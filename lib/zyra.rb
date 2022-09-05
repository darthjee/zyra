# frozen_string_literal: true

require 'sinclair'
require 'jace'

# @api public
# @author darthjee
#
# Zyra allows builders to be registered to ease up
# seeding
module Zyra
  autoload :VERSION, 'zyra/version'

  autoload :Builder,       'zyra/builder'
  autoload :Exceptions,    'zyra/exceptions'
  autoload :Finder,        'zyra/finder'
  autoload :FinderCreator, 'zyra/finder_creator'
  autoload :Registry,      'zyra/registry'

  class << self
    # @method .register
    # @api public
    #
    # Register a new builder
    #
    # The builder will focus on one class and be registered under a
    # symbol key
    #
    # @overload register(klass)
    #   When the key is not provided, it is infered from the class name
    #   @param klass [Class] Model class to be used by the builder
    #
    # @overload register(klass, key)
    #   @param key [String,Symbol] key to be used when storyin the builder
    #   @param klass [Class] Model class to be used by the builder
    #
    # @return [Zyra::Builder] registered builder
    delegate :register, to: :registry

    # Register a handler on a certain event
    #
    # Possible events are +build+, +create+
    #
    # @param key [String,Symbol] key under which the {Builder builder}
    #   is {Registry registered}
    # @param (see Builder#after)
    #
    # @yield [Object] the model built
    #
    # @return (see Builder#after)
    def after(key, event, &block)
      finder_creator_for(key).after(event, &block)
    end

    # Builds an instance of the registered model class
    #
    # @param key [String,Symbol] key under which the {Builder builder}
    #   is {Registry registered}
    # @param (see Builder#build)
    #
    # @yield (see Builder#build)
    #
    # @return (see Builder#build)
    #
    # @see .register
    # @see Builder#build
    def build(key, attributes = {}, &block)
      finder_creator_for(key).build(attributes, &block)
    end

    # Creates an instance of the registered model class
    #
    # This behaves like {.build}, but persists the entry
    #
    # @param (see .build)
    # @yield (see .build)
    # @return (see .build)
    #
    # @see .register
    # @see Builder#create
    def create(key, attributes = {}, &block)
      finder_creator_for(key).create(attributes, &block)
    end

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
    # Returns a registered builder for a key
    #
    # @param key [String,Symbol] key under which the {Builder builder}
    #   is {Registry registered}
    #
    # @return [Builder]
    def finder_creator_for(key)
      registry.finder_creator_for(key) ||
        raise(Exceptions::BuilderNotRegistered)
    end

    # @private
    # @api private
    #
    # Returns the registry containing all the builders
    #
    # @return [Registry]
    def registry
      @registry ||= Registry.new
    end
  end
end
