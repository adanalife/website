###
# Page options, layouts, aliases and proxies
###


# Include .well-known directory (Middleman ignores dot-directories by default)
page '/.well-known/*', layout: false

# Cloudflare Pages reads /_redirects (301/302 rules) and /_headers (response
# headers) at the build root. Middleman skips files starting with "_" (treats
# them as partials), so we copy them from source/ after each build.
after_build do |builder|
  %w[_redirects _headers].each do |file|
    src = File.join(builder.app.root, 'source', file)
    dst = File.join(builder.app.root, builder.app.config[:build_dir], file)
    FileUtils.cp(src, dst) if File.exist?(src)
  end

  # Report-only CSP. The inline scripts, inline event handlers and <style>
  # blocks are allowed by hash, computed here from the built HTML so an edit to
  # any of them can't leave a stale hash behind.
  build_dir = File.join(builder.app.root, builder.app.config[:build_dir])
  scripts = Set.new
  styles = Set.new
  Dir.glob(File.join(build_dir, '**', '*.html')).each do |page|
    doc = Nokogiri::HTML(File.read(page))
    doc.css('script:not([src])').each { |s| scripts << s.content unless s['type'] == 'application/ld+json' }
    doc.xpath('//@*[starts-with(name(), "on")]').each { |a| scripts << a.value }
    doc.css('style').each { |s| styles << s.content }
  end
  hash = ->(text) { "'sha256-#{Digest::SHA256.base64digest(text)}'" }
  workers = 'https://dana-lol-post-inbox.danadotlol.workers.dev'
  csp = [
    "default-src 'self'",
    "script-src 'self' https://static.cloudflareinsights.com 'unsafe-hashes' #{scripts.map(&hash).sort.join(' ')}",
    "style-src 'self' #{styles.map(&hash).sort.join(' ')}",
    "img-src 'self' data:",
    "connect-src 'self' https://cloudflareinsights.com #{workers}",
    'frame-src https://www.youtube-nocookie.com https://player.twitch.tv https://embed.twitch.tv',
    "form-action 'self' #{workers}",
    "base-uri 'self'",
    "object-src 'none'",
    "frame-ancestors 'self'"
  ].join('; ')
  # Cloudflare Pages applies only one `/*` block, so every site-wide header is
  # written here as a single block.
  headers = [
    # Nothing on the site uses these; a third-party frame can't ask for them either.
    'Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=(), usb=()',
    "Content-Security-Policy-Report-Only: #{csp}"
  ]
  # Staging serves the production build on its own hostnames; keep it out of
  # search results. A header rather than a robots.txt Disallow, because a
  # crawler that may not fetch a page never sees its noindex.
  headers << 'X-Robots-Tag: noindex' if ENV['STAGING'] == 'true'
  File.open(File.join(build_dir, '_headers'), 'a') do |f|
    f.puts "\n/*", headers.map { |h| "  #{h}" }
  end
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

# Ignore `photo.html.erb` to prevent it from being processed directly
ignore "photo.html"
ignore "photo.html.erb"

# The vendored-asset pin list is provenance for this repo, not something the
# site serves.
ignore "assets/vendor.txt"

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
require 'digest'
require 'nokogiri'
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

# Build-specific configuration
configure :build do
  config[:host] = 'https://www.dana.lol'

  # Minify CSS on build
  activate :minify_css

  # Minify HTML on build
  activate :minify_html

  # Images are not processed at build time. Source images are already
  # losslessly optimized — they're optimized once, when they enter source/,
  # and the committed bytes are what ships. The -opt URLs still in the wild
  # 301 to the bare filenames via source/_redirects.
end

configure :development do
  config[:host] = 'http://localhost:4567'

  # Reload the browser automatically whenever files change
  activate :livereload
end

activate :blog do |blog|
  blog.default_extension = '.md.erb'

  blog.tag_template = 'tag.html'
  blog.calendar_template = 'calendar.html'

  # disabling this prevents future-dated posts from being published
  blog.publish_future_dated = true

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
end

# use Open Graph Protocol to generate URL previews
activate :ogp do |ogp|
  ogp.namespaces = {
    # these are defined in data/ogp/
    #
    # @app.data (rather than the lazy `data` proxy) so the defaults arrive as
    # plain hashes: middleman-ogp merges a page's `ogp:` front matter into the
    # namespace hash, and a lazy proxy isn't a Hash, so it gets replaced
    # wholesale instead of merged — dropping og:image on every page that sets
    # a description of its own.
    og: @app.data.ogp.og,
    fb: @app.data.ogp.fb,
    twitter: @app.data.ogp.twitter
  }
  # turn on article support
  ogp.blog = true
  # emits og:url on every page
  ogp.base_url = @app.data.settings.site.url
end
