# frozen_string_literal: true

require 'jace'

module Zyra
  module Exceptions
    # Exception returned when a model has not been registered
    # and there is an attempt to use it
    class NotRegistered < StandardError; end
  end
end
