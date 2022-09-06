# frozen_string_literal: true

module Zyra
  # @api public
  #
  # Registry of all registered creators
  class Registry
    # (see Zyra.register)
    #
    # @example Register models searching
    #   registry = Zyra::Registry.new
    #
    #   registry.register(User, find_by: :email)
    #   registry
    #     .register(User, :user_by_name, find_by: :name)
    #     .on(:return) do |user|
    #       user.update(email: "#{user.name.gsub(/ /, '_')}@srv.com")
    #     end
    #
    #   attributes = {
    #     name: 'my name',
    #     email: 'my_email@srv.com'
    #   }
    #
    #   user = registry.find_or_create(:user, attributes)
    #   # returns a User with name 'my_email@srv.com'
    #
    #   user = registry.find_or_create(:user_by_name, attributes)
    #   # returns a User with name 'my_name@srv.com'
    def register(klass, key = nil, find_by:)
      key ||= klass.name.gsub(/::([A-Z])/, '_\1').downcase

      registry[key.to_sym] = FinderCreator.new(klass, find_by)
    end

    # Register a handler on a certain event
    #
    # Possible events are +found+, +build+, +create+
    # and +return+
    #
    # @param key [String,Symbol] key under which the
    #   {FinderCreator finder_creator}
    #   is {Zyra::Registry#register registered}
    #
    # @param (see FinderCreator#after)
    # @yield (see FinderCreator#after)
    # @return [Finder] The finder registered under that key
    #
    # @see Zyra::Finder#find
    # @see Zyra::Creator#create
    #
    # @example Adding a hook on return
    #   registry = Zyra::Registry.new
    #   registry.register(User, find_by: :email)
    #   registry.on(:user, :return) do |user|
    #     user.update(name: 'initial name')
    #   end
    #
    #   email = 'email@srv.com'
    #
    #   user = registry.find_or_create(
    #     :user,
    #     email: email
    #   )
    #   # returns a User with name 'initial name'
    #
    #   user.update(name: 'some other name')
    #
    #   user = registry.find_or_create(:user, email: email)
    #   # returns a User with name 'initial name'
    #
    # @example Adding a hook on found
    #   registry = Zyra::Registry.new
    #   registry.register(User, find_by: :email)
    #   registry.on(:user, :found) do |user|
    #     user.update(name: 'final name')
    #   end
    #
    #   email = 'email@srv.com'
    #   attributes = { email: email, name: 'initial name' }
    #
    #   user = registry.find_or_create(:user, attributes)
    #   # returns a User with name 'initial name'
    #
    #   user = registry.find_or_create(:user, attributes)
    #   # returns a User with name 'final name'
    #
    # @example Adding a hook on build
    #   registry = Zyra::Registry.new
    #   registry.register(User, find_by: :email)
    #   registry.on(:user, :build) do |user|
    #     user.name = 'initial name'
    #   end
    #
    #   email = 'email@srv.com'
    #
    #   user = registry.find_or_create(:user, email: email)
    #   # returns a User with name 'initial name'
    #
    #   user.update(name: 'some other name')
    #
    #   user = registry.find_or_create(:user, email: email)
    #   # returns a User with name 'some other name'
    #
    # @example Adding a hook on create
    #   registry = Zyra::Registry.new
    #   registry.register(User, find_by: :email)
    #   registry.on(:user, :create) do |user|
    #     user.update(name: 'initial name')
    #   end
    #
    #   email = 'email@srv.com'
    #
    #   user = registry.find_or_create(:user, email: email)
    #   # returns a User with name 'initial name'
    #
    #   user.update(name: 'some other name')
    #
    #   user = registry.find_or_create(:user, email: email)
    #   # returns a User with name 'some other name'
    def on(key, event, &block)
      finder_creator_for(key).on(event, &block)
    end

    # Builds an instance of the registered model class
    #
    # @param key [String,Symbol] key under which the
    #   {FinderCreator finder_creator}
    #   is {Zyra::Registry#register registered}
    #
    # @param (see FinderCreator#find_or_create)
    #
    # @yield (see FinderCreator#find_or_create)
    #
    # @return [Object] A model either from the database or just
    #   inserted into it
    #
    # @see #register
    # @see FinderCreator#find_or_create
    #
    # @example Regular usage passing all attributes
    #   registry = Zyra::Registry.new
    #   registry.register(User, find_by: :email)
    #
    #   email = 'email@srv.com'
    #
    #   user = registry.find_or_create(
    #     :user,
    #     email: email, name: 'initial name'
    #   )
    #   # returns a User with name 'initial name'
    #
    #   user = registry.find_or_create(
    #     :user,
    #     email: email, name: 'final name'
    #   )
    #   # returns a User with name 'initial name'
    def find_or_create(key, attributes = {}, &block)
      finder_creator_for(key).find_or_create(attributes, &block)
    end

    private

    # @private
    # @api private
    # Returns a registered creator
    #
    # when the creator was not registerd, +nil+ is returned
    #
    # @param key [String,Symbol] key under which the creator is registered
    #
    # @return [Zyra::Creator]
    def finder_creator_for(key)
      registry[key.to_sym] ||
        raise(Exceptions::NotRegistered)
    end

    # @private
    # @api private
    #
    # Registry store for all creators
    #
    # @return [Hash] map of all registered creators
    def registry
      @registry ||= {}
    end
  end
end
