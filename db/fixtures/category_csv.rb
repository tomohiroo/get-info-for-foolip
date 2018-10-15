require 'csv'

csv = CSV.read('db/fixtures/category.csv')
csv.each do |category|
  Category.seed(:foursquare_id) do |s|
    s.foursquare_id = category[0]
    s.name = category[1]
    s.short_name = category[2]
    s.roman = category[3]
  end unless Category.find_by foursquare_id: category[0]
end
