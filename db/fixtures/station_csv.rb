require 'csv'

csv = CSV.read('db/fixtures/station.csv')
csv.each.with_index(1) do |station, i|
  Station.seed do |s|
    s.id = i
    s.name = station[0]
    s.roman = station[1]
    s.lng = station[2]
    s.lat = station[3]
    s.prefecture = station[4]
  end
end
