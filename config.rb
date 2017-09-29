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

# Activate directory indexes for pretty urls
activate :directory_indexes

activate :title, site: 'Middleman Boilerplate'

# Active sitemap generator
set :url_root, 'http://www.example.com'
activate :search_engine_sitemap,
  default_change_frequency: 'weekly',
  exclude_attr: 'private'

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
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  # blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/{num}"
end

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

###
# Helpers
###

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

