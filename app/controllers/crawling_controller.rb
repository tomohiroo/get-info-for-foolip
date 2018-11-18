require 'open-uri'
class CrawlingController < ApplicationController

  def get_ip
    JSON.parse(Faraday.new(url: 'https://jsonip.com').get.body)["ip"]
  end

  def foursquare
    Thread.start do
      set_global_variable params
      msg = <<-EOC

クローリングを開始します
ip: #{get_ip}
lat: #{$lat}
lng: #{$lng}
count: #{$count} / 48279 (#{($count / 48279.0 * 10000).round / 100.0}%)
Google Maps: https://www.google.co.jp/maps/search/#{$lat},#{$lng}

DBのレストランの件数: #{$restaurant_number}
      EOC

      slack_notify msg
      puts msg
      main
    end
    render status: 402, json: { status: 402, message: 'Accepted' }
  end

  DOMAIN = 'https://api.foursquare.com/v2'

  private

    def set_global_variable(params)
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

    def search(params)
      conn = Faraday.new url: "#{DOMAIN}/venues/search"
      conn.get do |req|
        req.params[:client_id] = $client_id
        req.params[:client_secret] = $client_secret
        req.params[:v] = ENV['foursquare_version']
        req.params[:locale] = 'ja'
        req.params[:intent] = 'browse'
        req.params[:ll] = params[:ll]
        req.params[:limit] = params[:limit]
        req.params[:radius] = params[:radius]
        req.params[:categoryId] = params[:categoryId]
      end
    end

    def get_details(ids)
      restaurant_hashes = []
      ids.each do |id|
        conn = Faraday.new url: "#{DOMAIN}/venues/#{id}"
        response = conn.get do |req|
          req.params[:client_id] = $client_id
          req.params[:client_secret] = $client_secret
          req.params[:v] = ENV['foursquare_version']
          req.params[:locale] = 'ja'
        end
        status = JSON.parse(response.body)['meta']['code']
        return status if status == 429

        venue = JSON.parse(response.body)['response']['venue']
        if venue.blank? || venue['id'].blank?
          msg = "venueがnilのerrorが起きました。venue: #{venue}\nresponse_code: #{status}\nbody: #{JSON.parse(response.body)}\n\nresponse: #{response}"
          slack_notify "<!tomohiro_ueda>\n#{msg}"
          puts msg
        end
        new_restaurant, category, pictures, station = Restaurant.build_with_foursquare_hash venue
        detail = new_restaurant.attributes
        detail[:category] = category
        detail[:pictures] = pictures
        detail[:station] = station
        restaurant_hashes << { restaurant: new_restaurant, detail: detail }
        sleep 3
      end
      restaurant_hashes
    end

    def get_restaurants(params)
      response = search params
      return response.status, response.body, 0, 'search api' if response.status != 200

      foursquare_ids = JSON.parse(response.body)['response']['venues'].map { |h| h['id'] }
      return 200, nil, 0, '' if foursquare_ids.blank?

      db_foursquare_ids = Restaurant.where(foursquare_id: foursquare_ids).select(:foursquare_id).map(&:foursquare_id)
      new_restaurants_foursquare_ids = foursquare_ids.select { |id| db_foursquare_ids.exclude? id }
      new_restaurants_hash = get_details new_restaurants_foursquare_ids
      return 429, new_restaurants_hash, 0, 'detail api' if new_restaurants_hash == 429

      Restaurant.import new_restaurants_hash.map { |h| h[:restaurant] }, recursive: true, validate: false
      return 200, nil, new_restaurants_foursquare_ids.length, ''
    end

    def update_params
      conn = Faraday.new url: 'https://foolip.net/crawling'
      conn.patch do |req|
        req.headers['Content-Type'] = 'application/json'
        req.headers['Authorization'] = "Bearer #{ENV['access_token']}"
        req.params[:lat] = $lat
        req.params[:lng] = $lng
        req.params[:line_num] = $line_num
        req.params[:count] = $count
      end
    end

    def finishing_processing
      info = <<-EOC

処理を終了します。
ip: #{get_ip}
lat: #{$lat}
lng: #{$lng}
count: #{$count} / 48279 (#{($count / 48279.0 * 10000).round / 100.0}%)
Google Maps: https://www.google.co.jp/maps/search/#{$lat},#{$lng}

