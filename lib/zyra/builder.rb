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
    # Builds an instance of model_class
    #
    # @param attributes [Hash] attributes to be set in the model
    # @param block [Proc] block to be ran after where more attributes
    # will be set
    #
    # @yield [Setter] Setter wrapping model
    #
    # @return [Object] an instance of {#model_class model_class}
    def build(**attributes, &block)
      block ||= proc {}

      model_class.new(attributes).tap(&block).tap do |model|
        event_registry.trigger(:build, model)
      end
    end

    def create(**attributes, &block)
      build(**attributes, &block).tap(&:save)
    end

    # @api public
    # Register a handler on a certain event
    #
    # Possible events are +build+, +create+
    #
    # @param event [Symbol,String] event to be watched.
    # @param block [Proc] block to be executed when the event is called
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
