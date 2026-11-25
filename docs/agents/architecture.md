# Architecture

## Overview

Zyra is a Ruby gem for idempotent seeding. A model class is registered with
lookup keys; `find_or_create` looks the record up by those keys and creates it
(with the remaining attributes) only if it is missing. Lifecycle hooks are
supported through `Jace` events (e.g. `:build`).

## Source Code Layout

All application source code lives under `lib/`.

### `lib/zyra.rb`

Entry point. Declares autoloads and exposes the public API (`Zyra.register`,
`Zyra.find_or_create`, etc.) delegating to a registry.

### `lib/zyra/`

- `registry.rb` — Public. Stores registered `FinderCreator`s by key.
- `finder_creator.rb` — Ensures an entry exists: finds via `Finder`, else builds via `Creator`.
- `finder.rb` — Looks a model up in the DB using only the configured keys; triggers events.
- `creator.rb` — Builds and saves a model from attributes, running the block and events.
- `exceptions.rb` — Exception classes.
- `version.rb` — Version constant.

## Guidelines

Small single-responsibility classes, composition over inheritance, Law of
Demeter, YARD docs on public APIs, specs for all behaviour (see `AGENTS.md`).
