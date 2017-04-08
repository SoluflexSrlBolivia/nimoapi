Apipie.configure do |config|
  config.app_name                = "Nimo social"
  config.copyright               = "&copy; 2017 Nelson Garcia, nelsongarcia.info@gmail.com"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/apidoc"
  config.validate                = false
  config.reload_controllers      = Rails.env.development?
  config.app_info["1.0"] = "
    Documentacion de servicios para el app Nimo.social
  "
  # where is your API defined?
  config.api_controllers_matcher = File.join(Rails.root, "app", "controllers", "**","*.rb")
  config.api_routes              = Rails.application.routes

  # user to access API section
  config.authenticate = Proc.new do
    authenticate_or_request_with_http_basic do |username, password|
      username == "api" && password == "API0001"
    end
  end
  #config.authorize = Proc.new do |controller, method, doc|
  #  !method   # show all controller doc, but no method docs.
  #end
end
