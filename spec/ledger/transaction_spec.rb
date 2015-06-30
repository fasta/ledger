require 'spec_helper'


include Ledger

describe Transaction do

  describe "#initialize" do
    it "should initialize the Transaction with the options hash" do
      tx = Transaction.new
      tx.postings.must_equal []

      tx = Transaction.new({date: Date.today, description: 'Test', line_nr: 3})
      tx.date.must_equal Date.today
      tx.description.must_equal 'Test'
      tx.line_nr.must_equal 3
      tx.postings.must_equal []
    end
  end

  describe "#complete?" do
    it "should return true if all Postings have an Amount" do
      tx = Transaction.new(postings: [Posting.from_s('Account A   $24.00'),
                                      Posting.from_s('Account B   $-24.00')])

      tx.complete?.must_equal true
    end

    it "should return false if a Posting does not have an Amount" do
      tx = Transaction.new(postings: [Posting.from_s('Account A   $24.00'),
                                      Posting.from_s('Account B')])

      tx.complete?.must_equal false
    end
  end

  describe "#complete!" do
    it "should return the Transaction" do
      tx = Transaction.new
      tx.complete!.must_equal tx
    end

    it "should infer and set the Amount if a Posting has elided it" do
      tx = Transaction.new(postings: [Posting.from_s('Account A   $24.00'),
                                      Posting.from_s('Account B')])

      tx.complete!

      tx.postings.select {|p| p.account_name == 'Account A' }.first
        .amount.must_equal Amount.from_s('$24.00')
      tx.postings.select {|p| p.account_name == 'Account B' }.first
        .amount.must_equal Amount.from_s('$-24.00')
    end

    it "should raise an ArgumentError if the Transaction cannot be completed" do
      tx = Transaction.new(postings: [Posting.from_s('Account A   $24.00'),
                                      Posting.from_s('Account B'),
                                      Posting.from_s('Account C')])

      -> { tx.complete! }.must_raise ArgumentError
    end
  end

  describe "#balanced?" do
    it "should return true if all postings balance out" do
      str = <<-EoT
      2015/06/01 Description
        Account A   CHF 24.00
        Account B   CHF 12.00
        Account C   CHF -36.00
      EoT
      tx = Transaction.from_s(str)

      tx.balanced?.must_equal true
    end

    it "should return false if the postings do not balance out" do
      tx = Transaction.new
      tx.postings << Posting.from_s('Account A    CHF 24.00')
      tx.postings << Posting.from_s('Account B    CHF 12.00')

      tx.balanced?.must_equal false
    end

    it "should return true if exactly one posting has no amount specified (eliding amounts)" do
      str = <<-EoT
      2015/06/01 Description
        Account A   CHF 24.00
        Account B   CHF 12.00
        Account C
      EoT
      tx = Transaction.from_s(str)

      tx.balanced?.must_equal true
    end

    it "should complete! the Transaction if one  Posting has an elided Amount" do
      tx = Transaction.new(postings: [Posting.from_s('Account A   $24.00'),
                                      Posting.from_s('Account B')])

      tx.must_respond_to(:complete!)
      tx.balanced?.must_equal true
      tx.postings.select {|p| p.account_name == 'Account B' }.first
        .amount.must_equal Amount.from_s('$-24.00')
    end

    it "should raise an ArgumentError if more than one posting has no amount specified" do
      tx = Transaction.new
      tx.postings << Posting.from_s('Account A    CHF 24.00')
      tx.postings << Posting.from_s('Account B')
      tx.postings << Posting.from_s('Account C')

      -> { tx.balanced? }.must_raise ArgumentError
    end

    it "should balance a Transaction with different commodities" do
      tx = Transaction.new
      tx.postings << Posting.from_s('Account A    20 AAPL @ $19.95')
      tx.postings << Posting.from_s('Account B    $-399.00')
      tx.balanced?.must_equal true

      tx = Transaction.new
      tx.postings << Posting.from_s('Account A    20 AAPL @ $19.95')
      tx.postings << Posting.from_s('Account B    $-400.00')
      tx.balanced?.must_equal false
    end
  end

  describe ".from_s" do
    it "should return a Transaction matching the given string" do
      str = <<-EoT
      2015/05/30 Description
        Account   $1.00
        Account
      EoT

      tx = Transaction.from_s(str)

      tx.must_be_instance_of Transaction
      tx.date.must_equal Date.new(2015, 05, 30)
      tx.description.must_equal "Description"
      tx.postings.count.must_equal 2
    end

    it "should initialize the Transaction with provided options" do
      str = <<-EoT
      2015/05/30 Description
        Account   $1.00
        Account
      EoT

      tx = Transaction.from_s(str, { :line_nr => 120, :description => 'Test' })

      tx.must_be_instance_of Transaction
      tx.date.must_equal Date.new(2015, 05, 30)
      tx.description.must_equal "Description"
      tx.line_nr.must_equal 120
      tx.postings.count.must_equal 2
    end

    it "should raise an ArgumentError if the provided Transaction does not balance out" do
      str = <<-EoT
      2015/06/03 Description
        Account   $1.00
      EoT

      -> { tx = Transaction.from_s(str) }.must_raise ArgumentError
    end

    it "should complete! the Transaction if one Posting has an elided Amount" do
      str = <<-EoT
      2015/05/30 Description
        Account A   $1.00
        Account B
      EoT

      tx = Transaction.from_s(str)
      tx.postings.select {|p| p.account_name == 'Account B' }.first
        .amount.must_equal Amount.from_s('$-1.00')
    end
  end

end

