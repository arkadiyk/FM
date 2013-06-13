FM::Application.routes.draw do
  get 'ui/index'
  root to: 'ui#index'
end
