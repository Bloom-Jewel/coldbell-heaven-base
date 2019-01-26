module MstShinyColors
  class Unit < Base
    self.table_name = 'unit_data'
    has_many :members, class_name: 'Chara'
  end
end
