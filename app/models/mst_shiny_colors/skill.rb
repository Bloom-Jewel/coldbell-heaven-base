module MstShinyColors
  class Skill < Base
    include BaseSkill
    include LinkableSkill
    self.table_name = "skill_data"
    after_initialize do
      @_real_parent = nil
    end
    
    def name
      type.in?([1,2]) ? super : '-'
    end
    
    def set_parent(panel)
      fail TypeError unless SkillPanel === panel
      @_real_parent = panel
    end
    def parent
      return @_real_parent if SkillPanel === @_real_parent
      case type
      when 1,2
        cut_id = String(self.id)[0...-2]
        SkillPanel.where("skill_id like '?%'",cut_id.to_i).take
      else
        SkillPanel.where(skill_id: String(self.id)).take
      end
    end
    
    def type
      Integer(String(self.id)[0])
    end
    def human_stage
      "Stage #{parent.step}"
    end
    def human_type
      case type
      when 1; "Main Skill"
      when 2; "Active Skill"
      when 3; "Passive Skill"
      else; "Misc Skill"
      end
    end
    def human_cost
      "#{10 * (parent.step.succ)} SP"
    end
    def human_requirement
      case parent.lock_type
      when NilClass; '-'
      when :commu; 'Special Commu'
      when :evolution; "#{parent.evolution_stage.ordinalize} Evol."
      else; 'Unknown'
      end
    end
    def human_condition_name
      case condition
      when NilClass; '---'
      when /^mental_[a-z]+er/; "Mental"
      when /^turn_[a-z]+/; "Length"
      when /^rival_or_[a-z]+/; "Rivals"
      when /^judge_or_[a-z]+/; "Judges"
      when /^star_or_[a-z]+/; "Stars"
      when 'character'; 'Character'
      when 'position'; "Deck"
      when 'ranking'; "Placement"
      else; condition
      end
    end
    def human_condition_value
      is_less = %w(lower early less).any?{|x|condition.end_with?(x)}
      case condition
      when NilClass; '---'
      # PERCENT BASED
      when /^mental_[a-z]+er/;
        "%s %d%%" % [
          is_less ? '<=' : '>=',
          condition_value
        ]
      # DISCRETE BASED
      when /^rival_or_[a-z]+/, /^judge_or_[a-z]+/, /^star_or_[a-z]+/;
        "%s %d" % [
          is_less ? '<=' : '>=',
          condition_value
        ]
      # SPECIAL HUMAN CONDITION
      when /^turn_[a-z]+/;
        "%s %s %d" % [
          is_less ? 'Up to' : 'Since',
          'Turn',
          condition_value,
        ]
      when 'character';
        chara = Chara.find_by_id(condition_value)
        if chara.nil? then
          '?'
        else
          chara.first_name_romaji
        end
      when 'position';
        %w(Any Center Leader Vocal Dance Visual).at(condition_value)
      when 'ranking';
        condition_value.ordinalize
      else; condition_value
      end
    end
  end
end
