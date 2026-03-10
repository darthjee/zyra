Zyra
====
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/darthjee/zyra/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/darthjee/zyra/tree/main)
[![Gem Version](https://badge.fury.io/rb/zyra.svg)](https://badge.fury.io/rb/zyra)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/fe2da1c4711d4774bd7c46acd578da05)](https://app.codacy.com/gh/darthjee/zyra/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![Codacy Badge](https://app.codacy.com/project/badge/Coverage/fe2da1c4711d4774bd7c46acd578da05)](https://app.codacy.com/gh/darthjee/zyra/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_coverage)
[![Inline docs](http://inch-ci.org/github/darthjee/zyra.svg?branch=master)](http://inch-ci.org/github/darthjee/zyra)

![zyra](https://raw.githubusercontent.com/darthjee/zyra/master/zyra.jpg)

Zyra is intented to easy the seeding stage of projects by ensuring an
entity exists without having to reinsert it every time in the database

The process is done by registering a model class, then performing
a creation in case of missing the entry

Current Release: [1.2.0](https://github.com/darthjee/zyra/tree/1.2.0)

[Next release](https://github.com/darthjee/zyra/compare/1.2.0...main)

Yard Documentation
-------------------
[https://www.rubydoc.info/gems/zyra/1.2.0](https://www.rubydoc.info/gems/zyra/1.2.0)

Installation
---------------

- Install it

```ruby
  gem install zyra
```

- Or add Zyra to your `Gemfile` and `bundle install`:

```ruby
  gem 'zyra'
```

```bash
  bundle install zyra
```

Usage
-----

The usage is done by registering a model, adding hooks
and calling `find_or_create` and passing a block to be executed
after

```ruby
  Zyra
    .register(User, find_by: :email)
    .on(:build) do |user|
      user.reference = SecureRandom.hex(16)
    end

  attributes = {
    email: 'usr@srv.com',
    name: 'Some User',
    password: 'pass'
  }

  user = Zyra.find_or_create(:user, attributes) do |usr|
    usr.update(attributes)
  end

  # returns an instance of User that is persisted in the database
  # user.email is the key as 'usr@srv.com'
  # user.name will always be updated to 'Some User'
  # user.password will always be updated to 'pass'
  # user.reference will be generated in the first time, and never again regenerated
```

## Hooks

hooks can be registered when registering a model or after to be executed in 4
points, `found`, `build`, `create` and `return`

```ruby
  Zyra
    .register(User, find_by: :email)
    .on(:build) do |user|
      user.posts.build(name: 'first', content: 'some content')
    end

  Zyra.on(:user, :return) do |user|
    user.update(reference: SecureRandom.hex(16))
  end

  attributes = {
    email: 'usr@srv.com',
    name: 'Some User',
    password: 'pass'
  }

  user = Zyra.find_or_create(:user, attributes).reload

  # Returns a User with email 'usr@srv.com'
  # Creates a post for the user, only in the first time
  # Regenerates the reference every time the code is ran
```
