require "csv"

module JMACode::PointAmedas
  class Ame < Struct.new(
    :code, :name, :name_phonetic, :type, :government_branch_name, :managed_by,
    :location, :lat, :lng, :altitude, :altitude_anemometer, :altitude_thermometer, :observation_started_since, 
    keyword_init: true
  )
    HEADERS = %i(
      government_branch_name
      code
      type
      name
      name_phonetic
      location
      lat_major
      lat_minor
      lng_major
      lng_minor
      altitude
      altitude_anemometer
      altitude_thermometer
      observation_started_since
      memo1
      memo2
    )

    class << self
      def load_20240325(&block)
        path = File.join(File.dirname(__FILE__), "../../data/20240325_PointAmedas/ame_master.csv")
        File.open(path) do |f|
          csv = CSV.new(f, headers: HEADERS, row_sep: "\r\n")
          if block_given?
            yield(csv)
          else
            load(csv, num_headers: 2, &block)
          end
        end
      end

      def load(csv, num_headers: 2)
        managed_by = nil
        list = []
        csv.each.with_index do |row, i|
          next if i < num_headers
          branch = row[:government_branch_name]
          if branch && branch.end_with?('管理')
            managed_by = branch
          else
            list << build_by_csv_row(row, managed_by: managed_by)
          end
        end
        list
      end

      def build_by_csv_row(row, managed_by: nil)
        new(
          code: row[:code], 
          name: row[:name], 
          name_phonetic: row[:name_phonetic],
          managed_by: managed_by,
          government_branch_name: row[:government_branch_name],
          type: row[:type],
          location: row[:location],
          lat: "#{row[:lat_major]}.#{row[:lat_minor]}".to_f,
          lng: "#{row[:lng_major]}.#{row[:lng_minor]}".to_f,
          altitude: row[:altitude],
          altitude_anemometer: row[:altitude_anemometer],
          altitude_thermometer: row[:altitude_thermometer],
          observation_started_since: row[:observation_started_since],
        )
      end
    end
  end
end
