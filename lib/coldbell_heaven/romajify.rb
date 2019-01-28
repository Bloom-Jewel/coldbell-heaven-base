module Romajify
class Converter
  class << self
    def lazy_hepb(t, o = {})
      r = t.encode(Encoding::UTF_8)
      r = romanize(romanize(r,DIGRAPHS),MONOGRAPHS)
      r.gsub!(/[っッ]c/, 'tc')
      r.gsub!(/[っッ](.)/, '\1\1')
      r.gsub!(/n([bmp])/, 'm\1') if o[:traditional]
      if o[:i_hate_long] then
        r.gsub!(/oo(.+)/, 'o\1')
        r.gsub!(/ou/, 'o')
        r.gsub!(/uu/, 'u')
      end
      r.upcase! if o[:upcase]
      r.gsub!(/\w+/,&:capitalize) if o[:capitalize]
      r
    end
  end
end
end
