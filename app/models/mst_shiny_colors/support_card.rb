module MstShinyColors
  class SupportCard < Base
    include BaseCard
    self.table_name = 'support_idol'
    has_many :support_skills, foreign_key: :support_idol_id
    has_one  :aid, class_name: 'SupportAidGroup', foreign_key: :support_idol_id
    STAT_GRADES = {
      singular: {
        F: 0, E: 80, D: 120, C: 160,
        B: 200, A:225, S: 250, SS: 300,
      },
      overall: {
        F: 300, E: 400, D: 475, C: 550,
        B: 610, A: 680, S: 740, SS: 780,
      },
      ratio: {
        F: 1.0, E: 1.05, D: 1.12, C: 1.25,
        B: 1.4, A: 1.7, S: 2.0, SS: 5.0,
      }
    }
    STAT_TEST = %w(vocal dance visual mental).freeze
    def support_skill_tiers
      support_skills.sort_by(&:level).group_by(&:level)
    end
    def level_limits
      SupportLevelLimit.where(rarity: rarity).pluck(:evolution_stage,:limit_level).to_h
    end
    def type
      :support
    end
    def incomplete?
      super ||
      self.max_mental_bonus.nil? ||
      false
    end
    def max_stats
      return [] if incomplete?
      attributes.values_at(*STAT_TEST.map{|k| "max_#{k}_bonus" })
    end
    def max_ratio_stat
      return if incomplete?
      Rational(max_stats.max, max_stats.min)
    end
    def max_overall_stat
      max_stats.inject(0,:+)
    end
    
    STAT_TEST.each do |k|
      define_method :"max_#{k}_grade" do
        return if incomplete?
        stat = attributes["max_#{k}_bonus"]
        STAT_GRADES[:singular].take_while do |(grade, bound)|
          stat >= bound
        end.last.first
      end
    end
    def max_ratio_grade
      return if incomplete?
      stat = max_ratio_stat
      STAT_GRADES[:ratio].take_while do |(grade, bound)|
        stat >= bound
      end.last.first
    end
    def max_overall_grade
      return if incomplete?
      stat = max_overall_stat
      STAT_GRADES[:overall].take_while do |(grade, bound)|
        stat >= bound
      end.last.first
    end
  end
end
