Installation
-----------
run

    gem install netaxept

or include in your _Gemfile_:

    gem 'netaxept'

Usage
-----

To interact with Nets you need to create an instance of `Netaxept::Service` with your credentials:

    service = Netaxept::Service.new(<merchant id>, <token>, :test|:production)

### General

Every operation except register returns on success.
The `register` operation returns an object containing `transaction_id` and a `terminal_url`.
In case of errors the operations will raise exceptions with the error message.
The exceptions are explained in the [nets documentation](http://www.betalingsterminal.no/Netthandel-forside/Teknisk-veiledning/API/Exceptions/).
All exceptions are subclasses of Netaxept::Error, if you need to catch all errors in one.

### Off-site payment workflow

The following applies for the _Nets hosted_ service type where the user is redirect to the
Nets site to enter her payment details (see the
[Nets docs](http://www.betalingsterminal.no/Netthandel-forside/Teknisk-veiledning/Overview/)
for details).

#### Registering a payment

    service.register({
      amount: <amount in cents>,
      orderNumber: <order number>,
      currencyCode: <3 letter ISO code>,
      redirectUrl: <url the terminal should return the user to on completion>
    })

These are the required options.

On success the response object gives you a `transaction_id` and a `terminal_url`.

For details on the options see http://www.betalingsterminal.no/Netthandel-forside/Teknisk-veiledning/API/Register/

#### Completing a payment

After the user has authorized the payment on the Nets site he is redirected to the `redirectUrl` you provided. Nets adds a `resonseCode` and `transactionId` parameter to the URL. To finalize the payment you call `sale` on the service.

    service.sale <transaction id>, <amount in cents>

The method returns if it was successful and raises an Exception (mentioned under _General_) if unsuccessful.

Congratulations, you have processed a payment.

Testing
-------

To run the tests:

    $ bundle
    $ MERCHANT_ID=<your merchant id> NETAXEPT_TOKEN=<your token> rake
