module MstShinyColors
  class LinkSkill < Base
    include BaseSkill
    self.table_name = "link_skill"
    def parent
      base_id = String(self.id).tap do |x| x[1] = '0' end.to_i
      BaseSkill.find_by_id(base_id)
    end
  end
end
