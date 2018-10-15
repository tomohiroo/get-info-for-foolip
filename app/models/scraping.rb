require "open-uri"

class Scraping

  def self.get_info_from_instagram url
    Selenium::WebDriver::Chrome.driver_path = "/usr/local/bin/chromedriver"
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    driver = Selenium::WebDriver.for :chrome, options: options
    driver.navigate.to url
    driver.navigate.to driver.find_element(:xpath, '//*[@id="react-root"]/section/main/div/div/article/header/div[2]/div[2]/a')
      .attribute('href')
    name = driver.find_element(:xpath, '//*[@id="react-root"]/section/main/article/header/div[2]/h1')
      .text.tr('０-９ａ-ｚＡ-Ｚ　', '0-9a-zA-Z ')
    meta_tags = driver.find_elements(:tag_name, 'meta')
    meta_tags.each do |meta|
      @lat = meta.attribute('content') if meta.attribute('property') == 'place:location:latitude'
      @lng = meta.attribute('content') if meta.attribute('property') == 'place:location:longitude'
    end
    driver.quit
    return "#{@lat},#{@lng}", name
  end

  def self.get_info_from_tabelog url
    if URI.parse(url).host == "s.tabelog.com"
      uri = URI.parse(url)
      uri.host = "tabelog.com"
      url = uri.to_s
    end
    splitted = url.split "/"
    url = (splitted[0..2] + splitted[4..-1]).join("/") if splitted[3] == "en"
    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    ll = Rack::Utils.parse_nested_query(URI.parse(doc.css('.rstinfo-table__map.js-catalyst-rstinfo-map > a > img').to_a[0].attributes["data-original"].value).query)["center"]
    name = doc.xpath('//*[@id="rstdtl-head"]/div[1]/section/div[1]/div[1]/div/h2/span')[0].inner_text.gsub(/\n| {3,}/, "").tr('０-９ａ-ｚＡ-Ｚ　', '0-9a-zA-Z ')
    return ll, name
  end

end
