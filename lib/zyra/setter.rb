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
      @model.public_send("#{method_name}=", *args, &block)
    end
  end
end
