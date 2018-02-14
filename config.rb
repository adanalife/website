###
# Page options, layouts, aliases and proxies
###

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

# set the default URL
set :url_root, @app.data.settings.site.url

# Activate directory indexes for pretty urls
activate :directory_indexes

activate :title,
  site: @app.data.settings.site.title

# Active sitemap generator
activate :search_engine_sitemap,
  default_change_frequency: 'weekly',
  exclude_attr: 'private'

# Allow syntax highlighting
set :markdown_engine, :redcarpet
set :markdown,
  fenced_code_blocks: true,
  smartypants: true
activate :syntax

# Shrink images during build
activate :imageoptim do |options|
  # pngout is sloooowww
  options.pngout = false
  # don't use threads so we have to wait for it to finish before pushing
  options.threads = false
end

# activate :robots,
#   rules: [{user_agent: '*', allow:  %w(/)}],
#   sitemap: @app.data.settings.site.url + 'sitemap.xml'

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }


# Build-specific configuration
configure :build do
  # Minify CSS on build
  activate :minify_css

  # Minify HTML on build
  activate :minify_html

  # Minify Javascript on build
  # activate :minify_javascript
end

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
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
  # blog.paginate = true
  # blog.per_page = 10
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

