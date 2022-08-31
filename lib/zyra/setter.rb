# frozen_string_literal: true

module Zyra
  # @api private
  # @author Darthjee
  #
  # Wrapper responsible for setting attributes on a model
  class Setter
    # @param model [Object] model to be set
    def initialize(model)
      @model = model
    end

    private

    # Method called for every attribute to be set
    #
    # Since none of those attributes have been defined, the call
    # always falls under method missing
    #
    # The method call is always directed to the model
    #
    # @param method_name [Symbol] attribute to be set or method to be called
    #   on the model
    # @param args [Array] arguments to be sent to the method call
    def method_missing(method_name, *args, &block)
      return super unless @model.respond_to?("#{method_name}=")

      @model.public_send("#{method_name}=", *args, &block)
    end

    def respond_to_missing?(*args)
      super || @model.send(:respond_to_missing?, *args)
    end
  end
end
