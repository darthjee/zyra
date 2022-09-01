# frozen_string_literal: true

require 'sinclair'
require 'jace'

# @api public
# @author darthjee
module Zyra
  autoload :VERSION, 'zyra/version'

  autoload :Builder,  'zyra/builder'
  autoload :Registry, 'zyra/registry'

  module Exceptions
    class BuilderNotRegistered < StandardError; end
  end

  class << self
    delegate :register, to: :registry

    def after(key, event, &block)
      builder_for(key).after(event, &block)
    end

    def build(key, **attributes, &block)
      builder_for(key).build(**attributes, &block)
    end

    def create(key, **attributes, &block)
      builder_for(key).create(**attributes, &block)
    end

    def reset
      @registry = nil
    end

    private

    def builder_for(key)
      registry.builder_for(key) || fail(Exceptions::BuilderNotRegistered)
    end

    def registry
      @registry ||= Registry.new
    end
  end
end
