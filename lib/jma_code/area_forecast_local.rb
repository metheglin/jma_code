
module JMACode
  using Blank

  class AreaForecastLocal < Struct.new(
    :code, :name, :name_phonetic, 
    :belonging_local_code_in_weather_alert, 
    :belonging_local_code_in_tornado_alert, 
    :used_by,
    keyword_init: true
  )
    CSV_ROW_SEP = "\r\n"
    NUM_HEADER_ROWS = 4
    HEADERS = %i(
      code
      name
      name_phonetic
      used_by_area_forecast_type3_in_weather_alert
      used_by_area_forecast_type2_in_weather_alert
      used_by_area_forecast_type1_in_weather_alert
      used_by_weather_forecast
      used_by_weather_description
      used_by_next_weather_forecast
      used_by_landslide_alert
      used_by_area_forecast_type3_in_tornado_alert
      used_by_area_forecast_type2_in_tornado_alert
      used_by_area_forecast_type1_in_tornado_alert
      used_by_recorded_heavy_rain_alert
      used_by_flood_alert
      used_by_area_forecast_type3_in_typhoon_probability
      used_by_area_forecast_type1_in_typhoon_probability
      belonging_local_code_in_weather_alert
      belonging_local_code_in_tornado_alert
    )

    class << self
      attr_accessor :data

      def load_csv(version: "20240216-completed")
        path = File.join(File.dirname(__FILE__), "../../data/#{version}_AreaInformationCity-AreaForecastLocalM/AreaForecastLocalM（コード表）.csv")
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

      def load_relation(version: "20240216")
        headers = %i(code_type3 name_type3 code_type2 name_type2 code_type1 name_type1)
        
        path1 = File.join(File.dirname(__FILE__), "../../data/#{version}_AreaInformationCity-AreaForecastLocalM/AreaForecastLocalM（関係表　警報・注意報.csv")
        relation1 = File.open(path1) do |f|
          csv = CSV.new(f, headers: headers, row_sep: CSV_ROW_SEP)
          csv.drop(3).map do |row|
            [row[:code_type3], row[:code_type2], row[:code_type1]]
          end
        end

        path2 = File.join(File.dirname(__FILE__), "../../data/#{version}_AreaInformationCity-AreaForecastLocalM/AreaForecastLocalM（関係表　竜巻注意情報.csv")
        relation2 = File.open(path2) do |f|
          csv = CSV.new(f, headers: headers, row_sep: CSV_ROW_SEP)
          csv.drop(3).map do |row|
            [row[:code_type3], row[:code_type2], row[:code_type1]]
          end
        end

        Struct.new(:relation_weather_alert, :relation_tornado_alert, keyword_init: true).new({
          relation_weather_alert: relation1, relation_tornado_alert: relation2
        })
      end

      def build_by_csv_row(row)
        used_by_fields = HEADERS.select{|n| n.to_s.start_with?('used_by_')}

        new(
          code: row[:code], 
          name: row[:name], 
          name_phonetic: row[:name_phonetic],
          belonging_local_code_in_weather_alert: row[:belonging_local_code_in_weather_alert],
          belonging_local_code_in_tornado_alert: row[:belonging_local_code_in_tornado_alert],
          used_by: used_by_fields.select{|f| row[f] == '1'}.map{|f| f.to_s.sub(/\Aused_by_/, '').to_sym}
        )
      end
    end

    def area_information_cities
      @area_information_cities ||= AreaInformationCity.get.select{|x| x.area_forecast_local_code == code}
    end

    def belonging_local_in_weather_alert
      return nil if belonging_local_code_in_weather_alert.blank?
      @belonging_local_in_weather_alert ||= begin
        AreaForecastLocal.get.find{|a| a.code == belonging_local_code_in_weather_alert}
      end
    end

    def belonging_local_in_tornado_alert
      return nil if belonging_local_code_in_tornado_alert.blank?
      @belonging_local_in_tornado_alert ||= begin
        AreaForecastLocal.get.find{|a| a.code == belonging_local_code_in_tornado_alert}
      end
    end

    def any_belonging_locals
      [belonging_local_in_weather_alert, belonging_local_in_tornado_alert].compact.uniq(&:code)
    end

    def any_ancestry_locals
      [
        belonging_local_in_weather_alert, 
        belonging_local_in_tornado_alert, 
        belonging_local_in_weather_alert&.belonging_local_in_weather_alert, 
        belonging_local_in_tornado_alert&.belonging_local_in_tornado_alert, 
      ].compact.uniq(&:code)
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
