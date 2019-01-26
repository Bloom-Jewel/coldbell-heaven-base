module MstShinyColors
  class ProduceCard < Base
    include BaseCard
    self.table_name = 'idol_data'
    def memory
      return @_cache_vattr[:memory_skills] if @_cache_vattr.key?(:memory_skills)
      @_cache_vattr[:memory_skills] = MemorySkill.where(idol_memory_appeal_group_id: self.idol_memory_appeal_group_id, level: 1..Float::INFINITY)
    end
    def type
      :produce
    end
    def chibi_path(skin_id=nil)
      if skin_id.is_a?(Integer)
        File.join(ASSET_IMAGE_PATH,'idols','costume_cb_icon',"3%02d%03d%03d%d.png" % [0,self.character_id,skin_id,0])
      else
        File.join(ASSET_IMAGE_PATH,'idols','costume_cb_icon',"%d.png" % [self.id])
      end
    end
    def sprite_path(skin_id=nil)
      File.join(ASSET_IMAGE_PATH,'idols','costume_stand`',"3%02d%03d%03d%d.png" % [0,self.character_id,skin_id,0])
    end
    def incomplete?
      super ||
      idol_memory_appeal_group_id.nil? ||
      false
    end
  end
end
