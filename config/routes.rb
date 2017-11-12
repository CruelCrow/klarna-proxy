Rails.application.routes.draw do
  get 'search', to: 'search#search', defaults: {format: 'json'}
end
