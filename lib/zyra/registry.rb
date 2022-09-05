# frozen_string_literal: true

module Zyra
  # @api private
  #
  # Registry of all registered creators
  class Registry
    # (see Zyra.register)
    def register(klass, key = nil, find_by:)
      key ||= klass.name.gsub(/::([A-Z])/, '_\1').downcase

      registry[key.to_sym] = FinderCreator.new(klass, find_by)
    end

    # Returns a registered creator
    #
    # when the creator was not registerd, +nil+ is returned
    #
    # @param key [String,Symbol] key under which the creator is registered
    #
    # @return [Zyra::Creator]
    def finder_creator_for(key)
      registry[key.to_sym]
    end

    private

    # @private
    #
    # Registry store for all creators
    #
    # @return [Hash] map of all registered creators
    def registry
      @registry ||= {}
    end
  end
end
