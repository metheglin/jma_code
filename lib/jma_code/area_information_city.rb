
module JMACode
  using Blank

  class AreaInformationCity < Struct.new(
    :code, :name, :alt_name, :alt_name_phonetic,
    :area_forecast_local_code, :used_by,
    keyword_init: true
  )
    CSV_ROW_SEP = "\r\n"
    NUM_HEADER_ROWS = 3
    HEADERS = %i(
      code
      name
      name_used_by_weather
      name_phonetic_used_by_weather
      area_forecast_local_code
      used_by_weather
      used_by_tornado
      used_by_storm_surge
      used_by_high_wave
      used_by_landslide
      used_by_flood
      name_used_by_earthquake
      name_phonetic_used_by_earthquake
      name_used_by_volcano
      name_phonetic_used_by_volcano
      name_used_by_uv
      name_phonetic_used_by_uv
      name_used_by_rainstorm
      name_phonetic_used_by_rainstorm
    )

    class << self
      attr_accessor :data

      def load_csv(version: "20240216")
        path = File.join(File.dirname(__FILE__), "../../data/#{version}_AreaInformationCity-AreaForecastLocalM/AreaInformationCity.csv")
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
        alt_name, alt_name_phonetic = if row[:name_used_by_weather].present?
          [row[:name_used_by_weather], row[:name_phonetic_used_by_weather]]
        elsif row[:name_used_by_earthquake].present?
          [row[:name_used_by_earthquake], row[:name_phonetic_used_by_earthquake]]
        elsif row[:name_used_by_volcano].present?
          [row[:name_used_by_volcano], row[:name_phonetic_used_by_volcano]]
        elsif row[:name_used_by_uv].present?
          [row[:name_used_by_uv], row[:name_phonetic_used_by_uv]]
        elsif row[:name_used_by_rainstorm].present?
          [row[:name_used_by_rainstorm], row[:name_phonetic_used_by_rainstorm]]
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
            row[:used_by_weather] == '1' ? :weather : nil,
            row[:used_by_tornado] == '1' ? :tornado : nil,
            row[:used_by_storm_surge] == '1' ? :storm_surge : nil,
            row[:used_by_high_wave] == '1' ? :high_wave : nil,
            row[:used_by_landslide] == '1' ? :landslide : nil,
            row[:used_by_flood] == '1' ? :flood : nil,
            row[:name_used_by_earthquake].present? ? :earthquake : nil,
            row[:name_used_by_volcano].present? ? :volcano : nil,
            row[:name_used_by_uv].present? ? :uv : nil,
            row[:name_used_by_rainstorm].present? ? :rainstorm : nil,
          ].compact
        )
      end
    end

    def prefecture_code
      @prefecture_code ||= code[0, 2]
    end

    def area_forecast_local
      @area_forecast_local ||= AreaForecastLocal.get.find{|x| x.code == area_forecast_local_code}
    end
  end
end
