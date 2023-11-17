class SpreeStripe {
  constructor(orderToken, configuration) {
    this._orderToken = orderToken;
    this._configuration = {...configuration, ...this._defaultConfiguration()};
    this._stripe = null;
    this._formSubmissionListener = null;
  }

  _defaultConfiguration() {
    return {
      paymentIntentStatusEndpoint: '/api/stripe/payment_intents',
      paymentIntentCreateEndpoint: '/api/stripe/payment_intents',
      buildOrderConfirmationPath: (orderNumber) => `/orders/${orderNumber}`,
      buildStripeReturnUrl: (_options) => `${window.location.origin}/stripe/payments/waiting`
    };
  }

  async setupPaymentElement(options={}) {
    this._validatePropertyNotEmpty(options, 'paymentMethodId');
    this._validatePropertyNotEmpty(options, 'mountNodeId');
    this._validatePropertyNotEmpty(options, 'publishableKey');
    this._validatePropertyNotEmpty(options, 'formId');

    const stripe = Stripe(options.publishableKey);
    const intentResponse = await fetch(this._configuration.paymentIntentCreateEndpoint, {
      method: 'POST',
      headers: {
        'X-Spree-Order-Token': this._orderToken,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ payment_method_id: options.paymentMethodId})
    });

    const intentResponseBody = await intentResponse.json();
    const elements = stripe.elements({ clientSecret: intentResponseBody.stripe_payment_intent_client_secret, appearance: options.stripeAppearance || {} });
    const paymentElement = elements.create('payment', options.stripeOptions || {});
    paymentElement.mount(`#${options.mountNodeId}`);

    this._formSubmissionListener = async (e) => {
      e.preventDefault();

      const { error } = await stripe.confirmPayment({
        elements,
        confirmParams: {
          return_url: this._configuration.buildStripeReturnUrl(options)
        }
      });

      if (error.type === 'card_error' || error.type === 'validation_error') {
        alert(error.message);
      } else {
        alert('An unexpected error occurred.');
      }
    };

    document.querySelector(`#${options.formId}`).addEventListener('submit', this._formSubmissionListener);
  }

  cleanupPaymentElement(options) {
    this._validatePropertyNotEmpty(options, 'formId');
    document.querySelector(`#${options.formId}`).removeEventListener('submit', this._formSubmissionListener);
  }

  async waitForPayment(refreshInterval=2000) {
    const response = await fetch(this._configuration.paymentIntentStatusEndpoint, {
      method: 'GET',
      headers: {
        'X-Spree-Order-Token': this._orderToken,
        'Content-Type': 'application/json'
      }
    });

    const responseBody = await response.json();
    if (responseBody.state === 'completed' || responseBody.state === 'pending') {
      const orderNumber = responseBody.order_number;
      const newPath = this._configuration.buildOrderConfirmationPath(orderNumber);
      window.location.replace(newPath);
    } else {
      setTimeout(() => this.waitForPayment(refreshInterval), refreshInterval);
    }
  }

  _validatePropertyNotEmpty(options, property) {
    if (!options[property] || options[property].length === 0) {
      throw `Property ${property} must be provided`;
    }
  }
}

window.SpreeStripe = SpreeStripe;
