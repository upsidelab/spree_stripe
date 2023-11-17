require 'spec_helper'

module SpreeStripe
  describe Actions::BuildCustomerParams, type: :model do
    let(:action) { described_class.new }

    subject { action.call(user: user) }

    context 'when user has no name' do
      let(:user) { build(:user, first_name: nil, last_name: nil, email: 'test@example.com') }

      let(:expected_result) do
        { email: 'test@example.com', name: '' }
      end

      it 'returns a reponse with only email address' do
        expect(subject).to eq(expected_result)
      end
    end

    context 'when user has saved name' do
      let(:user) { build(:user, first_name: 'John', last_name: 'Doe', email: 'test@example.com') }

      let(:expected_result) do
        { email: 'test@example.com', name: 'John Doe' }
      end

      it 'returns a response with both email and name' do
        expect(subject).to eq(expected_result)
      end
    end
  end
end
