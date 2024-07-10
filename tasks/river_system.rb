require_relative "./jma_ext/river_system"

namespace :river_system do
  desc "Complete river information in data/*.csv"
  task :complete do
    puts "river complete"
    version = "20230105"
    area_rivers = JMACode::AreaRiver.load(version: version)
    JMAExt::RiverDataPrefecture.all.each do |river_data_pref|
      master_rivers = river_data_pref.get_river_objects
      master_river_codes = master_rivers.map(&:code)

      area_rivers.each do |area_river|
        if master_river_codes.include?(area_river.code)
          area_river.add_prefecture_id(river_data_pref.pref_id)
        end
      end
    end
    # 
    CSV.open(File.expand_path("../data/#{version}-completed_AreaRiver.csv", __dir__), "wb") do |csv|
      (JMACode::AreaRiver::NUM_HEADER_ROWS - 1).times.each do
        csv << []
      end
      csv << JMACode::AreaRiver::HEADERS
      area_rivers.each do |area_river|
        csv << area_river.to_csv_row
      end
    end
  end
end
