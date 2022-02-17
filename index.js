const express = require("express");
const app = express();
// This is a public sample test API key.
// Don’t submit any personally identifiable information in requests made with this key.
// Sign in to see your own test API key embedded in code samples.
const stripe = require("stripe")('Bearer sk_test_51KTuiGEvfimLlZrspSXbovMmnyU9eJsrzUOSatcAYvz3AfLDE5QcgPOX6oPN6FuzKVhBOETTWiNFWLRVoTm0OURb00HhwsIFwH');

app.use(express.static("public"));
app.use(express.json());


app.post("/create-payment-intent", async (req, res) => {
  const { body } = req.body;

  // Create a PaymentIntent with the order amount and currency
  const paymentIntent = await stripe.paymentIntents.create({
    amount: body.amount,
    currency: body.current,
    payment_method_types: body.payment_method_types
  });

  res.send({
    clientSecret: paymentIntent.client_secret,
  });
});

app.listen(4242, () => console.log("Server on port 4242"));