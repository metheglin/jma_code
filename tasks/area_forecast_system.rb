require "fileutils"

namespace :area_forecast_system do
  desc "Complete area forecast local in data/*.csv"
  task :complete do
    puts "area forecast local complete"
    version = "20240216"
    area_forecast_locals = JMACode::AreaForecastLocal.load(version: version)
    area_relation = JMACode::AreaForecastLocal.load_relation(version: version)
    area_forecast_locals.each do |local|
      area_relation.relation_weather_alert.find{|code_type3, code_type2, code_type1|
        if code_type3 == local.code && code_type2 != local.code
          local.belonging_local_code_in_weather_alert = code_type2
        elsif code_type2 == local.code && code_type1 != local.code
          local.belonging_local_code_in_weather_alert = code_type1
        end
      }

      area_relation.relation_tornado_alert.find{|code_type3, code_type2, code_type1|
        if code_type3 == local.code && code_type2 != local.code
          local.belonging_local_code_in_tornado_alert = code_type2
        elsif code_type2 == local.code && code_type1 != local.code
          local.belonging_local_code_in_tornado_alert = code_type1
        end
      }
    end

    path_prefix = File.expand_path("../data/#{version}-completed_AreaInformationCity-AreaForecastLocalM", __dir__)
    FileUtils.mkdir_p(path_prefix)
    path = "#{path_prefix}/AreaForecastLocalM（コード表）.csv"
    CSV.open(path, "wb", row_sep: JMACode::AreaForecastLocal::CSV_ROW_SEP) do |csv|
      (JMACode::AreaForecastLocal::NUM_HEADER_ROWS - 1).times.each do
        csv << []
      end
      csv << JMACode::AreaForecastLocal::HEADERS
      area_forecast_locals.each do |local|
        csv << local.to_csv_row
      end
    end
  end
end
