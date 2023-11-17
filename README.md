# SpreeStripe

This extension adds support for modern Stripe APIs, that enable support for Stripe Payment Element.

> It's currently in beta, and will be moved to spree-contrib once it becomes ready for production use

TODO: Add screenshot
TODO: Add badges

## Installation

1. Add this extension to your Gemfile with this line:

    ```ruby
    gem 'spree_stripe'
    ```

2. Install the gem using Bundler

    ```ruby
    bundle install
    ```

3. Copy & run migrations

    ```ruby
    bundle exec rails g spree_stripe:install
    ```

4. Restart your server

  If your server was running, restart it so that it can find the assets properly.

## Configuring Stripe Payment Element

1. In the admin panel, create a new Payment Method of type `SpreeStripe::PaymentElementGateway`
2. Go to (Stripe's dashboard)[https://dashboard.stripe.com] -> Developers and
    - Navigate to the `Webhooks` tab and create a new webhook pointing to `https://{your_domain}/api/stripe/webhook?payment_method_id={the_id_of_the_newly_created_payment_method}`
    - Set the webhook to respond only to the following events: `charge.succeeded`, `payment_intent.payment_failed`
3. Set the following configuration options for the newly created payment method in Spree:
    - `Secret Key`: Copy from Stripe Dashboard -> API Keys
    - `Publishable Key`: Copy from Stripe Dashboard -> API Keys
    - `Webhook Signing Secret`: In the Stripe Dashboard -> Webhook settings, you'll find an option to `Reveal` the Signing Secret. Copy if from there
    - `Server`: Set to `test` or `live`

## Using Spree Stripe with a custom Rails storefront

By default SpreeStripe will inject itself into spree_rails_storefront default UI. To see the implementation, take a look at `app/views/checkout/payment/spree_payment_element.html.erb`.
If you'd like to use the gateway with your custom Rails-based frontend, you can take the following steps:

1. In the checkout process, add the following JS include tag where you'd like to use Stripe Payment Element:

```ruby
<%= javascript_include_tag 'spree_stripe/checkout', data: { turbo_track: 'reload' } %>
```

You'll also need to add Stripe's SDK directly:

```html
<script src="https://js.stripe.com/v3/"></script>
```

2. Create an element to attach the payment element to it:

```html
<form id="checkoutForm">
    <div id="stripeMountPoint"></div>

    <input type="submit" value="Pay" />
</form>
```

3. Add a script that will initialize Spree Stripe with the order token and attach it to the dom element created above:
```html
<script>
  const configuration = {};
  const spreeStripe = new window.SpreeStripe('<%= order.token %>', configuration);
  const paymentMethodId = '<%= payment_method.id %>';
  const setupOptions = {
    paymentMethodId: '<%= payment_method.id %>',
    mountNodeId: 'stripeMountPoint',
    publishableKey: '<%= payment_method.preferences[:publishable_key] %>',
    formId: 'checkoutForm',
    stripeAppearance: {},
    stripeOptions: {}
  };
  spreeStripe.setupPaymentElement(setupOptions);
</script>
```

This will also override the process of form submission to use Stripe. In case you'd like to revert default form submission method (e.g. after the customer selects a different payment method), you can use the following:
```js
spreeStripe.cleanupPaymentElement(setupOptions);
```

4. Create a separate page that displays a "Waiting for your payment" message:
```html
<h1>Waiting for your payment</h1>

<script>
  const configuration = {};
  const spreeStripe = new window.SpreeStripe('<%= order.token %>', configuration);
  spreeStripe.waitForPayment();
</script>
```

### Configuration options

`configuration`:
- `paymentIntentStatusEndpoint: string` - a GET endpoint that returns the status of the payment (defaults to `'/api/stripe/payment_intents'`)
- `paymentIntentCreateEndpoint: string` - a POST endpoint that creates a new payment intent and returns its secret key to the client (defaults to `'/api/stripe/payment_intents'`)
- `buildStripeReturnUrl: (options: SetupOptions)` - a lambda that generates a waiting for payment page URL for Stripe to return to (defaults to `(_options) => \`${window.location.origin}/stripe/payments/waiting\``)
- `buildOrderConfirmationPath: (orderNumber: string) => string` - a lambda that generates an URL to the order confirmation page after a successful payment (defaults to `(orderNumber) => `/orders/${orderNumber}`)

Available `setupOptions`:
- `paymentMethodId: string` - the payment method id in Spree
- `mountNodeId: string` - id of the DOM element that Stripe Payment Element should be attached to
- `publishableKey: string` - Stripe's publishable key configured for the payment method
- `formId: string` - id of the form element that should handle submission of the payment element
- `stripeAppearance: object` - (appearance options passed directly to Stripe Payment Element)[https://stripe.com/docs/elements/appearance-api]
- `stripeOptions: object` - (options passed directly to Stripe Payment Element)[https://stripe.com/docs/payments/payment-element#options]


## Using Spree Stripe with Headless checkout

Spree Stripe provides two endpoints that can be used for orchestrating creation of the payment intent from a headless storefront.

1. `POST /api/stripe/payment_intents` - creates a new payment intent (which also invalidates previously created ones) and returns `stripe_payment_intent_client_secret` that can be used to initialize Stripe Payment Element in the UI. This endpoint requires an `X-Spree-Order-Token` header.
2. `GET /api/stripe/payment_intents` - returns status of the payment in the `state` field. When set to `completed` or `pending`, the payment has been confirmed on Stripe's end and the storefront can proceed to the order confirmation.

## Testing

First bundle your dependencies, then run `rake`. `rake` will default to building the dummy app if it does not exist, then it will run specs. The dummy app can be regenerated by using `rake test_app`.

```shell
bundle update
bundle exec rake
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_stripe/factories'
```

## Releasing

```shell
bundle exec gem bump -p -t
bundle exec gem release
```

For more options please see [gem-release README](https://github.com/svenfuchs/gem-release)

## Contributing

If you'd like to contribute, please take a look at the
[instructions](CONTRIBUTING.md) for installing dependencies and crafting a good
pull request.

Copyright (c) 2023 Upside Lab sp. z o.o., released under the New BSD License
