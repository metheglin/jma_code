module JMACode
  class Prefecture < Struct.new(
    :id, :code, :name, :short_name, :slug, 
    keyword_init: true
  )
    DATA = [
      [1, '北海道', '北海道', 'hokkaido'],
      [2, '青森県', '青森', 'aomori'],
      [3, '岩手県', '岩手', 'iwate'],
      [4, '宮城県', '宮城', 'miyagi'],
      [5, '秋田県', '秋田', 'akita'],
      [6, '山形県', '山形', 'yamagata'],
      [7, '福島県', '福島', 'fukushima'],
      [8, '茨城県', '茨城', 'ibaraki'],
      [9, '栃木県', '栃木', 'tochigi'],
      [10, '群馬県', '群馬', 'gunma'],
      [11, '埼玉県', '埼玉', 'saitama'],
      [12, '千葉県', '千葉', 'chiba'],
      [13, '東京都', '東京', 'tokyo'],
      [14, '神奈川県', '神奈川', 'kanagawa'],
      [15, '新潟県', '新潟', 'niigata'],
      [16, '富山県', '富山', 'toyama'],
      [17, '石川県', '石川', 'ishikawa'],
      [18, '福井県', '福井', 'fukui'],
      [19, '山梨県', '山梨', 'yamanashi'],
      [20, '長野県', '長野', 'nagano'],
      [20, '岐阜県', '岐阜', 'gifu'],
      [22, '静岡県', '静岡', 'shizuoka'],
      [23, '愛知県', '愛知', 'aichi'],
      [24, '三重県', '三重', 'mie'],
      [25, '滋賀県', '滋賀', 'shiga'],
      [26, '京都府', '京都', 'kyoto'],
      [27, '大阪府', '大阪', 'osaka'],
      [28, '兵庫県', '兵庫', 'hyogo'],
      [29, '奈良県', '奈良', 'nara'],
      [30, '和歌山県', '和歌山', 'wakayama'],
      [31, '鳥取県', '鳥取', 'tottori'],
      [32, '島根県', '島根', 'shimane'],
      [33, '岡山県', '岡山', 'okayama'],
      [34, '広島県', '広島', 'hiroshima'],
      [35, '山口県', '山口', 'yamaguchi'],
      [36, '徳島県', '徳島', 'tokushima'],
      [37, '香川県', '香川', 'kagawa'],
      [38, '愛媛県', '愛媛', 'ehime'],
      [39, '高知県', '高知', 'kochi'],
      [40, '福岡県', '福岡', 'fukuoka'],
      [41, '佐賀県', '佐賀', 'saga'],
      [42, '長崎県', '長崎', 'nagasaki'],
      [43, '熊本県', '熊本', 'kumamoto'],
      [44, '大分県', '大分', 'oita'],
      [45, '宮崎県', '宮崎', 'miyazaki'],
      [46, '鹿児島県', '鹿児島', 'kagoshima'],
      [47, '沖縄県', '沖縄', 'okinawa'],
    ]

    class << self
      def all
        DATA.map do |id, name, short_name, slug|
          new(
            id: id, 
            code: id.to_s.rjust(2, '0'),
            name: name, 
            short_name: short_name, 
            slug: slug
          )
        end
      end
    end

    def type
      @type ||= begin
        res = name.sub(short_name, '')
        res.empty? ? '道' : res
      end
    end
  end
end
