require 'open-uri'

class Scraping
  def self.my_ip
    JSON.parse(Faraday.new(url: 'https://jsonip.com').get.body)['ip']
  end

  def self.set_global_variable(params)
    $lat = params[:lat].to_f
    $lng = params[:lng].to_f
    $line_num = params[:line_num].to_i
    $count = params[:count].to_i
    $account_num = 1
    $crawling_ids = []
    $crawling_secrets = []
    ENV['crawling_ids'].split(',').shuffle.each do |ids|
      $crawling_ids.push ids.split(':')[0]
      $crawling_secrets.push ids.split(':')[1]
    end
    $client_id = $crawling_ids[$account_num-1]
    $client_secret = $crawling_secrets[$account_num-1]
    $error_count = 0
    $restaurant_number = Restaurant.count
  end

  def format_tabelog_url(url)
    uri = URI.parse(url)
    uri.host = 'tabelog.com' if uri.host == 's.tabelog.com'
    uri.query = nil
    uri.to_s
  end
end
