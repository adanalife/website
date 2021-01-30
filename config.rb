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

# create a photo landing page for every image
ready do
  #TODO: is there a better way to find all images?
  images = sitemap.resources.map(&:path)
  images = images.select {|s| s =~ /\.(jpg|png)$/i && s !~ /assets\// && s !~ /ogp-image/ }
  images = images.map {|i| sitemap.find_resource_by_path(i)}
  images.each do |img|
    #TODO: add something like this to speed it up?
    # next if sitemap.find_resource_by_path(...)
    short_path = img.destination_path.sub(/#{File.extname(img.destination_path)}$/, '')
    proxy short_path, '/photo.html', layout: 'layout', locals: { photo: img }, ignore: true, content_type: 'text/html'
  end
end

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

