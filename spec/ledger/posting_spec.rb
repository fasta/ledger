require 'spec_helper'


include Ledger

describe Posting do

  describe "#initialize" do
    it "should initialize the Posting" do
      p = Posting.new

      p.elided?.must_equal false
    end
  end

  describe ".from_s" do
    it "should return a Posting matching the string" do
      p = Posting.from_s("Account Name    CHF 1.00")

      p.must_be_instance_of Posting
      p.account.must_equal "Account Name"
      p.amount.must_equal Amount.from_s('CHF 1.00')
      p.commodity_price.must_be_nil
    end

    it "should return a Posting with a commodity price if so specified" do
      p = Posting.from_s("Account Name    1 AAPL @ $9.95")

      p.account.must_equal "Account Name"
      p.amount.must_equal Amount.from_s('1 AAPL')
      p.commodity_price.must_equal Amount.from_s('$9.95')
    end

    it "should mark the Posting if the amount has been elided" do
      p = Posting.from_s("Account Name")

      p.account.must_equal "Account Name"
      p.amount.must_be_nil
      p.elided?.must_equal true
    end
  end

  describe "#price" do
    it "should return the amount if no commodity price is available" do
      p = Posting.from_s("Account Name    CHF 1.00")

      p.price.must_equal Amount.from_s('CHF 1.00')
    end

    it "should return an Amount equivalent to the amount in the commodity of the commodity price" do
      p = Posting.from_s("Account Name    40 AAPL @ CHF 9.95")

      p.price.must_equal Amount.from_s('CHF 398.00')
    end
  end

end
