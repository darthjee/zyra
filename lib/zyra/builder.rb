# frozen_string_literal: true

module Zyra
  # @api private
  # @author Darthjee
  #
  # Class responsible for building a model
  class Builder
    # @param model_class [Class] Model class to be initialized
    #   into a model
    def initialize(model_class)
      @model_class = model_class
    end

    # @api public
    # Builds an instance of the registered model class
    #
    # @param attributes [Hash] attributes to be set in the model
    # @param block [Proc] block to be ran after where more attributes
    # will be set
    #
    # @yield [Object] Instance of the model class
    #
    # @return [Object] an instance of model class
    def build(**attributes, &block)
      block ||= proc {}

      model_class.new(attributes).tap(&block).tap do |model|
        event_registry.trigger(:build, model)
      end
    end

    # @api public
    # Creates an instance of the registered model class
    #
    # This behaves like {#build}, but persists the entry
    #
    # @param (see #build)
    # @yield (see #build)
    # @return (see #build)
    def create(**attributes, &block)
      model = build(**attributes, &block)

      event_registry.trigger(:create, model) do
        model.tap(&:save)
      end
    end

    # @api public
    # Register a handler on a certain event
    #
    # Possible events are +build+, +create+
    #
    # @param event [Symbol,String] event to be watched.
    # @param block [Proc] block to be executed when the event is called
    #
    # @yield [Object] the model built
    #
    # @return [Builder] the builder itself
    def after(event, &block)
      tap { event_registry.register(event, &block) }
    end

    # Checks if another builder is equal to the current builder
    #
    # This is used mostly for rspec expectations
    #
    # @param other [Object] other object to be compared
    #
    # @return [TrueClass,FalseClass]
    def ==(other)
      return unless other.class == self.class

      other.model_class == model_class
    end

    protected

    # @method model_class
    # @api private
    #
    # Model class to be initialized into a model
    #
    # @return [Class]
    attr_reader :model_class

    # @private
    #
    # Event registry
    #
    # The event registry will contain all handlers for
    # post build or creating events
    #
    # @return [Jace::Registry]
    def event_registry
      @event_registry ||= Jace::Registry.new
    end
  end
end
