module ColdbellHeaven
  class CharaController < ApplicationController
    public
    # View character detail
    # From her basic data until her available cards.
    def view
      @chara = MstShinyColors::Chara.find(params[:id])
      @title = "ShinyColors - %s detail" % [@chara.name_romaji]
    end
    
    # View character list from Attr/Unit matrix
    # Knowing your idol attribute is important too
    def view_matrix
      @title = "ShinyColors - Character Matrix"
      @_chara_table = {}
      MstShinyColors::Chara.all.each do |chara|
        unit_id = chara.unit_id
        attribute = chara.attr
        
        unit_table = (@_chara_table[unit_id] ||= {'Sun'=>[],'Moon'=>[],'Star'=>[]})
        attr_table = unit_table[attribute]
        
        attr_table << chara
      end
    end
  end
end
