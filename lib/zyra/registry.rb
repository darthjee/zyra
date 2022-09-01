# frozen_string_literal: true

module Zyra
  # @api private
  #
  # Registry of all registered builders
  class Registry
    # @api public
    # Register a new builder
    #
    # The builder will focus on one class and be registered under a
    # symbol key
    #
    # @param klass [Class] Model class to be used by the builder
    #
    # @overload register(klass)
    #   When the key is not provided, it is infered from the class name
    #
    # @overload register(klass, key)
    #   @param key [String,Symbol] key to be used when storyin the builder
    #
    # @return [Zyra::Builder] registered builder
    def register(klass, key = klass.name.gsub(/::([A-Z])/, '_\1').downcase)
      registry[key.to_sym] = Builder.new(klass)
    end

    # Returns a registered builder
    #
    # when the builder was not registerd, +nil+ is returned
    #
    # @param key [String,Symbol] key under which the builder is registered
    #
    # @return [Zyra::Builder]
    def builder_for(key)
      registry[key.to_sym]
    end

    private

    # @private
    #
    # Registry store for all builders
    #
    # @return [Hash] map of all registered builders
    def registry
      @registry ||= {}
    end
  end
end
