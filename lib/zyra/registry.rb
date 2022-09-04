# frozen_string_literal: true

module Zyra
  # @api private
  #
  # Registry of all registered builders
  class Registry
    # (see Zyra.register)
    def register(klass, key = nil, find_by:)
      key ||= klass.name.gsub(/::([A-Z])/, '_\1').downcase

      registry[key.to_sym] = FinderCreator.new(klass, find_by)
    end

    # Returns a registered builder
    #
    # when the builder was not registerd, +nil+ is returned
    #
    # @param key [String,Symbol] key under which the builder is registered
    #
    # @return [Zyra::Builder]
    def finder_creator_for(key)
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
