require "csv"

module JMACode
  class WmoObservingStation < Struct.new(
    :code, :name, :name_phonetic, :long_name, :lat, :lng, :used_by,
    keyword_init: true
  )
    HEADERS = %i(
      code 
      name 
      name_phonetic
      lat_major
      lat_minor
      lng_major
      lng_minor
      long_name
      used_by_bioseasonal
      used_by_seasonal
      used_by_special
      name_used_by_uv
      name_used_by_marine_live_forecast
      name_used_by_flood_forecast
      name_used_by_weather
    )

    class << self
      def load_20201026(&block)
        path = File.join(File.dirname(__FILE__), "../../data/20201026_WmoObservingStations.csv")
        File.open(path) do |f|
          csv = CSV.new(f, headers: HEADERS, row_sep: "\r\n")
          if block_given?
            yield(csv)
          else
            load(csv, num_headers: 3, &block)
          end
        end
      end

      def load(csv, num_headers: 3)
        csv.drop(num_headers).map do |row|
          build_by_csv_row(row)
        end
      end

      def build_by_csv_row(row)
        new(
          code: row[:code], 
          name: row[:name], 
          name_phonetic: row[:name_phonetic],
          lat: "#{row[:lat_major]}.#{row[:lat_minor]}".to_f,
          lng: "#{row[:lng_major]}.#{row[:lng_minor]}".to_f,
          long_name: row[:long_name],
          used_by: [
            row[:used_by_bioseasonal] && !row[:used_by_bioseasonal].empty? ? :bioseasonal : nil,
            row[:used_by_seasonal] && !row[:used_by_seasonal].empty? ? :seasonal : nil,
            row[:used_by_special] && !row[:used_by_special].empty? ? :special : nil,
            row[:name_used_by_uv] && !row[:name_used_by_uv].empty? ? :uv : nil,
            row[:name_used_by_marine_live_forecast] && !row[:name_used_by_marine_live_forecast].empty? ? :marine_live_forecast : nil,
            row[:name_used_by_flood_forecast] && !row[:name_used_by_flood_forecast].empty? ? :flood_forecast : nil,
            row[:name_used_by_weather] && !row[:name_used_by_weather].empty? ? :weather : nil,
          ].compact,
        )
      end
    end
  end
end
