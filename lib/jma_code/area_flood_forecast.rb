require "csv"

module JMACode
  class AreaFloodForecast < Struct.new(
    :code, :name, :name_phonetic,
    keyword_init: true
  )
    CSV_ROW_SEP = "\r\n"
    HEADERS = %i(code name name_phonetic)
    NUM_HEADER_ROWS = 3

    class << self
      attr_accessor :area_rivers

      def load_csv(version: "20230105")
        path = File.join(File.dirname(__FILE__), "../../data/#{version}_AreaFloodForecast.csv")
        File.open(path) do |f|
          csv = CSV.new(f, headers: HEADERS, row_sep: CSV_ROW_SEP)
          yield(csv)
        end
      end

      def load(**args)
        load_csv(**args) do |csv|
          csv.drop(NUM_HEADER_ROWS).map do |row|
            new(
              code: row[:code], 
              name: row[:name], 
              name_phonetic: row[:name_phonetic]
            )
          end
        end
      end

      def load_area_rivers(**args)
        @area_rivers = AreaRiver.load(**args)
      end

      def area_rivers
        @area_rivers || load_area_rivers
      end
    end

    def river_code
      code[0..9]
    end

    def area_river
      @area_river ||= self.class.area_rivers.find{|ar| ar.code == river_code}
    end
  end
end
