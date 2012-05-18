[![Build Status](https://secure.travis-ci.org/Hakon/netaxept.png)](http://travis-ci.org/Hakon/netaxept)

Installation
-----------
run

    gem install netaxept

or include in your _Gemfile_:

    gem 'netaxept'

Testing
-------

To run the tests:

    $ bundle
    $ rake

Usage
-----

First step is to tell Netaxept your credentials and the desired mode:

    Netaxept::Service.authenticate <merchant id>, <token>
    Netaxept::Service.environment =  :test|:production

To interact with Netaxept you need to create an instance of `Netaxept::Service`:

    service = Netaxept::Service.new

### General

Every request returns a `Netaxept::Response` object, which has a `success?` method.
In case of an error you can call `errors`, which gives you a list of `Netaxept::ErrorMessage`s
(each with a `message`, `code`, `source` and `text`).

### Off-site payment workflow

The following applies for the _Nets hosted_ service type where the user is redirect to the
Netaxept site to enter her payment details (see the
[Netaxept docs](http://www.betalingsterminal.no/Netthandel-forside/Teknisk-veiledning/Overview/)
for details).

#### Registering a payment

    service.register <amount in cents>, <order number>, <options>

Required options are `CurrencyCode` (3 letter ISO code) and `redirectUrl`.

On success the response object gives you a `transaction_id`.
You pass that to `Netaxept::Service.terminal_url(<transaction id>)` to get the URL for redirecting the user.

For details on the options see http://www.betalingsterminal.no/Netthandel-forside/Teknisk-veiledning/API/Register/

#### Completing a payment

After the user has authorized the payment on the Netaxept site he is redirected to the `redirectUrl` you provided. Netaxept adds a `resonseCode` and `transactionId` parameter to the URL. To finalize the payment you call `sale` on the service.

    service.sale <transaction id>, <amount in cents>

The response is a `Responses::SaleResponse` which only has the `success?` and `errors` methods mentioned under _General_.

Congratulations, you have processed a payment.
