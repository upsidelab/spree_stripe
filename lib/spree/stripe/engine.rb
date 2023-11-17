module Spree
  module Stripe
    class Engine < Rails::Engine
      require 'spree/core'
      isolate_namespace Spree
      engine_name 'spree.stripe'

      # use rspec for tests
      config.generators do |g|
        g.test_framework :rspec
      end

      initializer 'spree.stripe.environment', before: :load_config_initializers do |_app|
        Spree::Stripe::Config = Spree::Stripe::Configuration.new
      end

      def self.activate
        Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
          Rails.configuration.cache_classes ? require(c) : load(c)
        end
      end

      config.to_prepare(&method(:activate).to_proc)
    end
  end
end
