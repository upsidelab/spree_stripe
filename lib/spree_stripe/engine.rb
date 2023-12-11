module SpreeStripe
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_stripe'

    Environment = Struct.new(:dependencies)

    config.after_initialize do |app|
      app.config.spree.payment_methods << ::SpreeStripe::PaymentElementGateway
    end

    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'spree_stripe.environment', before: :load_config_initializers do |app|
      app.config.spree_stripe = Environment.new(SpreeStripe::Dependencies.new)
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
