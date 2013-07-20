FM::Application.routes.draw do
  get 'ui/index'
  get 'ui/fm_config'
  root to: 'ui#index'
end
