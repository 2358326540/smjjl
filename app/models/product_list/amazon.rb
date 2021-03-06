class ProductList::Amazon < ProductList
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
  def list_url
    "http://www.amazon.cn/s?rh=n%3A#{url_key}"
  end

  # 获取分页的初始页
  def get_pagination(category = "id")
    total_page = (Nokogiri::HTML(http_get("http://www.amazon.cn/s/ref=?rh=n%3A#{url_key}&page=1&sort=-launch-date")).css("#resultCount").text.gsub(",", "").scan(%r|共(\d+)|).first.first.to_i / 24 + 1) rescue 1
    1.upto total_page do |page_num|
      # 亚马逊系统不支持分页大于400的情况
      break if page_num > 400
      GetIdWorker.perform_async(id, page_num) if category == "id"
      UpdateListPriceWorker.perform_async(id, page_num) if category == "price"
    end
  end

  # 在列表中获取product id
  def get_product_ids(page_num)
    page_url = "http://www.amazon.cn/s?rh=n%3A#{url_key}&page=#{page_num}"
    Nokogiri::HTML(http_get(page_url)).css("#rightResultsATF .prod").each do |div|
      Product::Amazon.create(url_key: div.attr("name")) if div.attr("name")
    end
  end

  # 从列表中更新价格(包括价格、名称、销量和分数)
  def get_list_prices(page_num)
    page_url = "http://www.amazon.cn/s?rh=n%3A#{url_key}&page=#{page_num}"
    Nokogiri::HTML(http_get(page_url)).css("#rightResultsATF .prod").each do |div|
      next unless product = Product::Amazon.where(url_key: div.attr("name").strip).first
      name = div.css(".newaps span").text.strip rescue nil
      # 如果名称发生巨大变化，则证明原商品已被替换，进行下架处理
      if product.name.blank? || (name && product.name.similar(name) > 85)
        product.name = name
        product.count = div.css(".rvwCnt a").text.scan(%r|\d+|).first
        product.score = div.css(".rvwCnt a").attr("alt").text.scan(%r|[\d\.]+|).first rescue nil
        product.save
        product.record_price div.css(".newp span").text.gsub("\s", "").scan(%r|[\d\.]+|).first
      else
        product.update_columns(url_key: nil, url: nil, is_discontinued: true)
      end
    end
  end

  # protected instance methods ................................................
  # private instance methods ..................................................
end
