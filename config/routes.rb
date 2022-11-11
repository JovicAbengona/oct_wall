Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # Landing Page
  root "users#signup"

  # User Routes
  get "/signup"  => "users#signup"
  get "/signin"  => "users#signin"
  get "/signout" => "users#signout"

  scope "/users" do
    post "/create_user" => "users#create_user"
    post "/get_user"    => "users#get_user"
  end

  # Message Routes
  scope "/messages" do
    get "/" => "messages#index"

    post "/create_message" => "messages#create_message"
    post "/update_message" => "messages#update_message"
  end

  # Comments Routs
  scope "/comments" do
    post "/create_comment" => "comments#create_comment"
    post "/update_comment" => "comments#update_comment"
  end
end
