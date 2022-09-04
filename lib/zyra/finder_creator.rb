# frozen_string_literal: true

module Zyra
  class FinderCreator
    # @param model_class [Class] Model class that does the ORM
    # @param keys [Array<Symbol,String>] keys used when searching
    #   for the entry
    def initialize(model_class, keys)
      @model_class = model_class
      @keys = [keys].flatten.map(&:to_sym)
    end

    def find_or_create(attributes)
      finder.find(attributes) || builder.create(attributes)
    end

    # @api public
    # Register a handler on a certain event
    #
    # Possible event is +found+
    #
    # @param event [Symbol,String] event to be watched.
    # @param block [Proc] block to be executed when the event is called
    #
    # @yield [Object] the model built
    #
    # @return [Finder] the finder itself
    def after(event, &block)
      tap { event_registry.register(event, &block) }
    end

    protected

    # @method model_class
    # @api private
    #
    # Model class to be initialized into a model
    #
    # @return [Class]

    # @method keys
    # @api private
    #
    # Keys used when finding a model
    #
    # @return [Array<Symbol>]
    attr_reader :model_class, :keys

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

    def finder
      @finder ||= Finder.new(model_class, keys, event_registry: event_registry)
    end

    def builder
      @builder ||= Builder.new(model_class, event_registry: event_registry)
    end
  end
end
