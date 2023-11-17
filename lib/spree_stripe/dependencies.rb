require 'spree/core/dependencies_helper'

module SpreeStripe
  class Dependencies
    INJECTION_POINTS_WITH_DEFAULTS = {
      build_customer_params_service: 'SpreeStripe::Actions::BuildCustomerParams',
      build_payment_intent_params_service: 'SpreeStripe::Actions::BuildPaymentIntentParams'
    }

    include Spree::DependenciesHelper
  end
end
