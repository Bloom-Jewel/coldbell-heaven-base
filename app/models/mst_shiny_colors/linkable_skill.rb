module MstShinyColors
  module LinkableSkill
    def link?
      return nil if @_cache_vattr.key?(:link_ptr) && @_cache_vattr[:link_ptr].nil?
      return @_cache_vattr[:have_link?] if @_cache_vattr.key?(:have_link?)
      @_cache_vattr[:have_link?] = !(self.link rescue nil).nil?
    end
    def link
      return @_cache_vattr[:link_ptr] if @_cache_vattr.key?(:link_ptr)
      link_id = String(self.id).tap do |x| x[1] = '9' end.to_i
      link_data = LinkSkill.find_by_id(link_id)
      @_cache_vattr[:link_ptr] = link_data
    end
    class << self
      def included(cls)
        fail "Bad attempt to include a non-Skill class!" unless cls.ancestors.include?(BaseSkill)
        cls.instance_exec do
          delegate :effects, to: :link, allow_nil: true, prefix: true
        end
      end
    end
  end
end
