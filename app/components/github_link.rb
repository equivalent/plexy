# frozen_string_literal: true

# Link to the project's GitHub repo, pinned to the top-right corner of every page.
class Components::GithubLink < Components::Base
  REPO_URL = "https://github.com/equivalent/plexy"

  def view_template
    Button(:ghost, :sm, as: :a, href: REPO_URL, target: "_blank", rel: "noopener",
           class: "fixed top-4 right-4 z-10") do
      LucideIcon(:external_link, class: "size-4")
      plain "GitHub"
    end
  end
end
