require_relative "./tools/river_system"

namespace :river_system do
  desc "Complete river information in data/*.csv"
  task :complete do
    puts "river complete"
    area_rivers = JMACode::AreaRiver.load(version: "20230105")
    JMACode::RiverDataPrefecture.all.drop(1).first(3).each do |river_data_pref|
      master_rivers = river_data_pref.get_river_objects
      master_river_codes = master_rivers.map(&:code)

      area_rivers.each do |area_river|
        if master_river_codes.include?(area_river.code)
          area_river.add_prefecture_id(river_data_pref.pref_id)
        end
      end
    end
    # TODO: Output new CSV with prefecture_ids
    # pp area_rivers.map(&:prefecture_ids)
  end
end
