const express = require("express");
const port = process.env.PORT || 3000
const app = express();
// This is a public sample test API key.
// Don’t submit any personally identifiable information in requests made with this key.
// Sign in to see your own test API key embedded in code samples.
const stripe = require("stripe")('sk_test_51KTuiGEvfimLlZrspSXbovMmnyU9eJsrzUOSatcAYvz3AfLDE5QcgPOX6oPN6FuzKVhBOETTWiNFWLRVoTm0OURb00HhwsIFwH');

app.use(express.static("public"));
app.use(express.json());

app.post("/create-payment-intent", async (req, res) => {
    // Create a PaymentIntent with the order amount and currency
  const paymentIntent = await stripe.paymentIntents.create({
    amount: req.body.amount,
    currency: req.body.currency,
    payment_method_types: req.body.payment_method_types
  });

  res.send({
    client_secret: paymentIntent.client_secret,
  });
});

app.post("/create-new-customer", async (req, res) => {
  // Create a PaymentIntent with the order amount and currency
  const customer = await stripe.customers.create({
    description: 'New customer',
  });

res.send({
  id: customer.id,
});
});

app.post("/create-payment-method", async (req, res) => {
  // Create a PaymentIntent with the order amount and currency
const paymentMethod = await stripe.paymentMethods.create({
  type: 'card',
  card:{
    number: req.body.number,
    exp_month: req.body.exp_month,
    exp_year: req.body.exp_year,
    cvc: req.body.cvc
  }
});

res.send({
  id: paymentMethod.id,
});
});

app.post("/attach-payment-method", async (req, res) => {
  // Create a PaymentIntent with the order amount and currency
  const paymentMethod = await stripe.paymentMethods.attach(
    req.body.paymentMethod,
    {customer: req.body.customer}
  );

res.send({
  id: paymentMethod.id,
});
});

app.post("/update-customer", async (req, res) => {
  // Create a PaymentIntent with the order amount and currency
  const paymentMethod = await stripe.customers.update(
    req.body.customer,
    {
      invoice_settings:{
        default_payment_method: req.body.default_payment_method
      }
    }
  );

res.send({
  id: paymentMethod.id,
});
});

app.post("/create-subscription", async (req, res) => {
  // Create a PaymentIntent with the order amount and currency
  const stripe = require('stripe')('sk_test_4eC39HqLyjWDarjtT1zdp7dc');

const subscription = await stripe.subscriptions.create({
  customer: req.body.customer,
  items: [
    {
      price: price_1Kky9GEvfimLlZrsVltR7krH,
      quantity: req.body.quantity
    },
  ],
});

req.send({
  id: subscription.id
})
});



app.listen(port, () => console.log("Server on port 4242"));