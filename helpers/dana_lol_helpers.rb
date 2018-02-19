# Methods defined in the helpers block are available in templates
module DanaLolHelpers

  # upcase the first few words in a paragraph
  def newthought(content)
    content_tag(:span, class: 'newthought') { content }
  end
  alias_method :nt, :newthought

  def linked_image(img_src, alt_text = '')
    link_to(tag(:img, src: img_src, alt: alt_text), img_src, class: 'no-underline')
  end

  # used for images and other figures
  def figure(img_src, alt_text = '')
    content_tag(:figure) do
      link_to(tag(:img, src: img_src, alt: alt_text), img_src, class: 'no-underline')
    end
  end
  alias_method :f, :figure

  # take up the whole screen
  def full_figure(img_src, alt_text = '')
    content_tag(:figure, class: 'fullwidth') do
      link_to(tag(:img, src: img_src, alt: alt_text), img_src, class: 'no-underline')
    end
  end
  alias_method :ff, :full_figure

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

  def summary(article, length = 255)
    article.summary(length, 'ENDART').sub(/ENDART/, link_to('...', article))
  end

  # just a simple way to keep this somewhere central
  def google_analytics
    'UA-106965485-1'
  end

end

