require 'spec_helper'

module SpreeStripe
  describe Actions::BuildPaymentIntentParams, type: :model do
    let(:action) { described_class.new }

    subject { action.call(payment: payment) }

    let(:payment) { create(:payment, payment_method: payment_method, order: order) }
    let(:payment_method) { create(:spree_stripe_payment_method, auto_capture: auto_capture) }
    let(:auto_capture) { true }

    let(:order) { create(:order_with_line_items, ship_address: address, user: user, currency: currency) }
    let(:currency) { 'EUR' }

    let(:address) do
      create(:address, firstname: shipping_first_name,
                       lastname: shipping_last_name,
                       address1: shipping_address1,
                       address2: shipping_address2,
                       city: shipping_city,
                       zipcode: shipping_zipcode,
                       country: shipping_country,
                       state: shipping_state,
                       phone: shipping_phone)
    end
    let(:shipping_first_name) { 'John' }
    let(:shipping_last_name) { 'Doe' }
    let(:shipping_full_name) { 'John Doe'}
    let(:shipping_address1) { 'Krupnicza 5/6' }
    let(:shipping_address2) { 'Upside' }
    let(:shipping_city) { 'Krakow' }
    let(:shipping_zipcode) { '31-123' }
    let(:shipping_country) { Spree::Country.first }
    let(:shipping_state) { create(:state, country: shipping_country) }
    let(:shipping_phone) { '123456789' }

    let(:user) { create(:user) }

    it 'sets payment methods to automatic' do
      expect(subject[:automatic_payment_methods]).to eq({ enabled: true })
    end

    it 'sets amount and currency of the order' do
      expect(subject[:amount]).to eq(order.total * 100.to_i)
      expect(subject[:currency]).to eq(currency)
    end

    it 'sets customer shipping details' do
      expect(subject[:shipping][:address][:line1]).to eq(shipping_address1)
      expect(subject[:shipping][:address][:line2]).to eq(shipping_address2)
      expect(subject[:shipping][:address][:city]).to eq(shipping_city)
      expect(subject[:shipping][:address][:postal_code]).to eq(shipping_zipcode)
      expect(subject[:shipping][:address][:country]).to eq(shipping_country.iso)
      expect(subject[:shipping][:address][:state]).to eq(shipping_state.name)
      expect(subject[:shipping][:name]).to eq(shipping_full_name)
      expect(subject[:shipping][:phone]).to eq(shipping_phone)
    end

    context 'when payment method is set to auto capture' do
      let(:auto_capture) { true }

      it 'sets automatic capture method' do
        expect(subject[:capture_method]).to eq('automatic')
      end
    end

    context 'when payment method is set to manual capture' do
      let(:auto_capture) { false }

      it 'sets manual capture method' do
        expect(subject[:capture_method]).to eq('manual')
      end
    end

    context 'when the checkout was initiated by a guest user' do
      let(:user) { nil }

      it 'returns nil in the customer field' do
        expect(subject[:customer]).to be_nil
      end
    end

    context 'when the checkout was initiated by a signed-in user' do
      context 'when the user has a stripe customer id assigned for the payment method' do
        let(:user) { create(:user, stripe_customer_id: { payment_method.id => stripe_customer_id })}
        let(:stripe_customer_id) { 'su_test_user_id' }

        it 'returns the stripe customer id' do
          expect(subject[:customer]).to eq(stripe_customer_id)
        end
      end

      context 'when the user has no stripe customer id assigned for the payment method' do
        let(:user) { create(:user, stripe_customer_id: { other_payment_method_id => stripe_customer_id })}
        let(:other_payment_method_id) { payment_method.id + 1 }
        let(:stripe_customer_id) { 'su_test_user_id' }

        it 'returns nil in the customer field' do
          expect(subject[:customer]).to be_nil
        end
      end
    end
  end
end
