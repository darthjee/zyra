# frozen_string_literal: true

module Zyra
  # @api private
  # @author Darthjee
  #
  # Class responsible for building a model
  class Builder
    attr_reader :model_class

    # @param model_class [Class] Model class to be initialized
    #   into a model
    def initialize(model_class)
      @model_class = model_class
    end

    # Builds an instance of model_class
    #
    # @param attributes [Hash] attributes to be set in the model
    # @param block [Proc] block to be ran after where more attributes
    # will be set
    #
    # @yield [Setter] Setter wrapping model
    def build(**attributes, &block)
      block ||= proc {}
      model_class.new(attributes).tap(&block)
    end
  end
end
