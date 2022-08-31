# frozen_string_literal: true

module Zyra
  class Setter
    def initialize(model)
      @model = model
    end

    def name(value)
      @model.name = value
    end

    private

    def method_missing(method_name, *args, &block)
      return super unless @model.respond_to?("#{method_name}=")

      @model.public_send("#{method_name}=", *args, &block)
    end

    def respond_to_missing?(*args)
      super || @model.send(:respond_to_missing?, *args)
    end
  end
end
