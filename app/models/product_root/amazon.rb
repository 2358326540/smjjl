class ProductRoot::Amazon < ProductRoot
  # extends ...................................................................
  # includes ..................................................................
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  # validations ...............................................................
  # callbacks .................................................................
  # scopes ....................................................................
  # additional config .........................................................
  # class methods .............................................................
  # public instance methods ...................................................
  def get_lists
    page = Nokogiri::HTML(http_get(url))
    links = [] 
    page.css("#shopAllLinks td")[1].css("li li a").each{|a| links << a }
    page.css("#shopAllLinks td")[2].css("div").first.css("li li a").each{|a| links << a }
    links.each do |link|
      url = link.attr("href")
      ProductList::Amazon.create(url: url, url_key: get_key(url)) if get_key(url)
    end
  rescue
    $crawler_log.info("#{self.class}|#{__method__}|#{self.id} >> #{$!}")
  end

  # protected instance methods ................................................
  # private instance methods ..................................................
  # private
  def get_key url
    keys = url.scan(%r|node=(\d+)|).first || url.scan(%r|\%3A(\d+)|).last || []
    keys.first
  end
end