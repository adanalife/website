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

# Active sitemap generator
set :url_root, 'http://www.whalecore.com'
activate :search_engine_sitemap,
  default_change_frequency: 'weekly',
  exclude_attr: 'private'

# Allow syntax highlighting
set :markdown_engine, :redcarpet
set :markdown,
  fenced_code_blocks: true,
  smartypants: true
activate :syntax

# Automatic image dimensions on image_tag helper
#activate :automatic_image_sizes

# Integrate Dotenv
#activate :dotenv

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

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

  # Enable pagination
  # blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/{num}"
end

# Build-specific configuration
configure :build do
  # Minify CSS on build
  activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript
end

activate :s3_sync do |s3_sync|
  s3_sync.bucket         = 'www.whalecore.com'
  s3_sync.region         = 'us-west-1'
  s3_sync.after_build    = true # sync after building
  s3_sync.index_document = 'index.html'
  s3_sync.error_document = '404.html'
end

activate :google_analytics do |ga|
  ga.tracking_id = 'UA-106768329-1'
end

###
# Helpers
###

# Methods defined in the helpers block are available in templates
helpers do

  def sidenote(content = nil)
    # auto-magically create incremental CSS ids
    @@sidenote ||= 0
    tag(:label, for: "sn-#{@@sidenote += 1}", class: 'margin-toggle sidenote-number') +
    input_tag(:checkbox, id: "sn-#{@@sidenote}", class: 'margin-toggle') +
    content_tag(:span, class: 'sidenote') { content || yield }
  end

  def marginnote(content = nil)
    # auto-magically create incremental CSS ids
    @@marginnote ||= 0
    icon = '&#8853;' # expand icon looks like: ⊕
    content_tag(:label, for: "mn-#{@@marginnote += 1}", class: 'margin-toggle') { icon } +
    input_tag(:checkbox, id: "mn-#{@@marginnote}", class: 'margin-toggle') +
    content_tag(:span, class: 'marginnote') { content || yield }
  end

  #TODO: maybe some day we will want this to take a block?
  def epigraph(content = nil, footer = nil)
    content_tag(:div, class: 'epigraph') do
      content_tag(:blockquote) do
        if footer
          footer = content_tag(:footer) { footer }
        end
        content_tag(:p) do
          content || yield
        end + footer
      end
    end
  end

  # upcase the first few words in a paragraph
  def newthought(content)
    content_tag(:span, class: 'newthought') { content }
  end

  # used for images and other figures
  def figure(img_src, alt_text = '')
    content_tag(:figure) do
      tag(:img, src: img_src, alt: alt_text)
    end
  end

  # take up the whole screen
  def full_figure(img_src, alt_text = '')
    content_tag(:figure, class: 'fullwidth') do
      tag(:img, src: img_src, alt: alt_text)
    end
  end

  def iframe_wrapper
    content_tag(:figure, class: 'iframe-wrapper') { yield }
  end

end

