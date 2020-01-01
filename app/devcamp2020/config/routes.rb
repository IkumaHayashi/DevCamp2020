Rails.application.routes.draw do
  post '/callback' => 'lineat#callback'
end
