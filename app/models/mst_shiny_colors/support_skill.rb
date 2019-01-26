module MstShinyColors
  class SupportSkill < Base
    self.table_name = 'support_skills'
    belongs_to :support_card, class_name: 'SupportIdol'
    belongs_to :character, class_name: 'Chara'
    def effect
      SupportSkillEffect.where(support_skill_group: support_skill_group, support_skill_level: support_skill_level).take
    end
  end
end

