# frozen_string_literal: true

module Zyra
  # Class responsible for making sure a model existis
  #
  # First, the object searchs in he database by the keys, and
  # if it fails to finds, it creates a new entry
  class FinderCreator
    # @param model_class [Class] Model class that does the ORM
    # @param keys [Array<Symbol,String>] keys used when searching
    #   for the entry
    def initialize(model_class, keys)
      @model_class = model_class
      @keys = [keys].flatten.map(&:to_sym)
    end

    def find_or_create(attributes)
      find(attributes) || create(attributes)
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

    # @method find
    # @api public
    #
    # Search the entry in the database
    #
    # The query is done using part of the expected
    # attributes filtered by the configured keys}
    #
    # if the model is found an event is triggered
    #
    # @overload find(attributes)
    #   @param attributes [Hash] expected model attribiutes
    #
    # @return [Object] the model from the database
    delegate :find, to: :finder

    # @method create
    # @api public
    #
    # Creates an instance of the registered model class
    #
    # @overload create(attributes, &block)
    #   @param attributes [Hash] attributes to be set in the model
    #   @param block [Proc] block to be ran after where more attributes
    #   will be set
    #
    # @yield [Object] Instance of the model class
    #
    # @return [Object] an instance of model class
    delegate :create, to: :creator

    # Checks if another finder creator is equal to the current
    #
    # This is used mostly for rspec expectations
    #
    # @param other [Object] other object to be compared
    #
    # @return [TrueClass,FalseClass]
    def ==(other)
      return unless other.class == self.class

      other.model_class == model_class &&
        other.keys == keys
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

    # @private
    #
    # Returns an instance of {Finder}
    #
    # Finder will use the same event registry so that event
    # handling and registration is centralized
    #
    # @return Finder
    def finder
      @finder ||= Finder.new(model_class, keys, event_registry: event_registry)
    end

    # @private
    #
    # Returns an instance of {Creator}
    #
    # Creator will use the same event registry so that event
    # handling and registration is centralized
    #
    # @return Creator
    def creator
      @creator ||= Creator.new(model_class, event_registry: event_registry)
    end
  end
end
