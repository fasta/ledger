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
  end

end

