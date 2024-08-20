module JMACode
  using Blank

  class PointSeismicIntensity < Struct.new(
    :code, :name, :name_phonetic, 
    :area_information_city_code,
    :used_by,
    keyword_init: true
  )
    CSV_ROW_SEP = "\r\n"
    NUM_HEADER_ROWS = 1
    HEADERS = %i(
      code
      name
      name_phonetic
      area_information_city_code
      used_by_regular_seismic_intensity
      used_by_realtime_seismic_intensity
      used_by_long_seismic_intensity
    )

    class << self
      attr_accessor :data

      def load_csv(version: "20240618-completed")
        path = File.join(File.dirname(__FILE__), "../../data/#{version}_Volcano-Earthquake/PointSeismicIntensity.csv")
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
        used_by_fields = HEADERS.select{|n| n.to_s.start_with?('used_by_')}
        new(
          code: row[:code], 
          name: row[:name], 
          name_phonetic: row[:name_phonetic],
          area_information_city_code: row[:area_information_city_code],
          used_by: used_by_fields.select{|f| row[f] == '1'}.map{|f| f.to_s.sub(/\Aused_by_/, '').to_sym}
        )
      end
    end

    # def prefecture_code
    #   @prefecture_code ||= code[0, 2]
    # end

    # def prefecture
    #   @prefecture ||= Prefecture.get.find{|pref| pref.code == prefecture_code}
    # end

    def area_information_city
      @area_information_city ||= AreaInformationCity.get.find{|x| x.code == area_information_city_code}
    end

    def to_csv_row
      HEADERS.map do |k|
        if respond_to?(k)
          public_send(k)
        else
          if k.to_s.start_with?("used_by_")
            x = k.to_s.sub('used_by_', '').to_sym
            used_by.include?(x) ? '1' : nil
          end
        end
      end
    end
  end
end
