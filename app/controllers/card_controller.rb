class CardController < ApplicationController
  def view
    @card = MstShinyColors::BaseCard.find(params[:id])
    @_card_details = {
      :skill => 'Skills',
    }
    if @card.produce? then
    end
    if @card.support? then
      @_card_details.update({
        :skill_aid => 'Aid Skills',
        :supp => 'Supports',
      })
    end
  end
  
  FieldFunction = Struct.new(:fun) do
    def execute(card)
      case fun
      when Symbol, String
        card.send(fun)
      when Proc, Method
        fun.call(card)
      when NilClass
        nil
      else
        fail TypeError, "cannot execute #{fun.class} <- #{fun}"
      end
    end
  end
  
  def list
    # prepare data (migrate to BJ -> separate into sub func)
    @config = {}
    -> {
      create_config = ->(key, &block){
        k = String(key).to_sym
        (@config[k] = {
          fields: {},
        }).instance_exec(&block)
        @config[k]
      }
      create_field  = ->(cfg, key, name, group, classes, function){
        f = cfg[:fields]
        k = String(key).dasherize.to_sym
        f[k] = {
          name: name,
          group: group,
          class: (classes.to_ary rescue []),
          function: FieldFunction.new(function),
        }
      }
      attr = %w(vocal dance visual mental).map do |k|
        [k[0,2].capitalize,k]
      end.to_h
      create_config.call :produce do
        create_field.call(self, :name, 'Title', 'general', [], :title_tr)
      end
      create_config.call :support do
        create_field.call(self, :name, 'Title', 'general', [], :title_tr)
        attr.each do |k,m|
          create_field.call(self, "stat_#{m}", k, 'general', [], "max_%s_bonus" % [m] )
        end
        create_field.call(self, :stat_overall_g, "Overall (G)", 'general', [], ->(c){
          score, grade = "%d" % c.max_overall_stat, c.max_overall_grade
          [score, grade]
        })
        create_field.call(self, :stat_ratio_g, "Ratio (G)", 'general', [], ->(c){
          score, grade = "%.3f" % c.max_ratio_stat, c.max_ratio_grade
          [score, grade]
        })
        # Panels
        create_field.call(self, :panel_style, "Panel Style", 'panels', [], ->(c){'Normal Panel'})
        create_field.call(self, :panel_passives, "Passives", 'panels', [], nil)
        create_field.call(self, :panel_actives, "Actives", 'panels', [], nil)
        create_field.call(self, :panel_breaks, "L. Breaks", 'panels', [], nil)
        # Aids
        # TODO: make a helper function or something
        create_field.call(self, :aid_skills, "Aid Skills", 'aids', [], nil)
      end
    }.call
    
    # main func
    @card_list = MstShinyColors::BaseCard.all.sort_by(&:id).group_by(&:type)
  end
end
