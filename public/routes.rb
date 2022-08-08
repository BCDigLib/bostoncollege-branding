Rails.application.routes.draw do
  get  '/faq',  to: 'static#faq'
end

Rails.application.routes.draw do
  get '/sitemap', to: 'sitemap#generate'
end