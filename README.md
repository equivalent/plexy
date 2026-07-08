# Plexy

A vibe-coded demo app — nothing serious here. It exists to try out
[pgbus](https://pgbus.zoolutions.llc) and PhlexReactive in a real-ish Rails app
(a tiny drum shop with products and a single-session shopping cart).

## Stack

- Rails 8.1 / Ruby 4.0, PostgreSQL
- [pgbus](https://pgbus.zoolutions.llc) — PGMQ-backed ActiveJob adapter + event bus (replaces Solid Queue)
- [Phlex](https://www.phlex.fun) views with the [daisyui](https://daisyui.phlex.fun) component gem
- Tailwind CSS v4 via [tailwind-cli-extra](https://github.com/dobicinaitis/tailwind-cli-extra) (DaisyUI bundled)
- Hotwire (Turbo/Stimulus), importmaps, no JS bundler

## Running it

```sh
bin/setup        # installs gems, downloads bin/tailwindcss, prepares DBs, starts bin/dev
bin/rails test   # test suite
```

The pgbus dashboard is mounted at `/pgbus` in development.

See [CLAUDE.md](CLAUDE.md) for architecture notes and setup caveats
(DaisyUI/Tailwind quirks, pgbus embedded-mode pgmq schema, etc.).
