module SpreeStripe
  module Handlers
    class ProcessWebhook
      def initialize(
        process_charge_succeeded: ::SpreeStripe::Handlers::ProcessChargeSucceeded.new,
        process_payment_failed: ::SpreeStripe::Handlers::ProcessPaymentFailed.new
      )
        @process_charge_succeeded = process_charge_succeeded
        @process_payment_failed = process_payment_failed
      end

      def call(event:)
        object = event.data.object
        case event.type
        when 'charge.succeeded'
          @process_charge_succeeded.call(object: object)
        when 'payment_intent.payment_failed'
          @process_payment_failed.call(object: object)
        end
      end
    end
  end
end
