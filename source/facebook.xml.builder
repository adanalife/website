xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  site_url = "https://www.dana.lol"
  xml.title page_title
  #xml.subtitle "Blog subtitle"
  xml.id URI.join(site_url, blog.options.prefix.to_s)
  xml.link "href" => URI.join(site_url, blog.options.prefix.to_s)
  xml.link "href" => URI.join(site_url, current_page.path), "rel" => "self"
  xml.updated(blog.articles.first.date.to_time.iso8601) unless blog.articles.empty?
  xml.author { xml.name "Dana" }

  blog.articles[0..5].each do |article|
    xml.item do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => URI.join(site_url, article.url)
      xml.content.encoded article.body, "type" => "html"
      #xml.id URI.join(site_url, article.url)
      xml.pubdate article.date.to_time.iso8601
      #xml.updated File.mtime(article.source_file).iso8601
      xml.author { xml.name "Dana" }
    end
  end
end
