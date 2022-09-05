# frozen_string_literal: true

require 'sinclair'
require 'jace'

# @api public
# @author darthjee
#
# Zyra allows creators to be registered to ease up
# seeding
module Zyra
  autoload :VERSION, 'zyra/version'

  autoload :Creator,       'zyra/creator'
  autoload :Exceptions,    'zyra/exceptions'
  autoload :Finder,        'zyra/finder'
  autoload :FinderCreator, 'zyra/finder_creator'
  autoload :Registry,      'zyra/registry'

  class << self
    # @method register
    # @api public
    #
    # Register a new creator
    #
    # The creator will focus on one class and be registered under a
    # symbol key
    #
    # @overload register(klass)
    #   When the key is not provided, it is infered from the class name
    #   @param klass [Class] Model class to be used by the creator
    #
    # @overload register(klass, key)
    #   @param key [String,Symbol] key to be used when storyin the creator
    #   @param klass [Class] Model class to be used by the creator
    #
    # @return [Zyra::FinderCreator] registered finder_creator

    # @method after(key, event, &block)
    # Register a handler on a certain event
    #
    # Possible events are +found+, +build+, +create+
    #
    # @param (see Zyra::Registry#after)
    # @yield (see Zyra::Registry#after)
    # @return (see Zyra::Registry#after)
    delegate :register, :after, to: :registry

    # Builds an instance of the registered model class
    #
    # @param key [String,Symbol] key under which the {Creator creator}
    #   is {Registry registered}
    # @param (see FinderCreator#find_or_create)
    #
    # @yield (see FinderCreator#find_or_create)
    #
    # @return (see FinderCreator#find_or_create)
    #
    # @see .register
    # @see FinderCreator#find_or_create
    def find_or_create(key, attributes = {}, &block)
      finder_creator_for(key).find_or_create(attributes, &block)
    end

    # @api private
    #
    # Resets the state of the registry
    #
    # This is mainly used for testing
    #
    # @return [NilClass]
    def reset
      @registry = nil
    end

    private

    # @private
    # @api private
    #
    # Returns a registered creator for a key
    #
    # @param key [String,Symbol] key under which the {Creator creator}
    #   is {Registry registered}
    #
    # @return [Creator]
    def finder_creator_for(key)
      registry.finder_creator_for(key) ||
        raise(Exceptions::CreatorNotRegistered)
    end

    # @private
    # @api private
    #
    # Returns the registry containing all the creators
    #
    # @return [Registry]
    def registry
      @registry ||= Registry.new
    end
  end
end
