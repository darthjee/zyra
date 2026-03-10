# Copilot Instructions for `zyra`

## About This Project

`zyra` is a Ruby gem designed to be used from `db/seeds.rb` in Rails projects.
You define how an entity is **found** (via lookup keys/attributes), and Zyra
locates those entities using those keys.  If the entity is not found, Zyra
creates it with the additional attributes provided.

This makes seeding **idempotent**: running `rake db:seed` repeatedly does not
duplicate records, and it guarantees that required entities are always present
in the database.

---

## Language

- All PRs, PR descriptions, commit messages, review comments, documentation,
  and code **must be written in English**.

---

## Tests

- **Always add tests** for new behaviour and for any change to existing
  behaviour.
- Tests live in the `spec/` directory and use RSpec.
- Files that cannot reasonably be tested (e.g. version constants, exception
  class definitions) must be listed in `config/check_specs.yml` under the
  `ignore:` key with a brief comment explaining why tests are not applicable.

---

## Documentation (YARD)

- All **public APIs** must have YARD-compatible docstrings (`@param`, `@return`,
  `@example`, etc.).
- Update `README.md` and any relevant usage docs whenever public behaviour
  changes.

---

## `config/check_specs.yml`

Any file that is intentionally excluded from test coverage must be added to
`config/check_specs.yml`:

```yaml
ignore:
  - lib/zyra/version.rb   # version constant only, no logic to test
  - lib/zyra/exceptions.rb  # plain exception class definitions
```

If you add a new file without tests, add its path here with a comment
justifying the omission.

---

## Code Style — Small Classes & Single Responsibilities

Follow the principles described by Sandi Metz (including those in
*99 Bottles of OOP*):

- Keep **methods short** and intention-revealing; a method should do one thing.
- Prefer **extracting new objects** over adding conditionals to existing ones.
- Favour **composition over inheritance**.
- Name things after what they *do* or *represent*, not after implementation
  details.

---

## Law of Demeter

Avoid Demeter violations (chained message sends across object boundaries):

- **Pass collaborators** as arguments rather than reaching through objects.
- **Wrap** external calls in intention-revealing methods so callers do not need
  to know the internal structure of their dependencies.
- A method should only call methods on: `self`, objects passed as arguments,
  objects it creates, or direct component objects.
