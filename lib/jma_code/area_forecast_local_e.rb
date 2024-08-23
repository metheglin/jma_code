module JMACode
  using Blank

  class AreaForecastLocalE < Struct.new(
    :code, :name, :name_phonetic, :prefecture_code,
    keyword_init: true
  )
    CSV_ROW_SEP = "\r\n"
    NUM_HEADER_ROWS = 1
    HEADERS = %i(
      code
      name
      name_phonetic
      prefecture_code
    )

    class << self
      attr_accessor :data

      def load_csv(version: "20240618-completed")
        path = File.join(File.dirname(__FILE__), "../../data/#{version}_Volcano-Earthquake/AreaForecastLocalE.csv")
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

      def get
        @data ||= load
      end

      def build_by_csv_row(row)
        new(
          code: row[:code], 
          name: row[:name], 
          name_phonetic: row[:name_phonetic],
          prefecture_code: row[:prefecture_code],
        )
      end

      def build_tree(areas=nil, cities=nil)
        areas ||= get
        cities ||= JMACode::AreaInformationCity.get
        
        areas.group_by(&:prefecture).map{|pref, pref_areas|
          [
            block_given? ? yield(pref) : pref, 
            pref_areas.map{|a|
              [
                block_given? ? yield(a) : a,
                a.area_information_cities.map{|c|
                  [
                    block_given? ? yield(c) : c, 
                    nil
                  ]
                }
              ]
            }
          ]
        }
      end

      def walk_tree(tree, &block)
        tree.map do |area, children|
          a = block.call(area)
          c = if children.is_a?(Array) and children.present?
            walk_tree(children, &block)
          else
            children
          end
          [a, c]
        end
      end
    end

    def prefecture
      @prefecture ||= Prefecture.get.find{|pref| pref.code == prefecture_code}
    end

    def area_information_cities
      @area_information_cities ||= AreaInformationCity.get.select{|x| x.area_forecast_local_e_code == code}
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
