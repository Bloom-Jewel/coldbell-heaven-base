module MstShinyColors
  class MemorySkill < Base
    include BaseSkill
    include LinkableSkill
    self.table_name = "memory_appeals"
    def parent
      ProduceCard.find_by_idol_memory_appeal_group_id(self.idol_memory_appeal_group_id)
    end
    def human_stage
      "Memory #{level}"
    end
    def human_type
      ""
    end
    def human_cost
      "-"
    end
    def human_requirement
      "#{memory_point} MP"
    end
  end
end
