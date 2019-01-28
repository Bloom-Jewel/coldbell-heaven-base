ColdbellHeaven::Engine.routes.draw do
  scope '/shinymas', format: false do
    get 'chara/:id', to: 'chara#view', constraints: {id:%r(\d+)}, as: 'chara'
    
    get 'chara/matrix', to: 'chara#view_matrix'
    
    get 'card/:id', to: 'card#view', constraints: {id:%r(\d+)}, as: 'card'
    get 'cards', to: 'card#list'
    
    get 'skill/:id', to: 'skill#view', constraints: {id:%r(\d+)}, as: 'skill'
  end
end
