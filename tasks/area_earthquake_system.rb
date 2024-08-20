require "fileutils"

namespace :area_earthquake_system do
  desc "Complete areas relating earthquake in data/*.csv"
  task :complete do
    puts "areas relating earthquake complete"
    version = "20240618"
    area_city_version = "20240216"

    source_prefix = File.expand_path("../data/#{version}_Volcano-Earthquake", __dir__)
    dest_prefix = File.expand_path("../data/#{version}-completed_Volcano-Earthquake", __dir__)

    path1 = "#{source_prefix}/AreaForecastLocalE-AreaInformationCity-PointSeismicIntensity.csv"
    headers1 = %i(area_local_code area_local_name area_local_name_phonetic area_city_code area_city_name area_city_name_phonetic point_code point_name point_name_phonetic)
    list1 = CSV.read(path1, headers: headers1, row_sep: "\r\n").drop(3)

    path2 = "#{source_prefix}/AreaForecastLocalE-AreaInformationCity-PointRealtimeIntensity.csv"
    headers2 = %i(area_local_code area_local_name area_city_code area_city_name point_code point_name)
    list2 = CSV.read(path2, headers: headers2, row_sep: "\r\n").drop(3)

    path3 = "#{source_prefix}/AreaForecastLocalE-PointSeismicLgIntensity.csv"
    headers3 = %i(area_local_code area_local_name point_code point_name point_name_phonetic)
    list3 = CSV.read(path3, headers: headers3, row_sep: "\r\n").drop(3)

    area_locals1 = list1.map{[_1[:area_local_code], _1[:area_local_name], _1[:area_local_name_phonetic]]}
    area_locals2 = list2.map{[_1[:area_local_code], _1[:area_local_name], nil]}
    area_locals3 = list3.map{[_1[:area_local_code], _1[:area_local_name], nil]}

    area_forecast_locals = (area_locals1 + area_locals2 + area_locals3).uniq{|code,name,name_phonetic| code}.map{|code,name,name_phonetic|
      JMACode::AreaForecastLocalE.new(code: code, name: name, name_phonetic: name_phonetic)
    }

    FileUtils.mkdir_p(dest_prefix)

    path_area_local = "#{dest_prefix}/AreaForecastLocalE.csv"
    CSV.open(path_area_local, "wb", row_sep: JMACode::AreaForecastLocalE::CSV_ROW_SEP) do |csv|
      (JMACode::AreaForecastLocalE::NUM_HEADER_ROWS - 1).times.each do
        csv << []
      end
      csv << JMACode::AreaForecastLocalE::HEADERS
      area_forecast_locals.each do |local|
        csv << local.to_csv_row
      end
    end

    area_cities1 = list1.map{[_1[:area_city_code], _1[:area_local_code]]}
    area_cities2 = list2.map{[_1[:area_city_code], _1[:area_local_code]]}
    area_cities3 = list3.map{[_1[:area_city_code], _1[:area_local_code]]}
    area_cities = area_cities1 + area_cities2 + area_cities3

    cities = JMACode::AreaInformationCity.load(version: area_city_version)
    cities.each do |city|
      city_code, local_code = area_cities.find{|city_code, local_code| city.code == city_code}
      city.area_forecast_local_e_code = local_code
    end
    
    area_city_dest_path = File.expand_path("../data/#{area_city_version}-completed_AreaInformationCity-AreaForecastLocalM/AreaInformationCity.csv", __dir__)
    CSV.open(area_city_dest_path, "wb", row_sep: JMACode::AreaInformationCity::CSV_ROW_SEP) do |csv|
      (JMACode::AreaInformationCity::NUM_HEADER_ROWS - 1).times.each do
        csv << []
      end
      csv << JMACode::AreaInformationCity::HEADERS
      cities.each do |city|
        csv << city.to_csv_row
      end
    end

    points = []
    # list_all = (list1 + list2 + list3)
    points = list1.map{|row|
      JMACode::PointSeismicIntensity.new(
        code: row[:point_code], 
        name: row[:point_name],
        name_phonetic: row[:point_name_phonetic],
        area_information_city_code: row[:area_city_code],
        used_by: [:regular_seismic_intensity]
      )
    }
    list2.each{|row|
      if point = points.find{|pt| pt.code == row[:point_code]}
        point.used_by << :realtime_seismic_intensity
      else
        points << JMACode::PointSeismicIntensity.new(
          code: row[:point_code], 
          name: row[:point_name],
          name_phonetic: row[:point_name_phonetic],
          area_information_city_code: row[:area_city_code],
          used_by: [:realtime_seismic_intensity]
        )
      end
    }
    list3.each{|row|
      if point = points.find{|pt| pt.code == row[:point_code]}
        point.used_by << :long_seismic_intensity
      else
        points << JMACode::PointSeismicIntensity.new(
          code: row[:point_code], 
          name: row[:point_name],
          name_phonetic: row[:point_name_phonetic],
          area_information_city_code: row[:area_city_code],
          used_by: [:long_seismic_intensity]
        )
      end
    }

    path_point = "#{dest_prefix}/PointSeismicIntensity.csv"
    CSV.open(path_point, "wb", row_sep: JMACode::PointSeismicIntensity::CSV_ROW_SEP) do |csv|
      (JMACode::PointSeismicIntensity::NUM_HEADER_ROWS - 1).times.each do
        csv << []
      end
      csv << JMACode::PointSeismicIntensity::HEADERS
      points.each do |point|
        csv << point.to_csv_row
      end
    end
  end
end
