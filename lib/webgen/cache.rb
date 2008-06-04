require 'set'
require 'facets/kernel/constant'

module Webgen

  class Cache

    attr_reader :permanent
    attr_reader :volatile

    def initialize()
      @old_data = {}
      @new_data = {}
      @volatile = {}
      @permanent = {:classes => []}
    end

    def [](key)
      if @old_data.has_key?(key)
        @old_data[key]
      else
        @new_data[key]
      end
    end

    def []=(key, value)
      @new_data[key] = value
    end

    def restore(data)
      @old_data, @permanent = *data
      @permanent[:classes].each {|klass| instance(klass)}
    end

    def dump
      [@old_data.merge(@new_data), @permanent]
    end

    def reset_volatile_cache
      @volatile = {:classes => @volatile[:classes]}
    end

    def instance(name)
      @permanent[:classes] << name unless @permanent[:classes].include?(name)
      (@volatile[:classes] ||= {})[name] ||= constant(name).new
    end

  end

end
