require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sdf2
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths << File.join(config.root, "lib")
    config.autoload_paths += %W(#{config.root}/controllers/concerns)
    # config.autoload_paths += %W(#{config.root}/lib/servicers)

    # config.autoload_paths << Rails.root.join('datatables')
    config.autoload_paths << File.join(config.root, "datatables")



    config.autoload_paths << Rails.root.join('lib/tools')
    config.autoload_paths += Dir["#{config.root}/lib/tools"]

    config.autoload_paths << Rails.root.join('lib/tools/about')
    config.autoload_paths += Dir["#{config.root}/lib/tools/about"]

    config.autoload_paths << Rails.root.join('lib/tools/algos')
    config.autoload_paths += Dir["#{config.root}/lib/tools/algos"]

    config.autoload_paths << Rails.root.join('lib/tools/apis')
    config.autoload_paths += Dir["#{config.root}/lib/tools/apis"]

    config.autoload_paths << Rails.root.join('lib/tools/csv')
    config.autoload_paths += Dir["#{config.root}/lib/tools/csv"]

    config.autoload_paths << Rails.root.join('lib/tools/dashboards')
    config.autoload_paths += Dir["#{config.root}/lib/tools/dashboards"]

    config.autoload_paths << Rails.root.join('lib/tools/formatters')
    config.autoload_paths += Dir["#{config.root}/lib/tools/formatters"]

    config.autoload_paths << Rails.root.join('lib/tools/iterators')
    config.autoload_paths += Dir["#{config.root}/lib/tools/iterators"]

    config.autoload_paths << Rails.root.join('lib/tools/migrators')
    config.autoload_paths += Dir["#{config.root}/lib/tools/migrators"]

    config.autoload_paths << Rails.root.join('lib/tools/nokos')
    config.autoload_paths += Dir["#{config.root}/lib/tools/nokos"]

    config.autoload_paths << Rails.root.join('lib/tools/scrapers')
    config.autoload_paths += Dir["#{config.root}/lib/tools/scrapers"]

    config.autoload_paths << Rails.root.join('lib/tools/serializers')
    config.autoload_paths += Dir["#{config.root}/lib/tools/serializers"]

    config.autoload_paths << Rails.root.join('lib/tools/scrapers/act_scrapers')
    config.autoload_paths += Dir["#{config.root}/lib/tools/scrapers/act_scrapers"]

    config.autoload_paths << Rails.root.join('lib/tools/scrapers/cont_scrapers')
    config.autoload_paths += Dir["#{config.root}/lib/tools/scrapers/cont_scrapers"]

    config.autoload_paths << Rails.root.join('lib/tools/servicers')
    config.autoload_paths += Dir["#{config.root}/lib/tools/servicers"]

    config.autoload_paths << Rails.root.join('lib/tools/reports')
    config.autoload_paths += Dir["#{config.root}/lib/tools/reports"]

    config.autoload_paths << Rails.root.join('lib/tools/verifiers')
    config.autoload_paths += Dir["#{config.root}/lib/tools/verifiers"]

  end
end
