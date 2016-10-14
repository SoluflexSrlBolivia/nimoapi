# tell the I18n library where to find your translations
#I18n.load_path += Dir[Rails.root.join('lib', 'locale', '*.{rb,yml}')]
 
#I18n.config.reload_on_each_request = true
I18n.config.enforce_available_locales = true
I18n.config.available_locales = :en, :es, :pt
# set default locale to something other than :en
I18n.default_locale = :en