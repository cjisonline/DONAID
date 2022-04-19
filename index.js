const express = require("express");
const port = process.env.PORT || 3000
const app = express();

//Stripe API key
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

  //Send the client secret back
  res.send({
    client_secret: paymentIntent.client_secret,
  });
});

app.post("/create-new-customer", async (req, res) => {
  // Create a new customer with a simple description of 'New Customer'
  const customer = await stripe.customers.create({
    description: 'New customer',
  });

  //Send back the new customer id
res.send({
  id: customer.id,
});
});

app.post("/create-payment-method", async (req, res) => {
  // Create a new payment method with the provided card information
const paymentMethod = await stripe.paymentMethods.create({
  type: 'card',
  card:{
    number: req.body.number,
    exp_month: req.body.exp_month,
    exp_year: req.body.exp_year,
    cvc: req.body.cvc
  }
});

//Send back the id of the new payment method
res.send({
  id: paymentMethod.id,
});
});

app.post("/attach-payment-method", async (req, res) => {
  // Attach a payment method to a customer with the provided payment and customer id
  const paymentMethod = await stripe.paymentMethods.attach(
    req.body.paymentMethod,
    {customer: req.body.customer}
  );

  //Send back payment method id
res.send({
  id: paymentMethod.id,
});
});

app.post("/update-customer", async (req, res) => {
  // Update the customer default payment method 
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
  // Create a new subscriptions
const subscription = await stripe.subscriptions.create({
  customer: req.body.customer, //the customer id that is subscribing
  items: [
    {
      price: 'price_1Kky9GEvfimLlZrsVltR7krH', //the subscription id - this subscription id corresponds with the price of $1 USD
      quantity: req.body.quantity //the quantity of subscriptions 
    },
  ],
});

//Send back the new subscription id
res.send({
  id: subscription.id
})
});

app.post("/cancel-subscription", async (req, res) => {
  //Cancel a subscription with the given subscription id
  //Cancelled subscription with cancel at end of billing cycle
const subscription = await stripe.subscriptions.del(
  req.body.subscription
);

res.send({
  id: subscription.id
})
});



app.listen(port, () => console.log("Server on port 4242"));