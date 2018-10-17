# encoding: utf-8
require 'open-uri'

class CrawlingController < ApplicationController

  def foursquare
    log = Logger.new '/home/tomohiroo/pecopeco/shared/log/crawling.log'
    msg = 'クローリングを開始します。'
    slack_notify msg
    log.info msg
    $account_num = 1
    $crawling_ids = ENV['crawling_ids'].split(',')
    $crawling_secrets = ENV['crawling_secrets'].split(',')
    $client_id = $crawling_ids[$account_num-1]
    $client_secret = $crawling_secrets[$account_num-1]
    main log
  end

  DOMAIN = "https://api.foursquare.com/v2"

  private

    def search params
      conn = Faraday.new url: "#{DOMAIN}/venues/search"
      conn.get do |req|
        req.params[:client_id] = $client_id
        req.params[:client_secret] = $client_secret
        req.params[:v] = ENV['foursquare_version']
        req.params[:locale] = "ja"
        req.params[:intent] = "browse"
        req.params[:ll] = params[:ll]
        req.params[:limit] = params[:limit]
        req.params[:radius] = params[:radius]
        req.params[:categoryId] = params[:categoryId]
      end
    end

    def get_details ids
      restaurant_hashes = []
      hydra = Typhoeus::Hydra.new
      ids.each do |id|
        request = Typhoeus::Request.new(
          "#{DOMAIN}/venues/#{id}",
          followlocation: true,
          params: {
            client_id: $client_id,
            client_secret: $client_secret,
            v: ENV['foursquare_version'],
            locale: "ja"
          }
        )
        request.on_complete do |response|
          status = JSON.parse(response.body)["meta"]["code"]
          return status if status == 429
          venue = JSON.parse(response.body)["response"]["venue"]
          if venue["id"].blank?
            slack_notify "errorが起きました。"
            slack_notify venue
            log.info venue
          end
          new_restaurant, category, pictures, station = Restaurant.build_with_foursquare_hash venue
          detail = new_restaurant.attributes
          detail[:category] = category
          detail[:pictures] = pictures
          detail[:station] = station
          restaurant_hashes << { restaurant: new_restaurant, detail: detail }
        end
        hydra.queue(request)
      end
      hydra.run
      restaurant_hashes
    end

    def get_restaurants params
      response = search params
      return response.status, response.body, 0, 'search api' if response.status != 200
      foursquare_ids = JSON.parse(response.body)["response"]["venues"].map { |h| h["id"] }
      return 200, nil, 0, '' if foursquare_ids.blank?
      db_foursquare_ids = Restaurant.where(foursquare_id: foursquare_ids).select(:foursquare_id).map(&:foursquare_id)
      new_restaurants_foursquare_ids = foursquare_ids.select { |id| db_foursquare_ids.exclude? id }
      new_restaurants_hash = get_details new_restaurants_foursquare_ids
      return 429, new_restaurants_hash, 0, 'detail api' if new_restaurants_hash == 429
      Restaurant.import new_restaurants_hash.map { |h| h[:restaurant] }, recursive: true, validate: false
      return 200, nil, new_restaurants_foursquare_ids.length, ''
    end

    def finishing_processing log, lat, lng, count
      info = <<-EOC

    ==============================================================
    処理を終了します。
    lat: #{lat}
    lng: #{lng}
    count: #{count} / 48279 (#{(count / 48279.0 * 10000).round / 100.0}%)
    Google Maps: "https://www.google.co.jp/maps/search/#{lat},#{lng}?sa=X&ved=2ahUKEwjvx7jJq4LeAhUIIIgKHSD-CTsQ8gEwAHoECAAQAQ"

    DBのレストランの件数: #{Restaurant.count}
    ==============================================================
      EOC
      log.info info
      slack_notify info
    end

    def complete_processing log, lat, lng, count
      info = <<-EOC

    ==============================================================
    領域内のクローリングが全て完了しました！！！。
    lat: #{lat}
    lng: #{lng}
    Google Maps: "https://www.google.co.jp/maps/search/#{lat},#{lng}?sa=X&ved=2ahUKEwjvx7jJq4LeAhUIIIgKHSD-CTsQ8gEwAHoECAAQAQ"
    count: #{count} / 48279 (#{(count / 48279.0 * 10000).round / 100.0}%)

    DBのレストランの件数: #{Restaurant.count}
    ==============================================================
      EOC
      log.info info
      slack_notify info
    end

    def slack_notify info
      slack_webhook_url = ENV['slack_webhook_url']
      notifier = Slack::Notifier.new slack_webhook_url do
        defaults username: "クローリングマン"
      end
      notifier.post({
        text: "```【#{Rails.env}】\n#{info}```",
        icon_url: 'https://t14.pimg.jp/030/224/824/1/30224824.jpg'
      })
    end

    def main log
      json_file_path = Rails.root.join "public/crawling.json"
      json_data = File.open(json_file_path) { |j| JSON.load j }
      lat = json_data["lat"]
      lng = json_data["lng"]

      restaurant_category_id = '4d4b7105d754a06374d81259,4bf58dd8d48988d116941735'
      params = {
        ll: "#{lat},#{lng}",
        limit: 50,
        radius: 50,
        categoryId: "#{restaurant_category_id}"
      }

      response_code, response_body, get_restaurants_num, error_api = get_restaurants params

      if response_code == 429
        info = <<-EOC

    =========================================================
    foursquare (apikey: #{$client_secret}) の回数上限に達しました。
    lat: #{lat}
    lng: #{lng}
    response_code: #{response_code}
    response_body: #{response_body}
    errorが起きたapi: #{error_api}
    保存したレストランの件数: #{get_restaurants_num}
    DBのレストランの件数: #{Restaurant.count}
    lat: #{lat}
    lng: #{lng}
    count: #{json_data["count"]} / 48279 (#{(json_data["count"] / 48279.0 * 10000).round / 100.0}%)
    =========================================================
        EOC

        log.info info
        slack_notify info
        return finishing_processing log, lat, lng, json_data["count"] unless $account_num < $crawling_ids.length
        $account_num += 1
        $client_id = $crawling_ids[$account_num-1]
        $client_secret = $crawling_secrets[$account_num-1]
      elsif response_code != 200
        info = <<-EOC

    =========================================================
    foursquareからエラーが返ってきました。
    処理は続行しています。
    lat: #{lat}
    lng: #{lng}
    count: #{json_data["count"]} / 48279 (#{(json_data["count"] / 48279.0 * 10000).round / 100.0}%)
    DBのレストランの件数: #{Restaurant.count}
    一番最後に保存したレストラン: #{Restaurant.last.attributes}
    response_code: #{response_code}
    response_body: #{response_body}
    errorが起きたapi: #{error_api}
    =========================================================
        EOC

        log.info info
        slack_notify info
      else
        log.info <<-EOC

    保存したレストランの件数: #{get_restaurants_num}
    lat: #{lat}
    lng: #{lng}
    count: #{json_data["count"]} (#{(json_data["count"] / 48279.0 * 10000).round / 100.0}%)
        EOC
      end
      south_end = 35.582135
      east_end = 139.811738
      lat_step = 0.00090128  # 100m
      lng_step = 0.00055278  # 50m
      initial_lat = 35.745434

      if lat < south_end
        if lng > east_end
          return complete_processing(log, lat, lng, json_data["count"])
        end

        info = <<-EOC

    =========================================================
    改行します
    lat: #{lat}
    lng: #{lng}
    count: #{json_data["count"]} / 48279 (#{(json_data["count"] / 48279.0 * 10000).round / 100.0}%)

    DBのレストランの件数: #{Restaurant.count}
    =========================================================
        EOC

        log.info info
        slack_notify info

        json_data["lng"] += lng_step
        json_data["line_num"] += 1
        if json_data["line_num"].odd?
          json_data["lat"] = initial_lat
        else
          json_data["lat"] = initial_lat - lat_step / 2
        end
      else
        json_data["lat"] -= lat_step
      end

      json_data["count"] += 1
      open(json_file_path, 'w') do |io|
        JSON.dump(json_data, io)
      end

      sleep rand 10
      return finishing_processing log, json_data["lat"], json_data["lng"], json_data["count"]
      main log
    end

end
