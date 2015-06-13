require 'spec_helper'


include Ledger

describe Account do

  describe "#initialize" do
    it "should return an Account initialized with the given options or nil" do
      a = Account.new
      a.name.must_be_nil
      a.amount.must_be_nil

      a = Account.new(name: 'Account Name', amount: Amount.from_s('CHF 1.00'))
      a.name.must_equal 'Account Name'
      a.amount.must_equal Amount.from_s('CHF 1.00')
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
        Account.new(name: 'Assets', amount: Amount.from_s('$25.00')),
        Account.new(name: 'Equity', amount: Amount.from_s('$-100.00')),
        Account.new(name: 'Expenses', amount: Amount.from_s('$75.00'))
      ]
    end
  end

end

