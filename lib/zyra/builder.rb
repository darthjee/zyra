# frozen_string_literal: true

module Zyra
  class Builder
    attr_reader :model_class

    def initialize(model_class)
      @model_class = model_class
    end

    def build(*attributes)
    end
  end
end
