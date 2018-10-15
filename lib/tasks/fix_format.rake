namespace :fix_format do
  desc "レストランのphoneのカラムを整える"
  task :restaurant_phone => :environment do
    Restaurant.where.not(phone: nil).each do |res|
      res.update! phone: "0#{res.phone[3..-1]}"
    end
  end

  desc "レストランのaddressのカラムを整える"
  task :restaurant_address => :environment do
    Restaurant.where.not(address: nil).each do |res|
      res.update! address: res.address.delete('[').delete(']')
        .delete('"').split(', ')[0..-2].reverse.join(' ')
    end
  end

  desc "レストランの写真のカラムを整える"
  task :restaurant_picture => :environment do
    RestaurantPicture.all.each do |picture|
      splitted = picture.picture.split '/'
      picture.update!({
        prefix: splitted[0..4].join('/'),
        suffix: splitted[6]
      })
    end
  end

  desc "prefixとsuffixに/を足す"
  task :add_slash => :environment do
    pictures = RestaurantPicture.all
    pictures.each do |picture|
      picture.update!({
        prefix: "#{picture.prefix}/",
        suffix: "/#{picture.suffix}"
      })
    end
  end

end
