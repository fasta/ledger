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
  end

end

