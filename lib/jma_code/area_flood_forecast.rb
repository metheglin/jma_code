require "csv"

module JMACode
  class AreaFloodForecast < Struct.new(
    :code, :name, :name_phonetic,
    keyword_init: true
  )
    HEADERS = %i(code name name_phonetic)

    class << self
      def load_20230105(&block)
        path = File.join(File.dirname(__FILE__), "../../data/20230105_AreaFloodForecast.csv")
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
          new(code: row[:code], name: row[:name], name_phonetic: row[:name_phonetic])
        end
      end
    end
  end
end
