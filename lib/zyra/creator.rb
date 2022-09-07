# frozen_string_literal: true

module Zyra
  # @api private
  # @author Darthjee
  #
  # Class responsible for building a model
  class Creator
    # @param model_class [Class] Model class to be initialized
    #   into a model
    # @param event_registry [Jace::Registry] event registry to handle events
    def initialize(model_class, event_registry:)
      @model_class = model_class
      @event_registry = event_registry
    end

    # Creates an instance of the registered model class
    #
    # @param attributes [Hash] attributes to be set in the model
    # @param block [Proc] block to be ran after where more attributes
    # will be set
    #
    # @yield [Object] Instance of the model class
    #
    # @return [Object] an instance of model class
    def create(**attributes, &block)
      block ||= proc {}

      model = build(**attributes)

      event_registry.trigger(:create, model) do
        model.tap(&:save).tap(&block)
      end
    end

    protected

    # @private
    # Builds an instance of the registered model class
    #
    # @param (see #create)
    # @yield (see #create)
    # @return (see #create)
    def build(**attributes)
      model_class.new(attributes).tap do |model|
        event_registry.trigger(:build, model)
      end
    end

    # @method model_class
    # @api private
    #
    # Model class to be initialized into a model
    #
    # @return [Class]

    # @method event_registry
    # @private
    #
    # Event registry
    #
    # The event registry will contain all handlers for
    # post build or creating events
    #
    # @return [Jace::Registry]
    attr_reader :model_class, :event_registry
  end
end
