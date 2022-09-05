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
    # @param event_registry [Jace::Registry] event registry to handle events
    def initialize(model_class, keys, event_registry:)
      @model_class = model_class
      @keys = [keys].flatten.map(&:to_sym)
      @event_registry = event_registry
    end

    # @api public
    # Search the entry in the database
    #
    # The query is done using part of the expected
    # attributes filtered by the configured keys}
    #
    # if the model is found an event is triggered
    #
    # @param attributes [Hash] expected model attribiutes
    #
    # @return [Object] the model from the database
    def find(attributes)
      model = find_by(attributes)
      return unless model

      event_registry.trigger(:found, model) { model }
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

    # @method event_registry
    # @private
    #
    # Event registry
    #
    # The event registry will contain all handlers for
    # post found events
    #
    # @return [Jace::Registry]
    attr_reader :model_class, :keys, :event_registry

    # private
    #
    # Extracts queriable attributes
    #
    # The queriable attributes are taken from the expected
    # attributes filtered by the given keys in the Finder
    # initialization
    #
    # @param (see #find)
    #
    # @return [Hash]
    def query_from(attributes)
      attributes.symbolize_keys.select do |attribute, _value|
        keys.include?(attribute)
      end
    end

    # @private
    #
    # Search the entry in the database
    #
    # The query is done using part of the expected
    # attributes filtered by the configured keys}
    #
    # @param (see #find)
    #
    # @return (see #find)
    def find_by(attributes)
      query = query_from(attributes)

      model_class.find_by(**query)
    end
  end
end
