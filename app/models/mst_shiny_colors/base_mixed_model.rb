module MstShinyColors
  module BaseMixedModel
    def method_missing(sym, *args, &block)
      if @_subclasses.empty? then
        fail TypeError, "No classes inheriting this module!"
      end
      if @_subclasses.any? { |scls| scls.respond_to?(sym,false) } then
        exceptions = []
        single_result = false
        found_result = false
        value = nil
        @_subclasses.inject([]) do |results, subclass|
          next results unless subclass.respond_to?(sym,false)
          begin
            temp_value = subclass.method(sym).call(*args, &block)
          rescue => e
            exceptions << e
            temp_value = nil
          end

          found_result |= !temp_value.nil?
          if temp_value.respond_to?(:to_ary) then
            results |= temp_value
          else
            single_result |= true
            break temp_value
          end if found_result
        end.tap do |result|
          if single_result then
            value = result # do i need to pop?
          else
            value = result
          end
        end
        return value if found_result
        fail exceptions.min_by{|exc|[exc.class.ancestors.size,exc.class.name,exc.message]} unless exceptions.empty?
        return value
      end
      super
    end
    def respond_to_missing?(sym, priv=false)
      @_subclasses.any?{|scls|scls.respond_to?(sym, priv)} || super
    end
    class << self
      def extended(cls) 
        cls.instance_exec do
          const_set :ClassMethods, Module.new
          private_constant :ClassMethods
          
          @_subclasses ||= []
          private
          def __mixed_model_included(scls)
            scls.extend(const_get(:ClassMethods))
            @_subclasses |= [scls]
          end
          def __base_model_included(scls)
          end
          def included(scls)
            __mixed_model_included(scls)
            __base_model_included(scls)
          end
        end
      end
    end
  end
  private_constant :BaseMixedModel
end

