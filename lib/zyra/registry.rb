# frozen_string_literal: true

module Zyra
  # @api public
  #
  # Registry of all registered creators
  class Registry
    # (see Zyra.register)
    def register(klass, key = nil, find_by:)
      key ||= klass.name.gsub(/::([A-Z])/, '_\1').downcase

      registry[key.to_sym] = FinderCreator.new(klass, find_by)
    end

    # Register a handler on a certain event
    #
    # Possible events are +found+, +build+ and +create+
    #
    # @param key [String,Symbol] key under which the
    #   {FinderCreator finder_creator}
    #   is {Zyra::Registry#register registered}
    #
    # @param (see FinderCreator#after)
    # @yield (see FinderCreator#after)
    # @return (see FinderCreator#after)
    def after(key, event, &block)
      finder_creator_for(key).after(event, &block)
    end

    # Builds an instance of the registered model class
    #
    # @param key [String,Symbol] key under which the
    #   {FinderCreator finder_creator}
    #   is {Zyra::Registry#register registered}
    #
    # @param (see FinderCreator#find_or_create)
    #
    # @yield (see FinderCreator#find_or_create)
    #
    # @return (see FinderCreator#find_or_create)
    #
    # @see #register
    def find_or_create(key, attributes = {}, &block)
      finder_creator_for(key).find_or_create(attributes, &block)
    end

    private

    # @private
    # Returns a registered creator
    #
    # when the creator was not registerd, +nil+ is returned
    #
    # @param key [String,Symbol] key under which the creator is registered
    #
    # @return [Zyra::Creator]
    def finder_creator_for(key)
      registry[key.to_sym] ||
        raise(Exceptions::CreatorNotRegistered)
    end

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
