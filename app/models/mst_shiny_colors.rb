module MstShinyColors
  GAME_TEASE_DATE = Time.new(2018,2,7,15,0,0,32400).freeze
end

loop do
  # Scan all class names
  case 2
  when 1
    Dir.glob(File.join(__dir__,File.basename(__FILE__,File.extname(__FILE__)),"**/*.rb")).each do |fn|
      cns = File.read(fn).scan(/(?:module|class)\s+((?:[A-Z][a-z]*)+)/).flatten
      ctx = Object
      while !cns.empty?
        con = cns.shift
        # ctx.const_missing(con) unless ctx.const_defined?(con,false)
        obj = ctx.const_get(con,false)
        if Module === obj then
          ctx = obj
        else
          cns.clear
        end
      end
    end
  when 2
    Dir.glob(File.join(__dir__,File.basename(__FILE__,File.extname(__FILE__)),"**/*.rb")).each(&Kernel.method(:require_or_load))
  end
  break
end
Object.const_set :ShinyColors, MstShinyColors unless defined?(ShinyColors)
