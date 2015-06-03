require 'spec_helper'


include Ledger

describe Amount do

  describe ".from_s" do
    it "should return an Amount matching the string" do
      a = Amount.from_s("CHF -1,234.55")

      a.must_be_instance_of Amount
      a.commodity.must_equal 'CHF'
      a.quantity.must_be_instance_of BigDecimal
      a.quantity.must_equal BigDecimal.new('-1234.55')

      # Some examples from Ledger documentation (3.4 Commodities and Currencies)
      a = Amount.from_s("$20.00")
      a.commodity.must_equal '$'
      a.quantity.must_be_instance_of BigDecimal
      a.quantity.must_equal BigDecimal.new('20.00')

      a = Amount.from_s("40 AAPL")
      a.commodity.must_equal 'AAPL'
      a.quantity.must_be_instance_of BigDecimal
      a.quantity.must_equal BigDecimal.new('40.00')
    end
  end

  describe "#initialize" do
    it "should return an Amount initialized with the given options or nil" do
      a = Amount.new
      a.commodity.must_be_nil
      a.quantity.must_be_nil

      a = Amount.new(commodity: 'CHF', quantity: 12.5)
      a.commodity.must_equal 'CHF'
      a.quantity.must_be_instance_of BigDecimal
      a.quantity.must_equal BigDecimal.new('12.5')
    end
  end

  describe "#+" do
    it "should raise an ArgumentError if the other Amount is of a different commodity" do
      a, b = Amount.from_s('CHF 20.00'), Amount.from_s('40 AAPL')

      -> { a + b }.must_raise ArgumentError
    end

    it "should return a new Amount of the same commodity added quantities" do
      a, b = Amount.from_s('CHF -20.00'), Amount.from_s('CHF 40.50')

      c = a + b
      c.commodity.must_equal 'CHF'
      c.quantity.must_equal BigDecimal.new('20.50')
    end
  end

  describe "#==" do
    it "should return true if both commodity and quantity are equal" do
      a, b = Amount.from_s('CHF 1.00'), Amount.from_s('CHF 1.00')
      (a == b).must_equal true
    end

    it "should return false if either the commodity or the quantity differ" do
      a, b = Amount.from_s('CHF 1.50'), Amount.from_s('CHF -1.50')
      (a == b).must_equal false

      a, b = Amount.from_s('CHF 1.00'), Amount.from_s('$1.00')
      (a == b).must_equal false

      a, b = Amount.from_s('CHF 1.00'), Amount.from_s('$-200.00')
      (a == b).must_equal false
    end
  end

end
