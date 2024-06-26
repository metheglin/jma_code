require "csv"

module JMACode::AreaMarine
  class A < Struct.new(
    :code, :name, :name_phonetic,
    keyword_init: true
  )
    HEADERS = %i(
      code
      name
      name_phonetic
    )

    class << self
      def load_20130523(&block)
        path = File.join(File.dirname(__FILE__), "../../data/20130523_AreaMarineAJ/AreaMarineA.csv")
        File.open(path) do |f|
          csv = CSV.new(f, headers: HEADERS, row_sep: "\r\n")
          if block_given?
            yield(csv)
          else
            load(csv, num_headers: 3, &block)
          end
        end
      end

      def load(csv, num_headers: 2)
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
  end

  class J < Struct.new(
    :code, :name, :name_phonetic, :used_by_local_marine_warning, :used_by_volcanic_marine_warning,
    keyword_init: true
  )
    HEADERS = %i(
      code
      name
      name_phonetic
      used_by_local_marine_warning
      used_by_volcanic_marine_warning
    )

    class << self
      def load_20130523(&block)
        path = File.join(File.dirname(__FILE__), "../../data/20130523_AreaMarineAJ/AreaMarineJ.csv")
        File.open(path) do |f|
          csv = CSV.new(f, headers: HEADERS, row_sep: "\r\n")
          if block_given?
            yield(csv)
          else
            load(csv, num_headers: 4, &block)
          end
        end
      end

      def load(csv, num_headers: 2)
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
          used_by_local_marine_warning: row[:used_by_local_marine_warning],
          used_by_volcanic_marine_warning: row[:used_by_volcanic_marine_warning],
        )
      end
    end
  end
end
