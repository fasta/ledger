require 'spec_helper'


include Ledger

describe Transaction do

  describe ".from_s" do
    it "should return a Transaction matching the given string" do
      tx = Transaction.from_s(<<EoT
2015/05/30 Description
  Account   Amount
  Account
EoT
)
      tx.must_be_instance_of Transaction
      tx.date.must_equal Date.new(2015, 05, 30)
      tx.description.must_equal "Description"
      tx.postings.count.must_equal 2
    end
  end

end

