
const stripe = require('stripe')('sk_test_51QihNcGAbo0iKHg8zbZkQN0J6sSLWK2OqEByUNtEY3lqd5clSZ6ibNefCY02W2mxA4fkhl6eFoWmQQwkOqiRgdrv00oTxB17dl');




exports.createPayment = async (req, res) => {
  const { amount, currency } = req.body;
  try {
    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
    });
    res.json({ clientSecret: paymentIntent.client_secret });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
};

//app.listen(3000, () => console.log('Server running on port 3000'));
