class Main
  def self.start_crawling
    restaurant_category_id = '4d4b7105d754a06374d81259,4bf58dd8d48988d116941735'
    params = {
      ll: "#{$lat},#{$lng}",
      limit: 50,
      radius: 50,
      categoryId: restaurant_category_id
    }

    response_code, response_body, get_restaurants_num, error_api = Restaurant.get_from_foursquare params

    if response_code == 429
      info = <<~DEBUG

        #{$account_num}つ目のfoursquare (Api Key: #{$client_secret})の回数上限に達しました。
        ip: #{Scraping.my_ip}
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
      DEBUG

      puts info
      SlackNotify.notify info
      return Debug.finish unless $account_num < $crawling_ids.length

      $account_num += 1
      $client_id = $crawling_ids[$account_num-1]
      $client_secret = $crawling_secrets[$account_num-1]
    elsif response_code != 200
      info = <<-DEBUG

        foursquareからエラーが返ってきました。
        処理は続行しています。
        lat: #{$lat}
        lng: #{$lng}
        ip: #{Scraping.my_ip}
        count: #{$count} / 48279 (#{($count / 48279.0 * 10000).round / 100.0}%)
        DBのレストランの件数: #{Restaurant.count}
        一番最後に保存したレストラン: #{Restaurant.last.attributes}
        response_code: #{response_code}
        response_body: #{response_body}
        errorが起きたapi: #{error_api}
      DEBUG

      puts info
      SlackNotify.notify info
      $error_count += 1
      if $error_count > 3
        return Debug.finish unless $account_num < $crawling_ids.length

        $account_num += 1
        $client_id = $crawling_ids[$account_num - 1]
        $client_secret = $crawling_secrets[$account_num - 1]
      end
    else
      puts "保存したレストランの件数: #{get_restaurants_num}, lat: #{$lat}, lng: #{$lng}, count: #{$count} (#{($count / 48279.0 * 10000).round / 100.0}%)"
      south_end = 35.582135
      east_end = 139.811738
      lat_step = 0.00090128  # 100m
      lng_step = 0.00055278  # 50m
      initial_lat = 35.745434

      if $lat < south_end
        return Debug.complete if $lng > east_end

        puts <<-DEBUG

            改行します
            lat: #{$lat}
            lng: #{$lng}
            count: #{$count} / 48279 (#{($count / 48279.0 * 10000).round / 100.0}%)

            DBのレストランの件数: #{Restaurant.count}
        DEBUG
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
    start_crawling
  end

  def self.update_params
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

end
