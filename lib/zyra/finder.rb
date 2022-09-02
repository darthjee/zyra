# frozen_string_literal: true

module Zyra
  # @api private
  # @author Darthjee
  #
  # Class responsible for finding a model in the DB
  class Finder
    # @param model_class [Class] Model class that does the ORM
    # @param keys [Array<Symbol,String>] keys used when searching
    #   for the entry
    def initialize(model_class, keys)
      @model_class = model_class
      @keys = [keys].flatten.map(&:to_sym)
    end

    # Search the entry in the database
    #
    # The query is done using part of the expected
    # attributes filtered by the configured keys}
    #
    # @param attributes [Hash] expected model attribiutes
    #
    # @return [Object] the model from the database
    def find(attributes)
      model = find_by(attributes)
      return unless model

      event_registry.trigger(:found, model) { model }
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

    def query_from(attributes)
      attributes.symbolize_keys.select do |attribute, _value|
        keys.include?(attribute)
      end
    end

    def find_by(attributes)
      query = query_from(attributes)

      model_class.find_by(**query)
    end
  end
end
