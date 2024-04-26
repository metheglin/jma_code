
module JMACode
  using Blank

  class AreaForecastLocal < Struct.new(
    :code, :name, :name_phonetic, :used_by,
    keyword_init: true
  )
    HEADERS = %i(
      code
      name
      name_phonetic
    )

    class << self
      attr_accessor :area_information_cities

      def load_20240216(&block)
        path = File.join(File.dirname(__FILE__), "../../data/20240216_AreaInformationCity-AreaForecastLocalM/AreaForecastLocalM（コード表）.csv")
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
