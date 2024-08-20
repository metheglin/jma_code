module JMACode
  using Blank

  class AreaForecastLocalE < Struct.new(
    :code, :name, :name_phonetic, 
    keyword_init: true
  )
    CSV_ROW_SEP = "\r\n"
    NUM_HEADER_ROWS = 1
    HEADERS = %i(
      code
      name
      name_phonetic
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
        )
      end
    end

    # def prefecture_code
    #   @prefecture_code ||= code[0, 2]
    # end

    # def prefecture
    #   @prefecture ||= Prefecture.get.find{|pref| pref.code == prefecture_code}
    # end

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
