require 'open-uri'
require 'nokogiri'
require 'net/http'
require 'tempfile'
require 'zip'

require "jma_code"

# def main
#   x = url_to_tempfile("https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-W05.html")
#   pp x.path
#   puts File.read x
# end

class JMACode::RiverDataPrefecture < Struct.new(:url, keyword_init: true)
  class << self
    def pref_ids
      (1..47).to_a.map{|pref_id| pref_id.to_s.rjust(2, '0')}
    end

    def all
      @all ||= begin
        puts "Started to scrape page"
        doc = Nokogiri::HTML(URI.open("https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-W05.html"))

        filenames = pref_ids.map do |pref_id|
          n = doc.css("tr:has(td#prefecture#{pref_id})")
          n.first.elements[4].text
        end

        urls = filenames.map do |filename|
          group, pref_id, suffix = filename.split('_')
          kind, serial = group.split('-')
          new(
            url: "https://nlftp.mlit.go.jp/ksj/gml/data/#{kind}/#{group}/#{filename}",
            # pref_id: pref_id,
            # filename: filename,
            # group: group
          )
        end
      end
    end

    def file_to_unzip(io, globname:)
      puts "Started to unzip #{globname}"
      Zip::File.open(io) do |zip_file|
        entries = zip_file.glob(globname)
        if entries.length <= 0
          raise "No zip entry detected with globname=#{globname}. #{zip_file.map(&:name)}"
        end
        if entries.length > 1
          puts "More than 1 file detected in zip: #{entries.map(&:name)}. Consider to appropriate filename, not #{filename}"
        end

        entry = entries.first
        entry.get_input_stream.read
      end
    end
  end

  def filename
    @filename ||= url.split('/').last
  end

  def parsed_filename
    @parsed_filename ||= filename.split('_')
  end

  def group
    group, _, _ = parsed_filename
    group
  end

  def pref_id
    _, pref_id, _ = parsed_filename
    pref_id
  end

  def prefix
    [group, pref_id].join('_')
  end

  def globname
    # "#{prefix}*/#{prefix}*.xml"
    "**/#{prefix}*.xml"
  end

  def download
    uri = URI.parse(url)
    puts "Started to download #{url} to #{filename}"
    @tempfile ||= Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      res = http.get(uri)
      Tempfile.open(filename) do |tempfile|
        tempfile.binmode
        tempfile.write(res.body)
        tempfile.flush
        tempfile
      end
    end
  end

  def download!
    @tempfile = nil
    download
  end

  def get_xml
    download unless @tempfile
    self.class.file_to_unzip(@tempfile, globname: globname)
  end

  def get_river_objects
    xml = get_xml
    puts "Started to read xml"
    doc = Nokogiri::XML(xml)
    ns = {ksj: "http://nlftp.mlit.go.jp/ksj/schemas/ksj-app"}
    streams = doc.xpath('//ksj:Stream', ns)
    streams.map do |stream|
      elements = stream.elements
      water_system_code = elements.find{|e| e.name == 'waterSystemCode'}&.text
      river_code = elements.find{|e| e.name == 'riverCode'}&.text
      river_name = elements.find{|e| e.name == 'riverName'}&.text
      JMACode::RiverObject.new(code: river_code, name: river_name, water_system_code: water_system_code)
    end
  end
end

class JMACode::RiverObject < Struct.new(:code, :name, :water_system_code, keyword_init: true)

  class << self
    # def main
    #   url, filename, group, pref_id = get_urls().first
    #   prefix = [group, pref_id].join('_')
    #   pp url, filename
    #   tempfile = url_to_tempfile(url)
    #   pp tempfile.path
    #   xml = tempfile_to_unzip(tempfile, filename: "#{prefix}*/#{prefix}*.xml")
    #   rivers = w05_xml_to_rivers(xml)
    #   puts rivers

    #   # get_urls().each do |url|

    #   # end
    # end

    # def get_pref_ids
    #   (1..47).to_a.map{|pref_id| pref_id.to_s.rjust(2, '0')}
    # end

    # def get_urls
    #   puts "Started to scrape page"
    #   doc = Nokogiri::HTML(URI.open("https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-W05.html"))

    #   filenames = get_pref_ids().map do |pref_id|
    #     n = doc.css("tr:has(td#prefecture#{pref_id})")
    #     n.first.elements[4].text
    #   end

    #   urls = filenames.map do |filename|
    #     group, pref_id, suffix = filename.split('_')
    #     kind, serial = group.split('-')
    #     ["https://nlftp.mlit.go.jp/ksj/gml/data/#{kind}/#{group}/#{filename}", filename, group, pref_id]
    #   end
    # end

    # def url_to_tempfile(url, filename: nil)
    #   filename ||= 'tempfile'
    #   uri = URI.parse(url)
    #   puts "Started to download #{url} to #{filename}"
    #   Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
    #     res = http.get(uri)
    #     Tempfile.open(filename) do |tempfile|
    #       tempfile.binmode
    #       tempfile.write(res.body)
    #       tempfile.flush
    #       tempfile
    #     end
    #   end
    # end

    # def tempfile_to_unzip(tempfile, filename:)
    #   puts "Started to unzip #{filename}"
    #   Zip::File.open(tempfile) do |zip_file|
    #     entries = zip_file.glob(filename)
    #     if entries.length <= 0
    #       raise "No zip entry detected with filename=#{filename}."
    #     end
    #     if entries.length > 1
    #       puts "More than 1 file detected in zip: #{entries.map(&:name)}. Consider to appropriate filename, not #{filename}"
    #     end

    #     entry = entries.first
    #     entry.get_input_stream.read
    #   end
    # end

    # def w05_xml_to_rivers(xml)
    #   puts "Started to read xml"
    #   doc = Nokogiri::XML(xml)
    #   ns = {ksj: "http://nlftp.mlit.go.jp/ksj/schemas/ksj-app"}
    #   streams = doc.xpath('//ksj:Stream', ns)
    #   streams.map do |stream|
    #     elements = stream.elements
    #     water_system_code = elements.find{|e| e.name = 'ksj:waterSystemCode'}&.text
    #     river_code = elements.find{|e| e.name = 'ksj:riverCode'}&.text
    #     river_name = elements.find{|e| e.name = 'ksj:riverName'}&.text
    #     new(code: river_code, name: river_name, water_system_code: water_system_code)
    #   end
    # end
  end

end
