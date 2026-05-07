###
# Page options, layouts, aliases and proxies
###


# Include .well-known directory (Middleman ignores dot-directories by default)
page '/.well-known/*', layout: false

# Cloudflare Pages reads /_redirects at the build root for 301/302 rules.
# Middleman skips files starting with "_" (treats them as partials), so
# we copy source/_redirects to build/_redirects after each build.
after_build do |builder|
  src = File.join(builder.app.root, 'source', '_redirects')
  dst = File.join(builder.app.root, builder.app.config[:build_dir], '_redirects')
  FileUtils.cp(src, dst) if File.exist?(src)
end

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# Generate a feed
page '/feed.xml', layout: false

# Define 404 page
page '/404.html', directory_index: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Ignore `photo.html.erb` to prevent it from being processed directly
ignore "photo.html"
ignore "photo.html.erb"

# Generate a photo landing page (/photo.html) for every image, mounted at
# the image's slug-without-extension. linked_image() in dana_lol_helpers
# wraps every <img> in <a href="<slug>"> pointing here.
#
# Implemented as a single sitemap manipulator (rather than calling proxy
# in a `ready do` loop): each proxy() call inside ready triggers a full
# manipulator pipeline re-run, including middleman-images. With ~190
# images the build went from ~2 minutes to ~10. Adding them as one
# batch keeps the manipulator pipeline at one pass.
#
# Priority 90 runs after the blog plugin (default 50, sets URL-style
# destination_paths for date-folder images) and before directory_indexes
# (100, rewrites the .html proxy path into <slug>/index.html so CF Pages
# serves it as text/html at the bare-slug URL).
class PhotoLandingPages
  def initialize(app)
    @app = app
  end

  def manipulate_resource_list(resources)
    existing = resources.map(&:path).to_set
    new_proxies = []

    resources.each do |r|
      next unless r.path =~ /\.(jpg|png|gif)$/i
      next if r.path =~ %r{^assets/} || r.path =~ /ogp-image/

      ext = File.extname(r.destination_path)
      short_path = r.destination_path.sub(/#{Regexp.escape(ext)}$/, '') + '.html'
      next if existing.include?(short_path)
      existing << short_path

      proxy = ::Middleman::Sitemap::ProxyResource.new(@app.sitemap, short_path, '/photo.html')
      proxy.add_metadata(locals: { photo: r }, options: { layout: 'layout' })
      new_proxies << proxy
    end

    resources + new_proxies
  end
end

require 'set'
sitemap.register_resource_list_manipulator(:photo_landing_pages, PhotoLandingPages.new(self), 90)

# set the default URL
set :url_root, @app.data.settings.site.url

# Activate directory indexes for pretty urls
activate :directory_indexes

activate :title,
  site: @app.data.settings.site.title

# Active sitemap generator
activate :search_engine_sitemap,
  default_change_frequency: 'weekly',
  exclude_attr: 'unlisted'

# Allow syntax highlighting
set :markdown_engine, :redcarpet
set :markdown,
  fenced_code_blocks: true,
  smartypants: true
activate :syntax

# activate :robots,
#   rules: [{user_agent: '*', allow:  %w(/)}],
#   sitemap: @app.data.settings.site.url + 'sitemap.xml'

# Build-specific configuration
configure :build do
  config[:host] = 'https://www.dana.lol'

  # Minify CSS on build
  activate :minify_css

  # Minify HTML on build
  activate :minify_html

  # Minify images on build
  activate :images do |images|
    images.optimize = ENV['ENV'] != 'test'
    # see https://github.com/toy/image_optim for all available options
    images.image_optim = {
      # disabling svgo because it complains about the missing tool
      svgo: false
    }
  end

  # Minify Javascript on build
  # activate :minify_javascript
end

configure :development do
  config[:host] = 'http://localhost:4567'

  # Reload the browser automatically whenever files change
  activate :livereload

  # Don't minify images in development
  activate :images do |images|
    images.optimize = false
  end
end

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"

  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  # blog.sources = "{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  # blog.layout = "layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  blog.default_extension = '.md.erb'

  blog.tag_template = 'tag.html'
  blog.calendar_template = 'calendar.html'

  # disabling this prevents future-dated posts from being published
  blog.publish_future_dated = true

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
  # blog.page_link = "page/{num}"
end

# use Open Graph Protocol to generate URL previews
activate :ogp do |ogp|
  ogp.namespaces = {
    # these are defined in data/ogp/
    og: data.ogp.og,
    fb: data.ogp.fb
  }
  # turn on article support
  ogp.blog = true
end

