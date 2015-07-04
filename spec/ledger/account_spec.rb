require 'spec_helper'


include Ledger

describe Account do

  describe "#initialize" do
    it "should return an Account initialized with the given options or nil" do
      a = Account.new
      a.name.must_be_nil
      a.amounts.must_equal []
      a.subaccounts.must_equal []
      a.alias.must_equal nil

      a = Account.new(name: 'Account Name',
                      amounts: [Amount.from_s('CHF 1.00')],
                      subaccounts: [Account.new(name: 'Subaccount')],
                      alias: 'Alias')
      a.name.must_equal 'Account Name'
      a.amounts.must_equal [Amount.from_s('CHF 1.00')]
      a.subaccounts.first.must_equal Account.new(name: 'Subaccount')
      a.alias.must_equal 'Alias'
    end
  end

  describe "#total_amounts" do
    it "should return the amounts if there are no subaccounts" do
      a = Account.new(amounts: [Amount.from_s('$100.00'), Amount.from_s('50 AAPL')])

      a.total_amounts.must_equal [
        Amount.from_s('$100.00'),
        Amount.from_s('50 AAPL')
      ]
    end

    it "should return the total of the amounts and the total_amounts of the subaccounts" do
      a = Account.new(amounts: [Amount.from_s('$100.00')],
                      subaccounts: [
                        Account.new(amounts: [Amount.from_s('$50.00')],
                                    subaccounts: [
                                      Account.new(amounts: [Amount.from_s('$25.00')])
                                    ]),
                        Account.new(amounts: [Amount.from_s('50 AAPL')])
                      ])

      a.total_amounts.must_equal [
        Amount.from_s('$175.00'),
        Amount.from_s('50 AAPL')
      ]
    end
  end

  describe "#==" do
    it "should return true if all attributes equal each other" do
      a = Account.new
      b = Account.new

      (a == b).must_equal true
    end

    it "should return false if just one attribute differs" do
      a = Account.new(name: 'A')
      b = Account.new(name: 'B')

      (a == b).must_equal false
    end

    it "should check all attributes"
  end

  describe ".organize" do
    it "should raise an ArgumentError if two Accounts with the same name are provided" do
      accounts = [
        Account.new(name: 'Assets'),
        Account.new(name: 'Assets'),
        Account.new(name: 'Equity')
      ]

      -> { Account.organize(accounts) }.must_raise ArgumentError
    end

    it "should organize the Accounts hierarchically" do
      accounts = [
        Account.new(name: 'Assets:Bank:BankA'),
        Account.new(name: 'Assets:Bank:BankB'),
        Account.new(name: 'Assets:Cash'),
        Account.new(name: 'Equity')
      ]

      Account.organize(accounts).must_equal [
        Account.new(name: 'Assets', subaccounts: [
          Account.new(name: 'Bank', subaccounts: [
            Account.new(name: 'BankA'),
            Account.new(name: 'BankB')]),
          Account.new(name: 'Cash')]),
        Account.new(name: 'Equity')
      ]
    end

    it "should set the amounts of the Accounts" do
      accounts = [
        Account.new(name: 'Assets:Bank:BankA', amounts: [Amount.from_s('$100.00')]),
        Account.new(name: 'Assets:Bank:BankB', amounts: [Amount.from_s('CHF 100.00')]),
        Account.new(name: 'Equity', amounts: [Amount.from_s('$-100.00'),
                                              Amount.from_s('CHF -100.00')])
      ]

      Account.organize(accounts).must_equal [
        Account.new(name: 'Assets', subaccounts: [
          Account.new(name: 'Bank', subaccounts: [
            Account.new(name: 'BankA', amounts: [Amount.from_s('$100.00')]),
            Account.new(name: 'BankB', amounts: [Amount.from_s('CHF 100.00')])
            ])
        ]),
        Account.new(name: 'Equity', amounts: [Amount.from_s('$-100.00'),
                                              Amount.from_s('CHF -100.00')])
      ]
    end
  end
  
  describe ".from_transactions" do
    it "should raise an ArgumentError if a Transaction is incomplete" do
      txs = [
        Transaction.new(postings: [Posting.from_s('Assets   $100.00'),
                                   Posting.from_s('Equity')]).complete!,
        Transaction.new(postings: [Posting.from_s('Expenses   $75.00'),
                                   Posting.from_s('Assets')])
      ]

      -> { Account.from_transactions(txs) }.must_raise ArgumentError
    end

    it "should raise an ArgumentError if a Transaction is not balanced" do
      txs = [
        Transaction.new(postings: [Posting.from_s('Assets   $100.00'),
                                   Posting.from_s('Equity')]).complete!,
        Transaction.new(postings: [Posting.from_s('Expenses   $75.00'),
                                   Posting.from_s('Assets   $-65.00')])
      ]

      -> { Account.from_transactions(txs) }.must_raise ArgumentError
    end

    it "should return an Array of Accounts with calculated amounts" do
      txs = [
        Transaction.new(postings: [Posting.from_s('Assets   $100.00'),
                                   Posting.from_s('Equity')]).complete!,
        Transaction.new(postings: [Posting.from_s('Expenses   $75.00'),
                                   Posting.from_s('Assets')]).complete!
      ]

      Account.from_transactions(txs).must_equal [
        Account.new(name: 'Assets', amounts: [Amount.from_s('$25.00')]),
        Account.new(name: 'Equity', amounts: [Amount.from_s('$-100.00')]),
        Account.new(name: 'Expenses', amounts: [Amount.from_s('$75.00')])
      ]
    end

    it "should calculate different commodities in one account separately" do
      txs = [
        Transaction.new(postings: [Posting.from_s('Assets   $100.00'),
                                   Posting.from_s('Assets   40 AAPL @ $1.00'),
                                   Posting.from_s('Equity')]).complete!,
        Transaction.new(postings: [Posting.from_s('Expenses   $75.00'),
                                   Posting.from_s('Assets')]).complete!
      ]

      Account.from_transactions(txs).must_equal [
        Account.new(name: 'Assets', amounts: [Amount.from_s('$25.00'),
                                             Amount.from_s('40 AAPL')]),
        Account.new(name: 'Equity', amounts: [Amount.from_s('$-140.00')]),
        Account.new(name: 'Expenses', amounts: [Amount.from_s('$75.00')])
      ]
    end
  end

  describe ".from_s" do
    it "should return an Account matching the string" do
      str = <<-EoT
      account Assets:Bank
        alias Bank
      EoT
      a = Account.from_s(str)

      a.must_be_instance_of Account
      a.name.must_equal 'Assets:Bank'
      a.alias.must_equal 'Bank'
    end
  end

end

