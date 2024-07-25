require "csv"

module JMACode
  using Blank

  class WaterLevelStation < Struct.new(
    :code, :name, :river_name,
    keyword_init: true
  )
    CSV_ROW_SEP = "\r\n"
    HEADERS = %i(code name river_name)
    NUM_HEADER_ROWS = 3

    class << self
      def load_csv(version: "20240418")
        path = File.join(File.dirname(__FILE__), "../../data/#{version}_WaterLevelStation.csv")
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
              river_name: row[:river_name],
            )
          end
        end
      end

      def rivers
        @rivers ||= AreaRiver.load
      end
    end

    def river_code
      code[0..9]
    end

    def river
      @river ||= self.class.rivers.find{|r| r.code == river_code}
    end
  end
end
