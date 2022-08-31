# frozen_string_literal: true

module Zyra
  class Builder
    attr_reader :model_class

    def initialize(model_class)
      @model_class = model_class
    end

    def build(**attributes, &block)
      model_class.new(attributes).tap do |model|
        Setter.new(model).tap(&block) if block
      end
    end
  end
end
