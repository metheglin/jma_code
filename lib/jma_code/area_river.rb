require "csv"

module JMACode
  class AreaRiver < Struct.new(
    :code, :name, :name_phonetic,
    :name2, :name_phonetic2, :name3, :name_phonetic3,
    :prefecture_ids,
    keyword_init: true
  )
    HEADERS = %i(code name name_phonetic name2 name_phonetic2 name3 name_phonetic3 prefecture_ids)
    NUM_HEADER_ROWS = 3
    PREFECTURE_ID_SEPARATOR = '/'

    class << self
      def load_csv(version: "20230105")
        path = File.join(File.dirname(__FILE__), "../../data/#{version}_AreaRiver.csv")
        File.open(path) do |f|
          csv = CSV.new(f, headers: HEADERS, row_sep: "\r\n")
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
              prefecture_ids: row[:prefecture_ids]
            )
          end
        end
      end
    end

    def prefecture_id_list
      (prefecture_ids || "").split(PREFECTURE_ID_SEPARATOR)
    end

    def add_prefecture_id(pref_id)
      ids = (prefecture_id_list + [pref_id]).sort.uniq
      self.prefecture_ids = ids.join(PREFECTURE_ID_SEPARATOR)
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
