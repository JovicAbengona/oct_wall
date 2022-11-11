Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
        origins 'thewall.localhost.com:3000'
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post]
    end
end