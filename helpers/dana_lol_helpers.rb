require 'json'

# Methods defined in the helpers block are available in templates
module DanaLolHelpers

  # upcase the first few words in a paragraph
  def newthought(content)
    content_tag(:span, class: 'newthought') { content }
  end
  alias_method :nt, :newthought

  # Resolve a bare filename against the current article's URL. Absolute paths
  # (leading /), full URLs (http(s)://), and data: URIs pass through unchanged.
  def article_image_path(img_src)
    return img_src if img_src.start_with?('/', 'http://', 'https://', 'data:')
    "#{current_article.url}#{img_src}"
  end

  def linked_image(img_src, alt_text = '')
    src = article_image_path(img_src)
    link_to(image_tag(src, alt: alt_text), remove_file_extension(src), class: 'no-underline')
  end

  # used for images and other figures
  def figure(img_src, alt_text = '', note: nil)
    content_tag(:figure) do
      body = linked_image(img_src, alt_text)
      body += marginnote(note) if note
      body
    end
  end
  alias_method :f, :figure

  # take up the whole screen
  def full_figure(img_src, alt_text = '', note: nil)
    content_tag(:figure, class: 'fullwidth') do
      body = linked_image(img_src, alt_text)
      body += marginnote(note) if note
      body
    end
  end
  alias_method :ff, :full_figure

  # used for images and other figures that link to somewhere specific
  def linked_figure(img_src, link, alt_text = '', note: nil)
    content_tag(:figure) do
      body = link_to(image_tag(article_image_path(img_src), alt: alt_text), link, class: 'no-underline')
      body += marginnote(note) if note
      body
    end
  end

  # used for images and other figures that have no link
  def nolink_figure(img_src, alt_text = '', note: nil)
    content_tag(:figure) do
      body = image_tag(article_image_path(img_src), alt: alt_text)
      body += marginnote(note) if note
      body
    end
  end

  # used for images and other figures that have no link
  def nolink_full_figure(img_src, alt_text = '', note: nil)
    content_tag(:figure, class: 'fullwidth') do
      body = image_tag(article_image_path(img_src), alt: alt_text)
      body += marginnote(note) if note
      body
    end
  end

  def iframe_wrapper
    content_tag(:figure, class: 'iframe-wrapper') { yield }
  end

  def twitch_channel
    ENV['STAGING'] == 'true' ? 'adanalife_staging' : 'adanalife_'
  end

  def sidenote(content = nil)
    # auto-magically create incremental CSS ids
    @@sidenote ||= 0
    tag(:label, for: "sn-#{@@sidenote += 1}", class: 'margin-toggle sidenote-number') +
    input_tag(:checkbox, id: "sn-#{@@sidenote}", class: 'margin-toggle') +
    content_tag(:span, class: 'sidenote') { content || yield }
  end
  alias_method :sn, :sidenote

  def marginnote(content = nil, opts = {})
    # auto-magically create incremental CSS ids
    @@marginnote ||= 0
    icon = opts[:icon] || '&#8853;' # expand icon looks like: ⊕
    content_tag(:label, for: "mn-#{@@marginnote += 1}", class: 'margin-toggle') { icon } +
    input_tag(:checkbox, id: "mn-#{@@marginnote}", class: 'margin-toggle') +
    content_tag(:span, class: 'marginnote') { content || yield }
  end
  alias_method :mn, :marginnote

  # Image inside a margin note, with optional caption and optional link target.
  # Without `link:`, the image links to its own photo landing page (linked_image).
  # With `link:`, the image links to the given URL (Amazon refs, external sites).
  def margin_image(img_src, alt_text = '', caption: nil, link: nil)
    img = if link
      link_to(image_tag(article_image_path(img_src), alt: alt_text), link, class: 'no-underline')
    else
      linked_image(img_src, alt_text)
    end
    marginnote(caption ? img + caption : img)
  end
  alias_method :mi, :margin_image

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
  alias_method :quote, :epigraph

  def summary(article, length = 255)
    summed = article.summary(length, 'ENDART').sub(/ENDART/, link_to('...', article))
    # make it so clicking an image inside a summary goes to the article and not the image
    doc = Nokogiri::HTML.fragment(summed)
    doc.css('figure').each do |figure|
      figure.css('a').attribute('href').value = article.url
    end
    doc.to_s
  end

  def remove_file_extension(path)
    path.sub(/#{File.extname(path)}$/, '')
  end

  # Site root without a trailing slash (data.settings.site.url has one).
  def site_root
    data.settings.site.url.chomp('/')
  end

  # Safely dig into the current page's `ogp:` front matter, e.g.
  # og_dig('og', 'description') or og_dig('og', 'image', '') for the secure_url.
  def og_dig(*keys)
    node = current_page.data['ogp']
    keys.each do |key|
      return nil unless node.respond_to?(:[])
      node = node[key]
    end
    node
  end

  # Build the schema.org structured-data graph for the current page. Every page
  # gets the WebSite + Person nodes (referenced by @id so they aren't duplicated);
  # article pages additionally get a BlogPosting node linked back to both.
  def json_ld_data
    person_id  = "#{site_root}/#person"
    website_id = "#{site_root}/#website"

    graph = [
      {
        '@type'     => 'WebSite',
        '@id'       => website_id,
        'url'       => "#{site_root}/",
        'name'      => data.settings.site.title,
        'inLanguage' => 'en',
        'publisher' => { '@id' => person_id }
      },
      {
        '@type'  => 'Person',
        '@id'    => person_id,
        'name'   => 'Dana',
        'url'    => "#{site_root}/about",
        'image'  => "#{site_root}/about/dana.jpg",
        'sameAs' => [
          'https://www.twitch.tv/adanalife_',
          'https://twitter.com/adanalife_',
          'https://instagram.com/adanalife_',
          'https://github.com/dmerrick'
        ]
      }
    ]

    if current_article
      url = "#{site_root}#{current_article.url}"
      posting = {
        '@type'            => 'BlogPosting',
        '@id'              => "#{url}#article",
        'headline'         => current_article.title,
        'url'              => url,
        'datePublished'    => current_article.date.strftime('%Y-%m-%d'),
        'author'           => { '@id' => person_id },
        'publisher'        => { '@id' => person_id },
        'isPartOf'         => { '@id' => website_id },
        'mainEntityOfPage' => { '@type' => 'WebPage', '@id' => url }
      }
      if (description = og_dig('og', 'description'))
        posting['description'] = description
      end
      if (image = og_dig('og', 'image', '') || og_dig('og', 'image'))
        posting['image'] = image
      end
      if (tags = current_article.tags) && tags.any?
        posting['keywords'] = tags.join(', ')
      end
      graph << posting
    end

    { '@context' => 'https://schema.org', '@graph' => graph }
  end

  # JSON-LD string for the <script type="application/ld+json"> tag. The angle
  # brackets and ampersand are escaped to their \uXXXX forms so a value can
  # never break out of the <script> element (e.g. a literal </script>).
  def json_ld
    JSON.generate(json_ld_data)
      .gsub('<', '\\u003c')
      .gsub('>', '\\u003e')
      .gsub('&', '\\u0026')
      .html_safe
  end

end
