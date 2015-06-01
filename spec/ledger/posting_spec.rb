require 'spec_helper'


include Ledger

describe Posting do

  describe ".from_s" do
    it "should return a Posting matching the string" do
      p = Posting.from_s("Account Name    Amount")

      p.must_be_instance_of Posting
      p.account.must_equal "Account Name"
      p.amount.must_equal "Amount"
    end
  end

end