DBのレストランの件数: #{Restaurant.count}件
保存したレストランの件数: #{Restaurant.count - $restaurant_number}件
      EOC
      puts info
      slack_notify info
    end

    def complete_processing
      info = <<-EOC

<!channel>
領域内のクローリングが全て完了しました！！！。
lat: #{$lat}
lng: #{$lng}
Google Maps: https://www.google.co.jp/maps/search/#{$lat},#{$lng}
count: #{$count} / 48279 (#{($count / 48279.0 * 10000).round / 100.0}%)
DBのレストランの件数: #{Restaurant.count}
      EOC
      puts info
      slack_notify info
    end

    def slack_notify info
      slack_webhook_url = ENV['slack_webhook_url']
      notifier = Slack::Notifier.new slack_webhook_url do
        defaults username: "クローリングマン"
      end
      notifier.post(
        text: "```【#{Rails.env}】\n#{info}```",
        icon_url: 'https://t14.pimg.jp/030/224/824/1/30224824.jpg'
      )
    end

    def main
      restaurant_category_id = '4d4b7105d754a06374d81259,4bf58dd8d48988d116941735'
      params = {
        ll: "#{$lat},#{$lng}",
        limit: 50,
        radius: 50,
        categoryId: "#{restaurant_category_id}"
      }

      response_code, response_body, get_restaurants_num, error_api = get_restaurants params

      if response_code == 429
        info = <<-EOC

#{$account_num}つ目のfoursquare (apikey: #{$client_secret})の回数上限に達しました。
ip: #{get_ip}
lat: #{$lat}
lng: #{$lng}
response_code: #{response_code}
response_body: #{response_body}
errorが起きたapi: #{error_api}
保存したレストランの件数: #{get_restaurants_num}
DBのレストランの件数: #{Restaurant.count}
lat: #{$lat}
lng: #{$lng}
Google Maps: https://www.google.co.jp/maps/search/#{$lat},#{$lng}
count: #{$count} / 48279 (#{($count / 48279.0 * 10000).round / 100.0}%)
        EOC

        puts info
        slack_notify info
        return finishing_processing unless $account_num < $crawling_ids.length
        $account_num += 1
        $client_id = $crawling_ids[$account_num-1]
        $client_secret = $crawling_secrets[$account_num-1]
      elsif response_code != 200
        info = <<-EOC

foursquareからエラーが返ってきました。
処理は続行しています。
lat: #{$lat}
lng: #{$lng}
ip: #{get_ip}
count: #{$count} / 48279 (#{($count / 48279.0 * 10000).round / 100.0}%)
DBのレストランの件数: #{Restaurant.count}
一番最後に保存したレストラン: #{Restaurant.last.attributes}
response_code: #{response_code}
response_body: #{response_body}
errorが起きたapi: #{error_api}
        EOC

        puts info
        slack_notify info
        $error_count += 1
        if $error_count > 3
          return finishing_processing unless $account_num < $crawling_ids.length

          $account_num += 1
          $client_id = $crawling_ids[$account_num-1]
          $client_secret = $crawling_secrets[$account_num-1]
        end
      else
        puts " 保存したレストランの件数: #{get_restaurants_num}, lat: #{$lat}, lng: #{$lng}, count: #{$count} (#{($count / 48279.0 * 10000).round / 100.0}%)"
        south_end = 35.582135
        east_end = 139.811738
        lat_step = 0.00090128  # 100m
        lng_step = 0.00055278  # 50m
        initial_lat = 35.745434

        if $lat < south_end
          if $lng > east_end
            return complete_processing
          end

          puts <<-EOC

改行します
lat: #{$lat}
lng: #{$lng}
count: #{$count} / 48279 (#{($count / 48279.0 * 10000).round / 100.0}%)

DBのレストランの件数: #{Restaurant.count}
          EOC
          $lng += lng_step
          $line_num += 1
          $lat = $line_num.odd? ? initial_lat : initial_lat - lat_step / 2
        else
          $lat -= lat_step
        end

        $count += 1
        update_params
      end

      sleep rand(10)
      main
    end

end
