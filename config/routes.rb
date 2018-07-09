Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # Todo: Version the APIs
  resources :images, :controller => :image_hub, :except => [:new, :edit] do
  end

  resources :directory, :controller => :directory, :except => [:new, :edit] do
  end

  match '/directory/:_directory_id/image' => 'image_hub#create', :via => :post

  match '/directory/:id' => 'directory#show', :via => :get

  match '/directory/:id/directory' => 'directory#create', :via => :post

  resources :files, :only => [:destroy, :show]
end
