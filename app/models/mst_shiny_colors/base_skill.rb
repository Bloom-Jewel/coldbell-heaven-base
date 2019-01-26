module MstShinyColors
  ELSDescriptor = Struct.new(:type, :data) do
    def []=(*k,v); nil end
    def [](k); data[String(k).to_sym] end
  end
  
  module BaseSkill
    extend BaseMixedModel
    FES_POINT_ORDER = [
      :fes_deck_rank_point_leader, :fes_idol_rank_point, :fes_deck_rank_point_center,
      :fes_deck_rank_point_vocal, :fes_deck_rank_point_dance, :fes_deck_rank_point_visual,
    ].freeze
    
    private
    def fes_order
      FES_POINT_ORDER.map { |fes_key| sfk=String(fes_key); sfk_l=sfk.split('_').last; [sfk_l, attributes[sfk]] }.to_h
    end
    
    public
    def effects
      BaseSkillEffect.where_safe(self.id)
    end
    def parent
      nil
    end
    
    def contribute_fes_point?
      fes_order.any?(&:present?) && fes_order.values.map(&:to_i).any?(&:nonzero?)
    end
    
    def each_fes_order(slice=nil,&block)
      if Integer === slice && slice.in?(2...fes_order.size) then
        return fes_order.each_slice(slice,&block)
      end
      fes_order.each(&block)
    end
    def each_effect_iterable(&block)
      h = {'Effect'=>[],'Link'=>[],'Condition'=>[]}
      proc_eff = ->(k, ef){
        h[k] << ELSDescriptor.new(:eff, {name: ef.human_name, duration: ef.human_duration, target: ef.human_target})
      }
      effects.each do |ef| proc_eff.call('Effect',ef) end
      link_effects&.each do |ef| proc_eff.call('Link',ef) end if respond_to?(:link_effects)
      h['Condition'].tap do |hc|
        next unless respond_to?(:condition)
        next if condition.nil?
        hc << ELSDescriptor.new(:cond, {name: self.human_condition_name, value: self.human_condition_value})
        hc << ELSDescriptor.new(:cond, {name: 'Chance', value: '%d%%' % [self.rate] })
        hc << ELSDescriptor.new(:cond, {name: 'Limit', value: "%s %s" % [self.limit,'time'.pluralize(self.limit)]})
      end
      h.reject!{|k,v|v.empty?}
      h.each(&block)
    end
    
    module ClassMethods
    end
    class << self
      def all_pure_skill
        @_subclasses.select do |subclass|
          subclass.ancestors.include?(LinkableSkill)
        end.inject([]) do |result, subclass|
          result | subclass.all
        end
      end
    end
  end
end  

