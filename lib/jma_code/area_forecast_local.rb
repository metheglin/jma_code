
module JMACode
  using Blank

  class AreaForecastLocal < Struct.new(
    :code, :name, :name_phonetic, :used_by,
    keyword_init: true
  )
    CSV_ROW_SEP = "\r\n"
    NUM_HEADER_ROWS = 4
    HEADERS = %i(
      code
      name
      name_phonetic
      used_by_area_forecast_type3_in_weather_alert
      used_by_area_forecast_type2_in_weather_alert
      used_by_area_forecast_type1_in_weather_alert
      used_by_weather_forecast
      used_by_weather_description
      used_by_next_weather_forecast
      used_by_landslide_alert
      used_by_area_forecast_type3_in_tornado_alert
      used_by_area_forecast_type2_in_tornado_alert
      used_by_area_forecast_type1_in_tornado_alert
      used_by_recorded_heavy_rain_alert
      used_by_flood_alert
      used_by_area_forecast_type3_in_typhoon_probability
      used_by_area_forecast_type1_in_typhoon_probability
    )

    class << self
      attr_accessor :data

      def load_csv(version: "20240216")
        path = File.join(File.dirname(__FILE__), "../../data/#{version}_AreaInformationCity-AreaForecastLocalM/AreaForecastLocalM（コード表）.csv")
        File.open(path) do |f|
          csv = CSV.new(f, headers: HEADERS, row_sep: CSV_ROW_SEP)
          yield(csv)
        end
      end

      def load(**args)
        load_csv(**args) do |csv|
          csv.drop(NUM_HEADER_ROWS).map do |row|
            build_by_csv_row(row)
          end
        end
      end

      def get
        @data ||= load
      end

      def build_by_csv_row(row)
        used_by_fields = HEADERS.select{|n| n.to_s.start_with?('used_by_')}

        new(
          code: row[:code], 
          name: row[:name], 
          name_phonetic: row[:name_phonetic],
          used_by: used_by_fields.select{|f| row[f] == '1'}.map{|f| f.to_s.sub(/\Aused_by_/, '').to_sym}
        )
      end
    end

    def area_information_cities
      @area_information_cities ||= AreaInformationCity.get.select{|x| x.area_forecast_local_code == code}
    end
  end
end
