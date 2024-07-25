class JMACode::AreaForecastType < Struct.new(:slug, :name, keyword_init: true)
  LIST = {
    type1: {name: "府県予報区等"},
    type2: {name: "一次細分区域等"},
    type3: {name: "市町村等をまとめた地域等"},
    type4: {name: "市町村等"},
  }

  def self.load
    LIST.map{|k,v| new(v.merge(slug: k.to_s))}
  end

  def self.get
    @data ||= load
  end
end
