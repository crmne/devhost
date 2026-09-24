# Loaded by `devhost run -- jekyll serve`. Jekyll serve replaces site.url with
# http://localhost:PORT, so absolute links, feeds and SEO tags would bypass the
# https://NAME.localhost address devhost gives the site. Put it back.
Jekyll::Hooks.register :site, :after_init do |site|
  site.config["url"] = ENV["DEVHOST_URL"] if site.config["serving"] && ENV["DEVHOST_URL"]
end
