# frozen_string_literal: true

module Zyra
  # @api private
  # @author Darthjee
  #
  # Class responsible for finding a model in the DB
  class Finder
    def initialize(model_class, keys)
      @model_class = model_class
    end

    def find(**attributes)
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

    # Checks if another finder is equal to the current finder
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
