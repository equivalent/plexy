ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

# Use the tailwind-cli-extra binary (TailwindCSS bundled with DaisyUI) from bin/
# instead of the plain CLI shipped with the tailwindcss-ruby gem.
# https://github.com/dobicinaitis/tailwind-cli-extra
ENV["TAILWINDCSS_INSTALL_DIR"] ||= File.expand_path("../bin", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
