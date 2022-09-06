# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'
require 'jace'

# @api public
# @author darthjee
#
# Zyra allows creators to be registered to ease up
# seeding
#
module Zyra
  autoload :VERSION, 'zyra/version'

  autoload :Creator,       'zyra/creator'
  autoload :Exceptions,    'zyra/exceptions'
  autoload :Finder,        'zyra/finder'
  autoload :FinderCreator, 'zyra/finder_creator'
  autoload :Registry,      'zyra/registry'

  class << self
    # @method register
    # @api public
    #
    # Register a new creator
    #
    # The creator will focus on one class and be registered under a
    # symbol key
    #
    # @overload register(klass)
    #   When the key is not provided, it is infered from the class name
    #   @param klass [Class] Model class to be used by the creator
    #
    # @overload register(klass, key)
    #   @param key [String,Symbol] key to be used when storyin the creator
    #   @param klass [Class] Model class to be used by the creator
    #
    # @return [Zyra::FinderCreator] registered finder_creator

    # @method on(key, event, &block)
    # @api public
    #
    # Register a handler on a certain event
    #
    # Possible events are +found+, +build+, +create+
    # and +return+
    #
    # @param (see Zyra::Registry#after)
    # @yield (see Zyra::Registry#after)
    # @return [Finder] The finder registered under that key
    #
    # @example Adding a hook on return
    #   Zyra.register(User, find_by: :email)
    #   Zyra.on(:user, :return) do |user|
    #     user.update(name: 'initial name')
    #   end
    #
    #   email = 'email@srv.com'
    #
    #   user = Zyra.find_or_create(
    #     :user,
    #     email: email
    #   )
    #   # returns a User with name 'initial name'
    #
    #   user.update(name: 'some other name')
    #
    #   user = Zyra.find_or_create(:user, email: email)
    #   # returns a User with name 'initial name'
    #
    # @example Adding a hook on found
    #   Zyra.register(User, find_by: :email)
    #   Zyra.on(:user, :found) do |user|
    #     user.update(name: 'final name')
    #   end
    #
    #   email = 'email@srv.com'
    #   attributes = { email: email, name: 'initial name' }
    #
    #   user = Zyra.find_or_create(:user, attributes)
    #   # returns a User with name 'initial name'
    #
    #   user = Zyra.find_or_create(:user, attributes)
    #   # returns a User with name 'final name'
    #
    # @example Adding a hook on build
    #   Zyra.register(User, find_by: :email)
    #   Zyra.on(:user, :build) do |user|
    #     user.name = 'initial name'
    #   end
    #
    #   email = 'email@srv.com'
    #
    #   user = Zyra.find_or_create(:user, email: email)
    #   # returns a User with name 'initial name'
    #
    #   user.update(name: 'some other name')
    #
    #   user = Zyra.find_or_create(:user, email: email)
    #   # returns a User with name 'some other name'
    #
    # @example Adding a hook on create
    #   Zyra.register(User, find_by: :email)
    #   Zyra.on(:user, :create) do |user|
    #     user.update(name: 'initial name')
    #   end
    #
    #   email = 'email@srv.com'
    #
    #   user = Zyra.find_or_create(:user, email: email)
    #   # returns a User with name 'initial name'
    #
    #   user.update(name: 'some other name')
    #
    #   user = Zyra.find_or_create(:user, email: email)
    #   # returns a User with name 'some other name'

    # @method find_or_create(key, attributes = {}, &block)
    # @api public
    #
    # Builds an instance of the registered model class
    #
    # @param (see Zyra::Registry#after)
    # @yield (see Zyra::Registry#after)
    # @return [Object] A model either from the database or just
    #   inserted into it
    #
    # @see .register
    #
    # @example Regular usage passing all attributes
    #   Zyra.register(User, find_by: :email)
    #
    #   email = 'email@srv.com'
    #
    #   user = Zyra.find_or_create(
    #     :user,
    #     email: email, name: 'initial name'
    #   )
    #   # returns a User with name 'initial name'
    #
    #   user = Zyra.find_or_create(
    #     :user,
    #     email: email, name: 'final name'
    #   )
    #   # returns a User with name 'initial name'
    delegate :register, :on, :find_or_create, to: :registry

    # @api private
    #
    # Resets the state of the registry
    #
    # This is mainly used for testing
    #
    # @return [NilClass]
    def reset
      @registry = nil
    end

    private

    # @private
    # @api private
    #
    # Returns the registry containing all the creators
    #
    # @return [Registry]
    def registry
      @registry ||= Registry.new
    end
  end
end
