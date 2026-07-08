# Plexy

Rails 8.1.3 app on Ruby 4.0.5 (rbenv). No JS bundler — importmaps + Hotwire (Turbo/Stimulus). Propshaft asset pipeline, Solid Cache/Queue/Cable, Kamal for deploys.

## Tech stack

- **Database**: PostgreSQL (`pg` gem). Local DBs: `plexy_development` / `plexy_test`. Production uses a multi-database layout (`primary` + `cache`/`queue`/`cable` for the Solid gems) and expects `PLEXY_DATABASE_PASSWORD` or `DATABASE_URL`.
- **Views**: Phlex (`phlex-rails`), not ERB. Components live in `app/components/` under the `Components::` namespace (a `Phlex::Kit`); full pages live in `app/views/` under `Views::`. Both namespaces are registered in `config/initializers/phlex.rb`. Base classes: `Components::Base` (< `Phlex::HTML`) and `Views::Base` (< `Components::Base`).
- **UI components**: `daisyui` gem (DaisyUI components as Phlex classes, docs: https://daisyui.phlex.fun). `DaisyUI` is included in `Components::Base`, so short-form syntax works everywhere: `Button(:primary) { "Save" }`, `Card(:base_100) { |card| card.body { ... } }`.
- **CSS**: Tailwind v4 (CSS-based config in `app/assets/tailwind/application.css` — there is no `tailwind.config.js`) via `tailwindcss-rails`.
- Controllers render Phlex views directly: `render Views::Pages::Landing.new`. Root route is `pages#landing`.

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
- `bin/dev` — Puma + Tailwind watcher (Foreman via `Procfile.dev`).
- `bin/rails test` — test suite.
- `.claude.json` in the repo configures the `daisyui` MCP server (`bundle exec daisyui-mcp`) for component documentation lookup.
