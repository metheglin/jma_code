
module JMACode
  using Blank

  class AreaInformationCity < Struct.new(
    :code, :name, :alt_name, :alt_name_phonetic,
    :area_forecast_local_code, :used_by,
    keyword_init: true
  )
    HEADERS = %i(
      code
      name
      name_used_by_weather
      name_phonetic_used_by_weather
      area_forecast_local_code
      used_by_weather_alert
      used_by_tornado_alert
      used_by_long_surge_alert
      used_by_short_surge_alert
      used_by_landslide_alert
      used_by_flood_alert
      name_used_by_earthquake
      name_phonetic_used_by_earthquake
      name_used_by_volcano
      name_phonetic_used_by_volcano
      name_used_by_uv
      name_phonetic_used_by_uv
      name_used_by_rainstorm_alert
      name_phonetic_used_by_rainstorm_alert
    )

    class << self
      attr_accessor :area_forecast_locals

      def load_20240216(&block)
        path = File.join(File.dirname(__FILE__), "../../data/20240216_AreaInformationCity-AreaForecastLocalM/AreaInformationCity.csv")
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
        list = []
        csv.each.with_index do |row, i|
          next if i < num_headers
          list << build_by_csv_row(row)
        end
        list
      end

      def build_by_csv_row(row)
        alt_name, alt_name_phonetic = if row[:name_used_by_weather].present?
          [row[:name_used_by_weather], row[:name_phonetic_used_by_weather]]
        elsif row[:name_used_by_earthquake].present?
          [row[:name_used_by_earthquake], row[:name_phonetic_used_by_earthquake]]
        elsif row[:name_used_by_volcano].present?
          [row[:name_used_by_volcano], row[:name_phonetic_used_by_volcano]]
        elsif row[:name_used_by_uv].present?
          [row[:name_used_by_uv], row[:name_phonetic_used_by_uv]]
        elsif row[:name_used_by_rainstorm_alert].present?
          [row[:name_used_by_rainstorm_alert], row[:name_phonetic_used_by_rainstorm_alert]]
        else
          []
        end

        new(
          code: row[:code], 
          name: row[:name], 
          alt_name: alt_name,
          alt_name_phonetic: alt_name_phonetic,
          area_forecast_local_code: row[:area_forecast_local_code],
          used_by: [
            row[:used_by_weather_alert] == '1' ? :weather_alert : nil,
            row[:used_by_tornado_alert] == '1' ? :tornado_alert : nil,
            row[:used_by_long_surge_alert] == '1' ? :long_surge_alert : nil,
            row[:used_by_short_surge_alert] == '1' ? :short_surge_alert : nil,
            row[:used_by_landslide_alert] == '1' ? :landslide_alert : nil,
            row[:used_by_flood_alert] == '1' ? :flood_alert : nil,
            row[:name_used_by_earthquake].present? ? :earthquake : nil,
            row[:name_used_by_volcano].present? ? :volcano : nil,
            row[:name_used_by_uv].present? ? :uv : nil,
            row[:name_used_by_rainstorm_alert].present? ? :rainstorm_alert : nil,
          ].compact
        )
      end
    end

    def area_forecast_local
      @area_forecast_local ||= (self.class.area_forecast_locals || []).find{|x| x.code == area_forecast_local_code}
    end
  end
end
