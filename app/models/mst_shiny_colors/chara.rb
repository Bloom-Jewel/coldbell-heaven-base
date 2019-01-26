module MstShinyColors
  class Chara < Base
    has_many :produce_cards
    has_many :support_cards
    belongs_to :unit
    
    self.table_name = 'character_data'
    
    def name_romaji
      return @_cache_vattr['name_romaji'] if @_cache_vattr.key?('name_romaji')
      
      @_cache_vattr['name_romaji'] = Romajify::Converter.lazy_hepb(self.name_kana,capitalize: true).gsub(/[[:space:]]+/,' ')
    rescue => e
      $stderr.puts "#{e.class}: #{e.message}"
      nil
    end
    def first_name_romaji
      return @_cache_vattr['first_name_romaji'] if @_cache_vattr.key?('first_name_romaji')
      
      @_cache_vattr['first_name_romaji'] = name_romaji.split(/\s+/).last
    rescue => e
      $stderr.puts "#{e.class}: #{e.message}"
      nil
    end
    def birth_day
      return @_cache_vattr['birth_day'] if @_cache_vattr.key?('birth_day')
      
      month, day = attributes['birth_day'].scan(/\d+/)
      this_time = Time.now
      base_time = GAME_TEASE_DATE
      idol_nxb  = Time.new(2018,month,day,0,0,0,32400)
      off_year  = 0
      while idol_nxb > base_time
        off_year += 1
        idol_nxb  = Time.new(2018 - off_year,month,day,0,0,0,32400)
      end
      real_idol = Time.new(this_time.year,month,day,0,0,0,32400)
      @_cache_vattr['birth_day'] = Time.new(idol_nxb.year - self.age,month,day,0,0,0,32400)
      @_cache_vattr['ex_age']    = self.age + (this_time.year - idol_nxb.year) + (this_time >= real_idol ? 0 : -1)
      @_cache_vattr['birth_day']
    end
    def actual_age
      return @_cache_vattr['ex_age'] if @_cache_vattr.key?('ex_age')
      
      birth_day
      @_cache_vattr['ex_age']
    end
    def cards(mode: nil)
      case mode
      when :neat
        # Neat mode explanation:
        # Cards sorted from their card type, rarity, card index
        r = {}
        q = ->(a,b,c,d){"%01d%02d%03d%03d%01d"%[a,b,c,d,0]}
        [:produce, :support].each_with_index do |ct,i|
          case ct
          when :produce, :support
            cg = send("#{ct}_cards")
          else
            next
          end
          gp = {}
          1.upto(4) do |r|
            rg, cr = {}, cg.where(rarity:r)
            next if cr.empty?
            mi = cr.max_by(&:card_index).card_index
            1.upto(mi) do |ci|
              cid = Integer(q.call(i.succ, r, id, ci))
              rg[cid] ||= cr.find_by_id(cid)
            end
            gp.update(rg)
          end
          r.update(gp)
        end
        r
      else
        produce_cards + support_cards
      end
    end
    def self.name
      'MstShinyColors::Character'
    end
  end
end
