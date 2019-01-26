#!/usr/bin/env ruby
module MstShinyColors
  class BaseTranslation < BaseLightModel
    const_set :LOAD_FILE, nil unless const_defined?(:LOAD_FILE)
    private_constant :LOAD_FILE
    class << self
      def load
        if const_defined?(:LOAD_FILE) && const_get(:LOAD_FILE).is_a?(String) then
          @__data.clear
          CSV.table(const_get(:LOAD_FILE)).tap do |csv|
            set_columns *csv.headers
            csv.each do |row|
              new(**row.to_h)
            end
          end
        else
          fail "LOAD_FILE is not defined properly"
        end
        nil
      end
      private :new
    end
  end
end
