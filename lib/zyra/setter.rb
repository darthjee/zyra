# frozen_string_literal: true

module Zyra
  class Setter
    def initialize(model)
      @model = model
    end

    def name(value)
      @model.name = value
    end
  end
end
