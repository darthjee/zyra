# frozen_string_literal: true

require 'sinclair'
require 'jace'

# @api public
# @author darthjee
module Zyra
  autoload :VERSION, 'zyra/version'

  autoload :Builder,  'zyra/builder'
  autoload :Registry, 'zyra/registry'

  class << self
    delegate :register, :builder_for, to: :registry

    def after(key, event, &block)
      builder_for(key).after(event, &block)
    end

    def build(key, **attributes, &block)
      builder_for(key).build(**attributes, &block)
    end

    def create(key, **attributes, &block)
      builder_for(key).create(**attributes, &block)
    end

    private

    def registry
      @registry ||= Registry.new
    end
  end
end
