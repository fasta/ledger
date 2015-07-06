# Ledger

Parses text files written in the Ledger format
([http://www.ledger-cli.org](http://www.ledger-cli.org)).

## About

A simple ruby library for parsing text files written in the Ledger format for
plain-text double-entry accounting. The library provides methods for parsing
files, calculating the totals of all accounts used in the parsed transactions,
and organising accounts as a hierarchical tree.

Be warned that this library supports only a subset of the official format. It
has been developed primarily to allow me to create reports in ruby. Thus, only
the features I was in need of have been added.

## Installation & Usage

Add the line `gem 'ledger'` to your application's Gemfile and run the `bundle
install` command. Or install the gem directly on your system with `gem install
ledger`.

To parse a journal use the `Journal` class method `parse`, which takes a string
as argument:

    journal = Ledger::Journal.parse(File.read("Journal.ledger"))

To calculate the totals of all accounts based on the transactions defined in
the journal, call the `Journal` instance method `balance`:

    accounts = journal.balance

To organise the accounts as a hierarchical tree, call the `Account` class
method `organize` with an array of accounts:

    accounts = Ledger::Account.organize(accounts)

Accounts may contain different commodities, and thus multiple amounts. This and
other attributes may be accessed as follows:

    account.name
    => 'Assets'
    account.amounts
    => [<#Ledger::Amount>]
    account.subaccounts
    => [<#Ledger::Account>]

Amounts consist of two attributes. First, a string containing the commodity
identifier (usually a currency symbol like e.g. '€', or a short commodity
identifier like e.g. 'CHF' or in the case of stocks 'AAPL'). Second, a
BigDecimal (to avoid floating point problems) representing the quantity of the
commodity.

    amount.commodity
    => '$'
    amount.quantity
    => <#BigDecimal>


## Development

For the moment this library provides most of the functionality I needed, so it
will probably stay mostly as it is today (unless you want to contribute).
Exceptions are the following features which may be added sometime in the near
future:

- Add sensible error messages to raised exceptions
- Add serialization to produce textual representations in the ledger format of
  journals and transactions


## Contributing

1. Fork it (https://github.com/[my-github-username]/ledger/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Feedback regarding code quality and other possible improvements are also
appreciated.
