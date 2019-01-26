module MstShinyColors
  class SkillPanel < Base
    def card
      return @_cache_vattr[:card] if @_cache_vattr.key?(:card)
      @_cache_vattr[:card] = BaseCard.find(idol_id)
    end
    def skills
      return @_cache_vattr[:skills] if @_cache_vattr.key?(:skills)
      @_cache_vattr[:skills] = BaseSkill.where("id like '?%'",skill_id)
      @_cache_vattr[:skills].each do |skill| skill.set_parent(self) end
      @_cache_vattr[:skills]
    end
    def locked?
      !!lock_size.nonzero?
    end
    def lock_type
      return unless locked?
      return :commu if evolution_stage.zero?
      :evolution
    end
    def commu_lock?
      lock_type == :commu
    end
    def evolution_lock?
      lock_type == :evolution
    end
  end
end
