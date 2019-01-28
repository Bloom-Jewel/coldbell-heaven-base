#!/usr/bin/env ruby
module ColdbellHeaven
  class BaseLightModel
    @__data = []
    @__primary_keys = []
    @__columns = []
    def initialize(**kwargs)
      @attributes = {}
      kwargs.each do |k,v|
        @attributes.store(k,v)
      end
      @attributes.freeze
    end
    def attributes
      @attributes
    end
    def method_missing(m, *a, &b)
      if self.class.columns.include?(m) then
        return @attributes[m]
      end
      super
    end
    def respond_to_missing?(m, pr)
      if self.class.columns.include?(m) then
        return true
      end
      super
    end
    def inspect
      id_hex = "%%%s0%dx" % [35.chr, 0.size << 1] % [self.object_id]
      attr_list = @attributes.inject([]){ |ar, (ak, av)|
        if self.class.columns.empty? || self.class.columns.include?(ak) then
          ar.push("%s: %s" % [ak, av.inspect])
        end
        ar
      }.join(' ')
      "%s<%s:%s %s>" % [35.chr, self.class.name, id_hex, attr_list]
    end
    class << self
      def all
        @__data.each.to_a
      end
      def columns
        # all.map(&:attributes).map(&:keys).inject(@__primary_keys,:|)
        @__columns.each.to_a
      end
      def primary_keys
        @__primary_keys.each.to_a
      end
      def find(*args,**kwargs)
        fail ArgumentError, "empty query" if kwargs.empty? && args.empty?
        fail ArgumentError, "primary key size does not match" if !args.empty? && args.size != primary_keys.size
        @__data.find do |obj|
          true && args.each_with_index.all? do |v,i|
            pk = @__primary_keys[i]
            obj.attributes[pk] == v
          end && kwargs.all? do |k,v|
            obj.attributes[k] == v
          end
        end
      end
      def new(*args)
        obj = allocate
        obj.send :initialize, *args
        @__data << obj
        obj.freeze
        obj
      end
      private
      def add_primary_keys(*args)
        fail ArgumentError, "empty query" if args.empty?
        args.map! do |x| x.to_s.to_sym end
        @__primary_keys.push(*args)
        nil
      end
      def set_primary_keys(*args)
        @__primary_keys.clear
        add_primary_keys(*args)
      end
      def set_columns(*args)
        @__columns.clear
        args.map! do |x| x.to_s.to_sym end
        @__columns.push(*args)
        nil
      end
      def inherited(cls)
        this = self
        cls.instance_exec do
          this.instance_variables.each do |ik|
            v = this.instance_variable_get(ik)
            instance_variable_set(ik, v.dup)
          end
        end
      end
    end
  end
end
