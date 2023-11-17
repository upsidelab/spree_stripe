module SpreeStripe
  module UserDecorator
    def self.prepended(base)
      if Rails::VERSION::STRING >= '7.1.0'
        base.serialize :stripe_customer_id, type: Hash, coder: YAML
      else
        base.serialize :stripe_customer_id, Hash
      end
    end
  end
end

::Spree::user_class.prepend(::SpreeStripe::UserDecorator)
