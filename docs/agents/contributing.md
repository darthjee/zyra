# Contributing

## Commit Guidelines

- **Atomic and Unitary:** Each commit must represent a single logical change.
  *Example:*
  - Good: `Add Finder#find_by_keys method`
  - Bad: `Add Finder#find_by_keys and refactor Registry logic`
- **No Unrelated Changes:** Do not mix unrelated changes in the same commit.
- **Separate Refactoring:** Whenever possible, separate refactoring commits from new feature or bugfix commits.

## Pull Requests

- **Descriptive Summary:** Every PR must include a clear and descriptive summary of its purpose and changes.
- **PR Description Files:** If a description cannot be provided directly in the PR, generate a file with the PR description (e.g., `docs/issues/<pr_number>_description.md`), but do not commit this file.

## Definition of Done for PRs

A PR is considered complete when:

- The stated objective has been achieved.
- All tests are passing.
- Linting passes without errors.
- Code coverage is as high as reasonably possible.
- Public APIs have YARD docs; README/usage docs are updated for public behaviour changes.
- Code is not overly complex:
  - Classes and methods should have clear, focused responsibilities.
  - Methods should be small and do exactly one thing. If a method is growing, extract private helpers or separate classes.
  - *Example:*

    ```ruby
    # Good: each method does one thing
    class Worker
      def fetch_job; end
      def process_job(job); end
    end

    # Bad: method does too much
    class Worker
      def run
        fetch_job
        process_job
        send_metrics
        cleanup
      end
    end
    ```

  - This applies primarily to source code. For specs, refactor only if there is excessive duplication.

### CI Checks

Before a PR is considered complete, all CI checks relevant to the modified parts of the project must pass locally. The project is a single gem, so CircleCI runs these jobs on every change:

| Modified area | CircleCI job | Local commands |
|---|---|---|
| `lib/`, `spec/` | `test` | `bundle exec rspec` |
| any | `checks` | `rubocop`, `bundle exec rake verify_measurements`, `check_readme.sh`, `rubycritic.sh`, `check_specs` |

Locally, run inside Docker: `make tests` (opens a shell), then e.g. `rspec && yard && rake yardstick_measure && rake verify_measurements`.

When **planning how to resolve an issue**, include a final step listing the CI commands to run before opening a PR.

## Code Organization

### File Responsibility: Class Declarers vs Scripts

Every source file (excluding specs) must act as a **class declarer** — define one or more classes or modules, and not execute logic or side effects at load time. The only entrypoint is `lib/zyra.rb`, which declares autoloads and the public API.

```ruby
# Good: class declarer
class Router
  def register(app); end
end

# Bad: script — executes logic at load time
router = Router.new
router.register(app)
```

Specs are exempt.

### File Naming: snake_case for Class Files

Files defining a class use **snake_case** matching the class name, and live under the module path (e.g. `Zyra::FinderCreator` → `lib/zyra/finder_creator.rb`). Specs mirror this: `spec/lib/zyra/finder_creator_spec.rb`.

### Method Order: Public Before Private

Public methods are declared before private methods; private helpers go at the end of the class body.

```ruby
# Good
class Worker
  def run
    prepare
    execute
  end

  private

  def prepare; end
  def execute; end
end
```

## Dependency Injection

Classes must receive their dependencies (data, configuration, collaborators) as constructor arguments. A class must never read files or environment variables on its own; the entry point loads configuration and passes it down. This keeps every class independently testable (as `Finder` and `Creator` do with `event_registry:`).

```ruby
# Good
class Router
  def initialize(data)
    @data = data
  end
end

# Bad: loads its own config
class Router
  def build
    data = YAML.load_file('./data.yml')
  end
end
```

## Refactoring Guidelines

When refactoring, aim to:

- **Reduce Code Duplication:** e.g. move repeated spec setup into factories (`spec/support/factories`).

  ```ruby
  # Good
  create(:category, id: 2)
  # Bad: the same hash repeated in many specs
  Category.new(id: 2, name: 'Books')
  ```

- **Prefer Extracting Objects** over adding conditionals (Sandi Metz).
- **Avoid Demeter violations:** wrap chained calls in intention-revealing methods.
- **Keep behaviour unchanged** and covered by passing specs throughout.
