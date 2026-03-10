# `zyra` Gem — Integration Reference

> **Audience:** this document is intended for developers and GitHub Copilot in
> repositories that use (or plan to use) the `zyra` gem. It describes how to
> integrate and use the gem without having to inspect the original source code.

## What is `zyra`?

`zyra` is a Ruby gem for **idempotent database seeding** in Rails projects. It
ensures that certain entities exist in the database without duplicating them on
every `rake db:seed` run.

The basic flow is:

1. You **register** a model and define which attributes serve as lookup keys.
2. When `find_or_create` is called, the gem searches for the record by those keys.
3. If the record **does not exist**, it is created with all provided attributes.
4. If the record **already exists**, it is simply returned (no duplication).
5. Optional hooks allow extra logic to be executed at each step of the process.

---

## Installation

### Via `Gemfile` (recommended for Rails applications)

Add to your `Gemfile`:

```ruby
gem 'zyra'
```

Then install the dependencies:

```bash
bundle install
```

### Via `gemspec` (for gems that depend on `zyra`)

```ruby
spec.add_dependency 'zyra', '>= 1.2.0'
```

### Direct installation

```bash
gem install zyra
```

---

## Requirements

| Requirement   | Minimum version |
|---------------|-----------------|
| Ruby          | 2.7.0           |
| ActiveSupport | 7.0.4           |
| jace          | 0.1.1           |

`zyra` is compatible with any ORM framework that uses the `ActiveRecord`
interface (e.g. Rails with ActiveRecord).

---

## Initial setup

The gem requires no configuration files, environment variables, or separate
initializers. Simply include it in the seeding code:

```ruby
require 'zyra'
```

In Rails projects the gem is already loaded automatically via Bundler.

---

## Usage in Rails applications

The recommended place to use `zyra` is `db/seeds.rb`.

### Step 1 — Register the model

Call `Zyra.register` passing the model class and the attribute (or list of
attributes) to use as the lookup key:

```ruby
# db/seeds.rb

Zyra.register(User, find_by: :email)
```

Multiple keys:

```ruby
Zyra.register(Product, find_by: %i[sku store_id])
```

Register with a custom symbolic key (useful when the same model needs more than
one registration):

```ruby
Zyra.register(User, :admin_user, find_by: :email)
```

> When no key is provided, it is automatically derived from the class name
> (e.g. `User` → `:user`, `Admin::User` → `:admin_user`).

### Step 2 — Find or create the record

```ruby
# db/seeds.rb

user = Zyra.find_or_create(
  :user,
  email: 'admin@example.com',
  name:  'Administrator',
  role:  'admin'
)
# => a persisted User instance
```

On the **first run** the user is created with all provided attributes. On
**subsequent runs** the existing user is found by `email` and returned
unchanged (unless hooks are configured).

### Step 3 — Use the block to always update certain fields

The block passed to `find_or_create` is executed both on creation and when an
existing record is found, making it useful to ensure certain fields are always
up-to-date:

```ruby
attributes = {
  email:    'admin@example.com',
  name:     'Administrator',
  password: 'secure_password'
}

Zyra.find_or_create(:user, attributes) do |user|
  user.update(attributes)
end
```

---

## Available hooks

Hooks are registered with `Zyra.on(key, event)` (or chained on the return value
of `register`). The four possible events are:

| Event     | When it fires                                             |
|-----------|-----------------------------------------------------------|
| `:build`  | After the object is instantiated (before saving)          |
| `:create` | After the object is saved for the first time              |
| `:found`  | When the object is found in the database                  |
| `:return` | Always, after `:build`/`:create`/`:found` (post-return)   |

### Example: generate a token only on creation

```ruby
Zyra.register(User, find_by: :email)
    .on(:build) do |user|
      user.api_token = SecureRandom.hex(16)
    end

Zyra.find_or_create(:user, email: 'usr@srv.com', name: 'John')
# api_token is generated only the first time
```

### Example: force an update on every run

```ruby
Zyra.register(User, find_by: :email)

Zyra.on(:user, :return) do |user|
  user.update(last_seeded_at: Time.current)
end

Zyra.find_or_create(:user, email: 'usr@srv.com')
# last_seeded_at is updated on every seed run
```

### Example: create associated records only on first creation

```ruby
Zyra.register(User, find_by: :email)
    .on(:build) do |user|
      user.posts.build(title: 'Welcome', body: 'First post')
    end

Zyra.find_or_create(:user, email: 'usr@srv.com', name: 'John').reload
# The post is created only when the user is created for the first time
```

---

## Full example in `db/seeds.rb`

```ruby
# db/seeds.rb

# 1. Register models
Zyra.register(Role, find_by: :name)
Zyra.register(User, find_by: :email)
    .on(:build) { |u| u.api_token = SecureRandom.hex(16) }

# 2. Create roles
admin_role = Zyra.find_or_create(:role, name: 'admin')
_user_role = Zyra.find_or_create(:role, name: 'user')

# 3. Create the admin user and always keep the name up-to-date
Zyra.find_or_create(
  :user,
  email: 'admin@example.com',
  name:  'Admin',
  role:  admin_role
) do |user|
  user.update(name: 'Admin')
end
```

Run with:

```bash
rails db:seed
# or, to start from scratch:
rails db:reset
```

---

## Best practices and conventions

1. **Register models before using them** — ideally at the top of `db/seeds.rb`
   or in a separate file (`db/seeds/registrations.rb`) loaded at the start.

2. **Use `find_by` with unique and stable attributes** — emails, slugs, internal
   codes. Avoid attributes that change frequently.

3. **Prefer the block for optional updates** — put in the block only what must
   always be updated; attributes outside the block are used only on creation.

4. **Use `:build` hooks for data that should be generated only once** — tokens,
   unique references, etc.

5. **Use `:return` hooks for data that should always be refreshed** — audit
   timestamps, counters, etc.

6. **One `Zyra.register` per model per key** — if you need to look up the same
   model by different attributes, provide a distinct symbolic key:

   ```ruby
   Zyra.register(User, :user_by_email, find_by: :email)
   Zyra.register(User, :user_by_name,  find_by: :name)
   ```

7. **Avoid `Zyra.reset` in production code** — this method exists to facilitate
   testing and clears all registered models.

---

## Relevant rake tasks

| Command           | Description                                              |
|-------------------|----------------------------------------------------------|
| `rails db:seed`   | Runs `db/seeds.rb` (use `zyra` here)                     |
| `rails db:reset`  | Recreates the database and runs the seeds                |
| `rails db:setup`  | Creates the database, runs migrations and seeds          |

---

## Internal file reference for `darthjee/zyra`

| File                            | Responsibility                                           |
|---------------------------------|----------------------------------------------------------|
| `lib/zyra.rb`                   | Main module; exposes `register`, `on`, `find_or_create`  |
| `lib/zyra/registry.rb`          | Keeps the map of registered models                       |
| `lib/zyra/finder_creator.rb`    | Orchestrates the lookup and creation of a record         |
| `lib/zyra/finder.rb`            | Queries the database using the lookup key attributes     |
| `lib/zyra/creator.rb`           | Instantiates and persists a new record                   |
| `lib/zyra/exceptions.rb`        | Gem exceptions (`NotRegistered`, etc.)                   |
| `lib/zyra/version.rb`           | Version constant (`Zyra::VERSION`)                       |

Full YARD documentation: <https://www.rubydoc.info/gems/zyra>
(replace with the version installed in your project, e.g. `/gems/zyra/1.2.0`)

Repository: <https://github.com/darthjee/zyra>
