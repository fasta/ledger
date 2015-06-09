require 'spec_helper'


include Ledger

describe Journal do

  describe "#balance" do
    it "should return a Hash with the account name as key and the total Amount as value" do
      j = Journal.parse(<<EoT
2015/06/08 Opening balances
  Assets:Checking   $100.00
  Equity:Opening Balances
2015/06/09 Buying groceries somewhere
  Expenses:Food   $75.00
  Assets:Checking
EoT
)

      j.balance.must_equal({
        'Assets:Checking' => Amount.from_s('$25.00'),
        'Equity:Opening Balances' => Amount.from_s('$-100.00'),
        'Expenses:Food' => Amount.from_s('$75.00')
      })
    end
  end

  describe ".parse_to_blocks" do
    it "should return a Hash of the blocks within the provided string with the line number as key" do
      blocks = Journal.parse_to_blocks(<<EoT
Block 1
Block 2
Block 3
EoT
)
      blocks.must_equal({ 1 => "Block 1", 2 => "Block 2", 3 => "Block 3" })

      blocks = Journal.parse_to_blocks(<<EoT
Block 1
Block 2
  2.1
  2.2
Block 3
EoT
)
      blocks.must_equal({ 1 => "Block 1", 2 => "Block 2\n  2.1\n  2.2", 5 => "Block 3" })
    end
  end

  describe ".parse" do
    it "should return the parsed Journal" do
      j = Journal.parse(<<EoT
2015/05/30 Description
  Account   $1
  Account
EoT
)
      j.transactions.count.must_equal 1
      j.transactions.first.line_nr.must_equal 1
    end
  end

end
