require 'open-uri'

class CrawlingController < ApplicationController

  def foursquare
    Thread.start do
      Scraping.set_global_variable params
      msg = <<~DEBUG

        クローリングを開始します
        ip: #{Scraping.my_ip}
        lat: #{$lat}
        lng: #{$lng}
        count: #{$count} / 48279 (#{($count / 48279.0 * 10000).round / 100.0}%)
        Google Maps: https://www.google.co.jp/maps/search/#{$lat},#{$lng}

        DBのレストランの件数: #{$restaurant_number}
      DEBUG

      Slack.notify msg
      puts msg
      Main.start_crawling
    end
    render status: 402, json: { status: 402, message: 'Accepted' }
  end

end
