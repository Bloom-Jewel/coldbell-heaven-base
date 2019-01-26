module MstShinyColors
  class SupportAidGroup < Base
    self.table_name = 'support_idol_active_skill'
    def levels
      SupportAidLevel.where(support_idol_active_skill_id: self.id).pluck(:required_idol_level,:skill_level).to_h
    end
    def skills
      BaseSkill.where('id like "?%"', self.concert_active_skill_group_id)
    end
    def level_skill
      skill_list = skills.to_a
      levels.map do |idol_level, skill_level|
        [idol_level, skill_list.find { |skill| skill.level == skill_level }]
      end.to_h
    end
  end
end

