module SpreeStripe
  module Actions
    class BuildCustomerParams
      def call(user:)
        full_name = [user.first_name, user.last_name].compact.join(' ')

        {
          email: user.email,
          name: full_name
        }
      end
    end
  end
end
