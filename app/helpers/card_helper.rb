module CardHelper
  def shinymasu_card_image_path(type,card_id)
    case type
    when /^full/
      ext = 'jpg'
    else
      ext = 'png'
    end
    "/img/card/#{card_id}_#{type}.#{ext}"
  end
end
