# Plexy

Rails 8.1.3 app on Ruby 4.0.5 (rbenv). No JS bundler — importmaps + Hotwire (Turbo/Stimulus). Propshaft asset pipeline, Solid Cache/Cable, pgbus for jobs, Kamal for deploys.

## Tech stack

- **Database**: PostgreSQL (`pg` gem). Local DBs: `plexy_development` / `plexy_test`. Production uses a multi-database layout (`primary` + `cache`/`cable` for the Solid gems) and expects `PLEXY_DATABASE_PASSWORD` or `DATABASE_URL`.
- **Background jobs**: [pgbus](https://pgbus.zoolutions.llc) (PGMQ-backed ActiveJob adapter + event bus), replacing Solid Queue. Configured in `config/initializers/pgbus.rb`; adapter set in `config/application.rb`. Workers run via `bin/pgbus start` (a `jobs` process in `Procfile.dev`). Dashboard mounted at `/pgbus` (needs auth before production exposure). The pgmq schema was installed by the pgbus migration in **embedded mode** (Homebrew Postgres has no pgmq extension) — it lives in the dev DB but is NOT in `schema.rb`, so the test DB has no pgmq schema; tests therefore use the `:test` ActiveJob adapter (`config/environments/test.rb`) and `Pgbus::Testing::MinitestHelpers` fake mode (`test/test_helper.rb`). A fresh database needs `bin/rails db:migrate` (not just schema load) to get pgmq installed.
- **Views**: Phlex (`phlex-rails`), not ERB. Components live in `app/components/` under the `Components::` namespace (a `Phlex::Kit`); full pages live in `app/views/` under `Views::`. Both namespaces are registered in `config/initializers/phlex.rb`. Base classes: `Components::Base` (< `Phlex::HTML`) and `Views::Base` (< `Components::Base`).
- **Reactive components**: [phlex-reactive](https://phlex-reactive.zoolutions.llc) — Livewire-style interactive Phlex components. **Preferred approach for ALL interactive UI in this project** — see the dedicated section below.
- **UI components**: `daisyui` gem (DaisyUI components as Phlex classes, docs: https://daisyui.phlex.fun). `DaisyUI` is included in `Components::Base`, so short-form syntax works everywhere: `Button(:primary) { "Save" }`, `Card(:base_100) { |card| card.body { ... } }`.
- **CSS**: Tailwind v4 (CSS-based config in `app/assets/tailwind/application.css` — there is no `tailwind.config.js`) via `tailwindcss-rails`.
- Controllers render Phlex views directly: `render Views::Pages::Landing.new`. Root route is `pages#landing`.

## phlex-reactive (use it heavily)

This project uses [phlex-reactive](https://phlex-reactive.zoolutions.llc) for interactive UI, and it should be the **default choice** for anything interactive: prefer a reactive component over hand-rolled Stimulus controllers, custom Turbo Stream templates, or dedicated controller actions. Only drop to raw Stimulus for purely client-side behavior with no server state.

How it works: one generic endpoint (`POST /reactive/actions`, mounted by the engine — zero routing per component) receives a signed identity token + action name, rebuilds the component server-side, runs the whitelisted action, and returns an auto-targeted Turbo Stream that morphs the component in place.

Conventions here:

- Reactive components live in `app/components/` like any other component, inherit `Components::Base`, and `include Phlex::Reactive::Component`. Reference example: `Components::Counter` (`app/components/counter.rb`), rendered on the landing page.
- **State-backed** (`reactive_state :foo`): state rides in the signed token — for ephemeral UI state. **Record-backed** (`reactive_record :foo`): the token carries a GlobalID, the record is re-found from the DB on every action, and actions persist directly (`@record.update!(...)`) — the DB *is* the state. Prefer record-backed whenever the data lives in a model.
- Declare every invokable method with `action :name` (+ `params:` schema for coercion); wire buttons/inputs with `on(:name)` inside a `reactive_root` element.
- **Authorization is fail-closed**: a mutating action that never calls an authorization method raises and rolls back. Call `authorize!`/`mark_authorized!` in the action, or declare `skip_verify_authorized` on genuinely public components (the app has no auth yet, so components currently use `skip_verify_authorized` — revisit when auth lands, along with `Phlex::Reactive.base_controller_name = "ApplicationController"` in the initializer).
- Broadcasting (cross-tab live updates) and deferred replies run over **pgbus** (auto-detected; the `realtime` capsule in `config/initializers/pgbus.rb` drains the broadcast queue). Use `Component.broadcast_to(...)` after saves that other sessions should see.
- Config lives in `config/initializers/phlex_reactive.rb` (all defaults currently). After adding/changing reactive components, run `bin/rails phlex_reactive:doctor` — it verifies routes, JS registration, stable `#id`s, action methods, and authorization intent.
- Flash replies (`reply.replace.flash(...)`) are sent but not yet rendered — the layout has no flash container.

## Tailwind + DaisyUI setup (read before touching CSS)

The plain `tailwindcss-ruby` binary does NOT include the DaisyUI plugin. We use
[tailwind-cli-extra](https://github.com/dobicinaitis/tailwind-cli-extra) (Tailwind CLI with DaisyUI bundled) instead:

- The binary lives at `bin/tailwindcss` — **gitignored** (~80MB). `bin/setup` downloads the right build for the current OS/arch (pinned v2.9.4). If Tailwind builds fail with a missing-binary error, run `bin/setup --skip-server` or just the download step.
- `config/boot.rb` sets `TAILWINDCSS_INSTALL_DIR` to `bin/`, which makes `tailwindcss-ruby` use that binary for every `bin/rails tailwindcss:*` and `assets:precompile` invocation. Don't remove that line.
- `@plugin "daisyui";` in `app/assets/tailwind/application.css` activates DaisyUI (only works with the extra binary).

### DaisyUI caveats

- **Absolute `@source` path**: `application.css` has an `@source` line pointing at the daisyui gem directory (rbenv path, includes the gem version). It must be updated whenever the gem version or Ruby version changes, and it's machine-specific. Check `bundle show daisyui` if DaisyUI modifier classes stop appearing.
- **`@source inline(...)` safelist is required**: the gem declares base classes as Ruby symbols (`self.component_class = :btn`), which Tailwind's scanner cannot extract (leading `:` is rejected as invalid variant syntax). Without the safelist, `.btn`, `.card`, etc. are never emitted and components render unstyled. The safelist in `application.css` lists all `component_class` values; if a gem update adds new components, regenerate it with:
  `grep -rh "component_class = :" $(bundle show daisyui)/lib/ | sed 's/.*= ://' | sort -u`
- **Tailwind utility classes in Ruby**: Tailwind v4 auto-scans project files (including `.rb`), so utility classes written in components (`class: "w-96 shadow-sm"`) are picked up — but only for literal strings. Don't build class names by string interpolation.
- After changing components/views, verify styles with `bin/rails tailwindcss:build` and grep `app/assets/builds/tailwind.css` for the expected class — a class present in HTML but missing from the build means a scanning gap.

## Deploy caveat (unresolved)

`config/deploy.yml` (Kamal) and the `Dockerfile` still assume the original SQLite setup:
- The Dockerfile does not download the **linux** tailwind-cli-extra binary, so `assets:precompile` in the image build will fail until that step is added.
- No Postgres accessory/external DB is configured for Kamal.

## Dev workflow

- `bin/setup` — installs gems, downloads `bin/tailwindcss`, prepares DBs, starts `bin/dev`.
- `bin/dev` — Puma + Tailwind watcher + pgbus worker (Foreman via `Procfile.dev`).
- `bin/rails test` — test suite.
- `.claude.json` in the repo configures the `daisyui` MCP server (`bundle exec daisyui-mcp`) for component documentation lookup.
