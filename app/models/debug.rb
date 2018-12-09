class Debug
  def self.finish
    info = <<~DEBUG

      処理を終了します。
      ip: #{Scraping.my_ip}
      lat: #{$lat}
      lng: #{$lng}
      count: #{$count} / 48279 (#{($count / 48279.0 * 10000).round / 100.0}%)
      Google Maps: https://www.google.co.jp/maps/search/#{$lat},#{$lng}

      DBのレストランの件数: #{Restaurant.count}件
      保存したレストランの件数: #{Restaurant.count - $restaurant_number}件
    DEBUG
    puts info
    SlackNotify.notify info
  end

  def self.complete
    info = <<~DEBUG

      領域内のクローリングが全て完了しました！！！。
      lat: #{$lat}
      lng: #{$lng}
      Google Maps: https://www.google.co.jp/maps/search/#{$lat},#{$lng}
      count: #{$count} / 48279 (#{($count / 48279.0 * 10000).round / 100.0}%)
      DBのレストランの件数: #{Restaurant.count}
    DEBUG
    puts info
    SlackNotify.notify info
  end

end
