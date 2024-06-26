require "csv"

module JMACode
  using Blank

  class WaterLevelStation < Struct.new(
    :code, :name, :river_name,
    keyword_init: true
  )
    HEADERS = %i(
      code 
      name 
      river_name
    )

    class << self
      def load_20240418(&block)
        path = File.join(File.dirname(__FILE__), "../../data/20240418_WaterLevelStation.csv")
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
          river_name: row[:river_name],
        )
      end
    end
  end
end
