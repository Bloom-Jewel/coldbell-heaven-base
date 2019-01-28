namespace :coldbell_heaven do |ns|
  require 'digest'
  
  task :make  => :environment do
    scp = String(ENV['SHINYCOLORS_REPO_PATH'])
    scm = File.join(scp, 'bin', 'sqlmake')
    if File.directory?(scp) && File.exists?(scm) then
      IO.popen({'PWD'=>scp},['bin/sqlmake'],'r+',{chdir: scp}) do |osio|
      end
    else
      fail "Wrong directory!"
    end
  end
  
  task :fetch => :environment do
    head = "#{Rails.root}/app/models"
    uri = URI('https://shinycolors.enza.fun')
    ctime = Time.now
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      call_network = ->(http, fn, path, &block) {
        next if File.exists?(fn) # && (ctime - File.mtime(fn)) < 86400 * 3
        
        req = Net::HTTP::Get.new(path)
        req['User-Agent'] = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0'
        res = http.request(req)
        
        next ($stderr.puts "#{path} not found") if res.content_type == 'text/html'
        res.value
        if block.respond_to?(:call)
          new_res = block.call(res.body)
          res.body.replace(new_res)
        end
        if File.exists?(fn)
          dg1, dg2 = Digest::SHA256.file(fn).hexdigest, Digest::SHA256.new.update(res.body).hexdigest
          `touch #{fn}`
          next if dg1 == dg2
        end
        File.binwrite(fn, res.body)
      }
      
      fmtstr = '/assets/images/content/characters/%s/%03d.png'.freeze
      fmtspine = '/assets/spine/characters/cb/%03d/data.%s'.freeze
      
      MstShinyColors::Chara.all.map(&:id).each do |chara_id|
        $stderr.print "Chara #{chara_id} "
        [
          ['stand_gasha','upper'],
          ['memory_roulette_good','roul1'],
          ['memory_roulette_bad','roul2'],
        ].each do |(urlk, fnk)|
          $stderr.print "#{fnk} "
          path = fmtstr % [urlk, chara_id]
          fn   = "%s/public/img/chara/%02d_%s.png" % [Rails.root, chara_id, fnk]
          ecp  = "/assets/%s" % [MstShinyColors::BlobMaster.encrypt_path(path, nil)]
          
          call_network.call(http, fn, ecp)
        end
        ->(){
          data_path, json_path, spine_path = %w(atlas json png).map do |ext| fmtspine % [chara_id, ext] end
          base_dl = '%s/private/spine/chara/%02d.%s'
          [[data_path,'atlas'],[spine_path,'png'],[json_path,'json']].each do |(path, ext)|
            $stderr.print "spine.#{ext} "
            fn  = base_dl % [Rails.root, chara_id, ext]
            ecp = '/assets/%s' % [MstShinyColors::BlobMaster.encrypt_path(path, nil)]
            
            case ext
            when 'atlas', 'json'
              call_network.call(http, fn, ecp, &MstShinyColors::BlobMaster.method(:decrypt_text))
            else
              call_network.call(http, fn, ecp)
            end
          end
        }.call
        $stderr.puts
      end
      MstShinyColors::Chara.all.map(&:cards).flatten
        .each do |card|
          puts "#{card.class} #{card.title} #{card.character.name}"
          [
            [:icon_path,'icon'], [:image_path,'full'],
            [:fes_icon_path, 'icon2'], [:fes_image_path, 'full2'],
          ].each do |(meth, fnkey)|
            path = card.method(meth).call
            next if path.nil?
            
            ext = File.extname(path)
            base = File.basename(path,ext)
            ecp = MstShinyColors::BlobMaster.encrypt_path(path,base)
            tfn = "#{Rails.root}/public/img/card/#{card.id}_#{fnkey}#{ext}"
            
            final_path = "/assets/%s%s" % [ecp, %w(.mp3 .mp4 .m4a).include?(ext) ? ext : '']
            call_network.call(http, tfn, final_path)
          end
        end
      # pass
    end
  end
end

