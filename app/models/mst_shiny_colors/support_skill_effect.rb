module MstShinyColors
  class SupportSkillEffect < Base
    self.table_name = 'support_skill_effect'
    def at_start?
      effect_type.in?(%w( friendship ))
    end
    def is_together?
      effect_type.in?(%w(tag_boost tension_boost tag_stamina excellent_mastery place_mastery perfect_mastery))
    end
    def is_deduction?
      effect_type.in?(%w(trouble_guard stamina_support))
    end
    def is_audition?
      effect_type.in?(%w( audition_mastery ))
    end
    def is_forgotten?
      effect_type.in?(%w( promise_recover ))
    end
    def is_success?
      effect_type.in?(%w( place_mastery perfect_mastery ))
    end
    def friendly_args
      attr_str = attributes['attribute'].dup.tap do |as|
        if as.count('_') < 1 then
          as.replace(as.capitalize[0,2])
        else
          as.replace(as.split('_').map(&:capitalize).map(&:chr).first(2).join(''))
        end
      end
      args = [effect_type, value, attr_str, tension]
      args[1] = -args[1] if is_deduction?
      args
    end

    def human_effect
      case effect_type
      when 'friendship'
        desc = 'initial friendship %2$+d'
      when 'tag_boost', 'tension_boost', 'audition_mastery'
        desc = '%3$s%2$+d'
      when 'tag_stamina'
        desc = 'stamina %2$+d%%'
      when 'rest_boost'
        desc = 'stamina %2$+d%%'
      when 'trouble_guard'
        desc = 'trouble rate %2$+d%%'
      when 'stamina_support'
        desc = 'stamina consumption %2$+d%%'
      when 'promise_recover'
        desc = 'prevent tension penalty'
      when 'excellent_mastery'
        desc = 'excellent boost rate %2$+d%%'
      when 'perfect_mastery'
        desc = 'auto PERFECT trigger'
      when 'place_mastery'
        desc = 'levels up place'
      else
        desc = "unk-%1$s %2$s %3$s"
      end
      desc
    end
    def human_description
      cond_str = human_condition
      cond_str = if human_condition.empty? then
                   ''
                 else
                   human_condition.join(', ') + ': '
                 end
      (cond_str + human_effect) % friendly_args
    end
    def human_chance
      if rate <= 0 then
        "Never"
      elsif rate < 100 then
        "%d%%%% chance" % [rate]
      else
        ""
      end
    end
    def human_condition
      cond_str = []
      
      cond_str << human_chance
      if produce_place_category_id > 0 then
        cond_str << ('on %s' % [
          'any place',
          'vocal lesson',
          'dance lesson',
          'visual lesson',
          'radio work',
          'talkshow work',
          'photoshoot work',
          nil,
          nil,
          'rest'
        ][produce_place_category_id] || "place #{produce_place_category_id}")
      end
      cond_str << "on start of session"   if at_start?
      cond_str << "when together"         if is_together?
      cond_str << "at least tension %4$d" if tension > 0
      cond_str << 'on 1st audition'       if is_audition?
      cond_str << 'on forgotten promise'  if is_forgotten?
      cond_str << 'not failing'           if is_success?
      cond_str.reject! &:empty?
      cond_str
    end
  end
end
