module MstShinyColors
  module BaseSkillEffect
    extend BaseMixedModel
    EFFECT_NAMES = %w(
      damage
      mental
      limit_break
      
      mental_unfavorable_damage
      mental_favorable_damage
      hp_proportion_damage
      endure
      probability_blow
      memory_appeal_gauge_bonus
      finishing_bonus_star
      variable_damage_up
      variable_damage_down
      judge_attack_up
      judge_attack_down
      judge_target_up
      judge_target_down
      attention_up
      attention_down
      undeletable_attention_up
      undeletable_attention_down
      fastest_appeal
      slowest_appeal
      clear
      appeal_up
      appeal_down
      defense
      early_damage
      middle_damage
      late_damage
      status_bonus
      perfect_bonus
      regenerate
      slip_damage
    ).freeze
    TARGET_NAMES = %w(
      us rivals them
    ).freeze
    dg=->(s){Digest::SHA256.hexdigest(s)}
    hm=->(h,l){
      hs=h.map do |x| [x, dg.call(x)[0,l]] end.to_h
      hs.default_proc = ->(_h,_k){ _h[_k]=dg.call(_k)[0,l] }
      hs
    }
    EFFECT_CODES = hm.call(EFFECT_NAMES, 8)
    TARGET_CODES = hm.call(TARGET_NAMES, 2)
    def effect_type_id
      EFFECT_CODES[effect_type]
    end
    def target_group_id
      TARGET_CODES[target_group]
    end
    def effect_code
      Integer("%s%s" %  [effect_type_id, target_group_id], 16)
    rescue => e
      0
    end
    def human_base_name
      case effect_code
      when 0x1e36bc1879; 'Limit Break'
      #
      when 0xc21fd946c9; 'RVG'
      when 0xa964562cc9; 'STR'
      #
      when 0xd32ab87479; '%Me Loss'
      when 0xcfe98dea79,  0xcfe98dea62; 'Memory Gauge'
      when 0xa8341ad879; 'Reraise'
      #
      when 0xaeeec71379,  0xaeeec71362; 'Damage +'
      when 0xaeeec713c9; 'Demote +'
      when 0x4a8a401179,  0x4a8a401162; 'Damage -'
      when 0x4a8a4011c9; 'Demote -'
      #
      when 0x16a701de79,  0x16a701de62; 'Taunt +'
      when 0xdb14e6e279,  0xdb14e6e262; 'Taunt -'
      when 0xabe3d29479,  0xabe3d29462; 'X-Taunt +'
      when 0x7b5baf8679,  0x7b5baf8662; 'X-Taunt -'
      #
      when 0x3f0562ff79,  0x3f0562ff62; 'Immediate'
      when 0xba4da12279,  0xba4da12262; 'Delayed'
      #
      when 0x68d6532b79,  0x68d6532b62; 'Stat +'
      when 0x77ec756879,  0x77ec756862; 'Stat -'
      #
      when 0x6df1026c79,  0x6df1026c1d,  0x6df1026cc9; 'PFBoost'
      #
      when 0x459ba96779,  0x459ba96762; 'RGN'
      when 0xc8e9cd5d79,  0xc8e9cd5d62; 'PSN'
      else; "%010x" %  effect_code
      end
    end
    def human_base_format
      # sprintf format
      # args: :skill_name, :attribute, :value, :value2
      case effect_code
      # Default
      when 0x6f5a5c61c9,  0x3bf92d72c9; "%2$s%3$d%%"
      when 0x1e36bc1879; "Max%2$s%3$+d"
      # Me%-based damage
      when 0x888df6d179
        if skill_type == 'passive' then
          "+%3$d%%LossMe"
        else
          "+%3$d%%Me"
        end
      when 0xa8341ad879,  0xa8341ad862;
        "+%3$d%%Me [Reraise]"
      when 0xc21fd946c9,  0xa964562cc9; "%2$s~%4$d%% [%1$s]"
      when 0xd32ab87479,  0xd32ab87462; "-%3$d%%Me"
      when 0xcd4310a2c9; "1HKO %3$d%%"
      when 0xcfe98dea79,  0xcfe98dea62; "Memory%3$+d%%"
      # MeDmg modifier
      when 0xaeeec71379,  0xaeeec71362; "MeDmg+%3$d%%"
      when 0x4a8a401179,  0x4a8a401162; "MeDmg-%3$d%%"
      when 0xaeeec713c9; "Appeal+%3$d%%"
      when 0x4a8a4011c9; "Appeal-%3$d%%"
      when 0xca5390a7c9; "Attack+%3$d%%"
      when 0x438e9851c9; "Attack-%3$d%%"
      # Taunt
      when 0x16a701de79,  0x16a701de62; "Target+%3$d%%"
      when 0xdb14e6e279,  0xdb14e6e262; "Target-%3$d%%"
      when 0xabe3d29479,  0xabe3d29462; "Target+%3$d%% [FIX]"
      when 0x7b5baf8679,  0x7b5baf8662; "Target-%3$d%% [FIX]"
      # Order
      when 0x3f0562ff79,  0x3f0562ff62; "Immediate %3$d%%"
      when 0xba4da12279,  0xba4da12262; "Delayed %3$d%%"
      # Status
      when 0x68d6532b79,  0x68d6532b62; "%2$s+%3$d%%"
      when 0x77ec756879,  0x77ec756862; "%2$s-%3$d%%"
      # Hit Modifier
      when 0x6df1026c79; "x%3$d%% [PERFECT]"
      # Turn-based Me
      when 0x459ba96779,  0x459ba96762,  0xc8e9cd5d79,  0xc8e9cd5d62; "%3$d%%Me [%1$s]"
      else; "%s %s %s %s"
      end
    end
    def human_duration
      if Integer === self.turn && self.turn > 1 then
        "%d %s" % [self.turn, 'turn'.pluralize(self.turn)]
      else
        ''
      end
    end
    def human_target
      case target_group
      when 'us'; "Self"
      when 'them';
        if skill_type == 'judge_skill' then
          "Idol".pluralize(target_num)
        else
          "Judge".pluralize(target_num)
        end
      when 'rivals'; "Others"
      end
    end
    def human_name
      val = [human_base_name, attributes['attribute'].capitalize, value, nil]
      val[1] = val[1][0,2] if val[1] != 'All'
      case effect_code
      when 0xc21fd946c9,  0xa964562cc9; val[3] = val[2] * 5
      end
      fmt = human_base_format
      fmt % val
    end
    class << self
      def where_safe(id)
        @_subclasses.inject([]) do |result, subclass|
          query = subclass.where(id: nil)
          subclass.column_names.select do |key| key.end_with?('_id') end
            .map(&:to_sym)
            .each do |key|
              query = query.or(subclass.where(key => id))
            end
          result | query
        end
      end
    end
  end
end

