module MstShinyColors
  module BaseCard
    extend BaseMixedModel
    ASSET_IMAGE_PATH = '/assets/images/content'.freeze
    ASSET_MOVIE_PATH = '/assets/movies'.freeze
    
    def title
      @title ||= /【(.+)】/.match(self.name)[1]
    end
    def title_tr
      TitleTranslation.find(title).presence&.romanized_name || title
    end
    def title_tr?
      TitleTranslation.find(title).present?
    end
    def produce?
      type == :produce
    end
    def support?
      type == :support
    end
    def card_index
      ( id / 10 ) % 1000
    end
    def fes_costume?
      produce?
    end
    def incomplete?
      panels.empty? ||
      skills.empty? || 
      false
    end
    def memory
      []
    end
    def memory?
      self.memory.present?
    end
    def panels
      SkillPanel.where(idol_id: self.id)
    end
    def panel_tree(flat: nil)
      tree = panels.group_by(&:step).each{|level,depth|depth.sort_by!(&:sequence)}
      if flat then
        flat_tree = {}
        tree.each do |level,panel_levels|
          if panel_levels.size > 1 then
            panel_levels.each do |panel|
              flat_tree.store("Stage #{level}#{(64+panel.sequence).chr}", panel.skills)
            end
          else
            panel_levels.each do |panel|
              flat_tree.store("Stage #{level}", panel.skills)
            end
          end
        end
        tree.clear
        flat_tree
      else
        tree
      end
    end
    def skills
      self.panels.map(&:skills).flatten + self.memory
    end
    def skill_effect_steps
      return @_cache_vattr[:skill_effect_steps] if @_cache_vattr.key?(:skill_effect_steps)
      effects = {}
      order = []
      order = skills.select do |skill|
                next if MemorySkill === skill
                skill.link? || skill.name.start_with?(title)
              end
      order.each do |skill|
        skill.effects.each do |effect|
          (effects[effect.effect_code] ||= []) << effect.id
        end
      end
      @_cache_vattr[:skill_effect_steps] = {
        skills:      order,
        effects:     effects
      }
    end
    def icon_path
      File.join(ASSET_IMAGE_PATH, support? ? 'support_idols' : 'idols', 'icon', "#{self.id2}.png")
    end
    def image_path
      File.join(ASSET_IMAGE_PATH, support? ? 'support_idols' : 'idols', 'card', "#{self.id2}.jpg")
    end
    def fes_icon_path
      return if !fes_costume?
      File.join(ASSET_IMAGE_PATH, support? ? 'support_idols' : 'idols', 'fes_icon', "#{self.id2}.png")
    end
    def fes_image_path
      return if !fes_costume?
      File.join(ASSET_IMAGE_PATH, support? ? 'support_idols' : 'idols', 'fes_card', "#{self.id2}.jpg")
    end
    module ClassMethods
      def complete
        all.reject(&:incomplete?)
      end
    end
    class << self
      def __base_model_included(cls)
        cls.instance_exec do
          belongs_to :character, class_name: 'Chara'
        end
      end
    end
  end
end

