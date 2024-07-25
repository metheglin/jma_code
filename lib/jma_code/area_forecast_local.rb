
module JMACode
  using Blank

  class AreaForecastLocal < Struct.new(
    :code, :name, :name_phonetic, :used_by,
    keyword_init: true
  )
    CSV_ROW_SEP = "\r\n"
    NUM_HEADER_ROWS = 3
    HEADERS = %i(
      code
      name
      name_phonetic
    )

    class << self
      attr_accessor :area_information_cities

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

      def build_by_csv_row(row)
        new(
          code: row[:code], 
          name: row[:name], 
          name_phonetic: row[:name_phonetic],
        )
      end
    end

    def area_information_city
      @area_information_city ||= (self.class.area_information_cities || []).find{|x| x.area_forecast_local_code == code}
    end
  end
end
