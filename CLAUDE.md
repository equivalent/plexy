# Plexy

Rails 8.1.3 / Ruby 4.0.5. PostgreSQL, importmaps + Hotwire (no JS bundler), Propshaft, Solid Cache/Cable, [pgbus](https://pgbus.zoolutions.llc) for jobs, Kamal deploys (https://plexy.eq8.eu).

## Views & UI

- **Phlex, not ERB.** Components in `app/components/` (`Components::`), pages in `app/views/` (`Views::`). Controllers render directly: `render Views::Pages::Landing.new`.
- **Interactive UI: use [phlex-reactive](https://phlex-reactive.zoolutions.llc) by default** (Livewire-style components), not hand-rolled Stimulus/Turbo Streams. Reference example: `app/components/counter.rb`. Prefer `reactive_record` over `reactive_state` when data lives in a model. Run `bin/rails phlex_reactive:doctor` after changes.
- **DaisyUI** via the `daisyui` gem (docs: https://daisyui.phlex.fun; MCP server `daisyui` for lookup). Short form works everywhere: `Button(:primary) { "Save" }`.
- **Icons: always use [glyphs](https://github.com/mhenrixon/glyphs)** — never inline SVGs or emoji-as-icons. Available in every component/view: `LucideIcon(:house, class: "size-4")`, `HeroIcon(:check, variant: :solid)`; prefer Lucide (the default library). Names take symbols/strings, underscores become dashes (`:circle_check` → `circle-check`). SVGs are vendored in `app/assets/svg/icons/` (lucide + heroicons); browse them at `/rails_icons` in dev. To add another library: `bin/rails generate rails_icons:sync --libraries=<name>`.
- **Tailwind v4**, CSS-based config in `app/assets/tailwind/application.css`. The binary at `bin/tailwindcss` is gitignored (tailwind-cli-extra with DaisyUI bundled, downloaded by `bin/setup`) — don't build class names by string interpolation, and if DaisyUI classes go missing see the comments in `application.css` (safelist + `vendor/daisyui-src` symlink).

## Gotchas

- pgmq lives in the dev DB via migration (embedded mode), not in `schema.rb` — fresh DBs need `bin/rails db:migrate`; tests use the `:test` ActiveJob adapter + pgbus fake mode.
- No auth yet: reactive components use `skip_verify_authorized`; `/pgbus` dashboard is unauthenticated.

## Commands

- `bin/setup` — full setup; `bin/dev` — Puma + Tailwind watcher + pgbus worker.
- `bin/rails test` — test suite.
- `bin/kamal deploy` — deploy `main` to deploy.ahow.app → https://plexy.eq8.eu (Postgres runs as Kamal accessory `db`; secrets need `PLEXY_DATABASE_PASSWORD` in shell). Sanity-check after: `curl https://plexy.eq8.eu/up` → 200. Aliases: `bin/kamal logs`, `rc` (Rails console), `sh` (shell), `dbc`.
