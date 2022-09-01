# frozen_string_literal: true

module Zyra
  class Registry
    def register(klass, as: klass.name.gsub(/::([A-Z])/, '_\1').downcase)
      registry[as] = Builder.new(klass)
    end

    private

    def registry
      @registry ||= {}
    end
  end
end

