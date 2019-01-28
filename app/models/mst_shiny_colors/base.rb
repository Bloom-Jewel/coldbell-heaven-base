module MstShinyColors
  class Base < ColdbellHeaven::ApplicationRecord
    self.logger&.level = 1 
    self.establish_connection :'master_shinydb'
    self.connection.disable_query_cache!
    self.abstract_class = true
    after_initialize do
      self.readonly!
      @_cache_vattr = {}
    end
    def attr
      if attributes.key?('attribute') then
        attributes['attribute']
      else
        nil
      end
    end
    def data_hash
      if attributes['hash'].present? then
        attributes['hash']
      else
        nil
      end
    end
    def id2
      return if id.blank?
      if data_hash.present? then
        "#{data_hash}_#{id}"
      else
        "#{id}"
      end
    end
    def readonly?; true; end
    class << self
      def cache(&block)
        yield
      end
    end
  end
end
