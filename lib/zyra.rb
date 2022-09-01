# frozen_string_literal: true

require 'sinclair'
require 'jace'

# @api public
# @author darthjee
module Zyra
  autoload :VERSION, 'zyra/version'

  autoload :Builder,    'zyra/builder'
  autoload :Exceptions, 'zyra/exceptions'
  autoload :Registry,   'zyra/registry'

  class << self
    delegate :register, to: :registry

    def after(key, event, &block)
      builder_for(key).after(event, &block)
    end

    # Builds an instance of the registered model class
    #
    # @param key [String,Symbol] key under which the {Builder builder}
    #   is {Registry registered}
    # @param (see Builder#build)
    #
    # @yield (see Builder#build)
    # @return (see Builder#build)
    #
    # @see .register
    # @see Builder#build
    def build(key, **attributes, &block)
      builder_for(key).build(**attributes, &block)
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
    def create(key, **attributes, &block)
      builder_for(key).create(**attributes, &block)
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

    def builder_for(key)
      registry.builder_for(key) || raise(Exceptions::BuilderNotRegistered)
    end

    def registry
      @registry ||= Registry.new
    end
  end
end
