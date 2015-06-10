require 'spec_helper'


include Ledger

describe Ledger do

  describe ".balance" do
    it "should raise an ArgumentError if a Transaction is incomplete" do
      txs = [
        Transaction.new(postings: [Posting.from_s('Assets   $100.00'),
                                   Posting.from_s('Equity')]).complete!,
        Transaction.new(postings: [Posting.from_s('Expenses   $75.00'),
                                   Posting.from_s('Assets')])
      ]

      -> { Ledger.balance(txs) }.must_raise ArgumentError
    end

    it "should raise an ArgumentError if a Transaction is not balanced" do
      txs = [
        Transaction.new(postings: [Posting.from_s('Assets   $100.00'),
                                   Posting.from_s('Equity')]).complete!,
        Transaction.new(postings: [Posting.from_s('Expenses   $75.00'),
                                   Posting.from_s('Assets   $-65.00')])
      ]
      -> { Ledger.balance(txs) }.must_raise ArgumentError
    end

    it "should return a Hash of the accounts as key and the total Amount as value" do
      txs = [
        Transaction.new(postings: [Posting.from_s('Assets   $100.00'),
                                   Posting.from_s('Equity')]).complete!,
        Transaction.new(postings: [Posting.from_s('Expenses   $75.00'),
                                   Posting.from_s('Assets')]).complete!
      ]

      Ledger.balance(txs).must_equal({
        'Assets' => Amount.from_s('$25.00'),
        'Expenses' => Amount.from_s('$75.00'),
        'Equity' => Amount.from_s('$-100.00')
      })
    end

    it "should return a Hash including super-accounts" do
      txs = [
        Transaction.new(postings: [Posting.from_s('Assets:Bank:Bank A   $100.00'),
                                   Posting.from_s('Assets:Bank:Bank B   $200.00'),
                                   Posting.from_s('Equity:Opening Balances')]).complete!,
        Transaction.new(postings: [Posting.from_s('Expenses   $75.00'),
                                   Posting.from_s('Assets:Bank:Bank A')]).complete!
      ]

      Ledger.balance(txs).must_equal({
        'Assets' => Amount.from_s('$225.00'),
        'Assets:Bank' => Amount.from_s('$225.00'),
        'Assets:Bank:Bank A' => Amount.from_s('$25.00'),
        'Assets:Bank:Bank B' => Amount.from_s('$200.00'),
        'Equity' => Amount.from_s('$-300.00'),
        'Equity:Opening Balances' => Amount.from_s('$-300.00'),
        'Expenses' => Amount.from_s('$75.00')
      })
    end
  end

  describe ".account_hierarchy" do
    it "should return an Array of each individual account contained in the name" do
      Ledger.account_hierarchy('Assets').must_equal ['Assets']

      Ledger.account_hierarchy('Assets:Checking').must_equal [
        'Assets',
        'Assets:Checking'
      ]

      Ledger.account_hierarchy('Assets:Checking:Business').must_equal [
        'Assets',
        'Assets:Checking',
        'Assets:Checking:Business'
      ]
    end
  end

end

