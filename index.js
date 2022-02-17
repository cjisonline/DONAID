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
  const {body} = req.body;
  console.log('Request body'+req.body)
  console.log('Amount'+req.body.amount)
    // Create a PaymentIntent with the order amount and currency
  const paymentIntent = await stripe.paymentIntents.create({
    amount: 200,
    currency: 'usd',
    payment_method_types: ['card']
  });

  res.send({
    client_secret: paymentIntent.client_secret,
  });
});

app.listen(port, () => console.log("Server on port 4242"));