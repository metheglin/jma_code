require "csv"

module JMACode
  class AreaRiver < Struct.new(
    :code, :name, :name_phonetic,
    :name2, :name_phonetic2, :name3, :name_phonetic3,
    :prefecture_codes,
    keyword_init: true
  )
    CSV_ROW_SEP = "\r\n"
    HEADERS = %i(code name name_phonetic name2 name_phonetic2 name3 name_phonetic3 prefecture_codes)
    NUM_HEADER_ROWS = 3
    PREFECTURE_CODE_SEPARATOR = '/'

    class << self
      attr_accessor :prefectures

      def load_csv(version: "20230105-completed")
        path = File.join(File.dirname(__FILE__), "../../data/#{version}_AreaRiver.csv")
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
              name_phonetic: row[:name_phonetic],
              name2: row[:name2], 
              name_phonetic2: row[:name_phonetic2],
              name3: row[:name3], 
              name_phonetic3: row[:name_phonetic3],
              prefecture_codes: row[:prefecture_codes]
            )
          end
        end
      end

      def prefectures
        @prefectures ||= Prefecture.all
      end

      def water_level_stations
        @water_level_stations ||= WaterLevelStation.load
      end
    end

    def prefecture_code_list
      @prefecture_code_list ||= (prefecture_codes || "").split(PREFECTURE_CODE_SEPARATOR)
    end

    def add_prefecture_code(pref_code)
      ids = (prefecture_code_list + [pref_code]).sort.uniq
      self.prefecture_codes = ids.join(PREFECTURE_CODE_SEPARATOR)
    end

    def prefectures
      @prefectures ||= self.class.prefectures.select{|pref|
        prefecture_code_list.include?(pref.code)
      }
    end

    def water_level_stations
      @water_level_stations ||= self.class.water_level_stations.select{|w| w.river_code == code}
    end

    def to_csv_row
      HEADERS.map do |k|
        respond_to?(k) ?
          public_send(k) :
          nil
      end
    end
  end
end
