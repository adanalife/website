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

  # just a simple way to keep this somewhere central
  def google_analytics
    'UA-106965485-1'
  end

end
