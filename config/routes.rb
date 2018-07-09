Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # Todo: Version the APIs

  match '/image/:id' => 'image_hub#show', :via => :get

  match '/directory/:directory_id/image' => 'image_hub#create', :via => :post

  match '/directory/:id' => 'directory#show', :via => :get

  match '/directory/:id/directory' => 'directory#create', :via => :post

end
