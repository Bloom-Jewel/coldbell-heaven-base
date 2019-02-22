module ColdbellHeaven
  module ApplicationHelper
    def asset_encode_path(path)
      ext = File.extname(path)
      ecp = MstShinyColors::BlobMaster.encrypt_path(path)
      wex = %w(.mp4 .mp3 .m4a).include?(ext)
      "https://shinycolors.enza.fun/assets/%s%s" % [ecp, wex ? ext : nil]
    end
  end
end
