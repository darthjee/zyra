# frozen_string_literal: true

module Zyra
  class Registry
    def register(klass, key = klass.name.gsub(/::([A-Z])/, '_\1').downcase)
      registry[key.to_sym] = Builder.new(klass)
    end

    def builder_for(key)
      registry[key.to_sym]
    end

    private

    def registry
      @registry ||= {}
    end
  end
end
