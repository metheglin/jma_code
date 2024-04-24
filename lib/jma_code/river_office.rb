require "csv"

module JMACode
  class RiverOffice < Struct.new(
    :code, :name,
    keyword_init: true
  )
    HEADERS = %i(code name)

    class << self
      def load_20240315(&block)
        path = File.join(File.dirname(__FILE__), "../../data/20240315_RiverOffice.csv")
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
          new(code: row[:code], name: row[:name])
        end
      end
    end
  end
end
