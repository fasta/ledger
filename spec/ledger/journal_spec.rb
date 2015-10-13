require 'spec_helper'


include Ledger

describe Journal do

  describe "#initialize" do
    it "should return a Journal initialized with the given options or nil" do
      j = Journal.new
      j.transactions.must_equal []
      j.accounts.must_equal []

      j = Journal.new(transactions: ['Transaction'], accounts: ['Account'])
      j.transactions.must_equal ['Transaction']
      j.accounts.must_equal ['Account']
    end
  end

  describe "#balance" do
    it "should raise an ArgumentError if the Journal is not valid" do
      j = Journal.new(transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('Account   $10.00'),
                                          Posting.from_s('Account   $-10.00')])])

      -> { j.balance }.must_raise ArgumentError
    end

    it "should return an Array of all Accounts with calculated amounts" do
      j = Journal.new(accounts: [
                        Account.new(name: 'Assets:A'),
                        Account.new(name: 'Assets:B'),
                        Account.new(name: 'Equity')],
                      transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('Assets:A    $10.00'),
                                          Posting.from_s('Assets:B    $20.00'),
                                          Posting.from_s('Equity    $-30.00')]),
                        Transaction.new(postings: [
                                          Posting.from_s('Assets:A    $5.00'),
                                          Posting.from_s('Assets:B    $-5.00')])])

      j.balance.must_equal [
        Account.new(name: 'Assets:A', amounts: [Amount.from_s('$15.00')]),
        Account.new(name: 'Assets:B', amounts: [Amount.from_s('$15.00')]),
        Account.new(name: 'Equity', amounts: [Amount.from_s('$-30.00')])
      ]
    end

    it "should expand the aliases used in the transactions to the full account name" do
      j = Journal.new(accounts: [
                        Account.new(:name => 'Assets:A', :alias => 'A'),
                        Account.new(:name => 'Assets:B', :alias => 'B'),
                        Account.new(name: 'Equity')],
                      transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('A    $10.00'),
                                          Posting.from_s('B    $20.00'),
                                          Posting.from_s('Equity    $-30.00')]),
                        Transaction.new(postings: [
                                          Posting.from_s('A    $5.00'),
                                          Posting.from_s('B    $-5.00')])])

      j.balance.must_equal [
        Account.new(name: 'Assets:A', alias: 'A', amounts: [Amount.from_s('$15.00')]),
        Account.new(name: 'Assets:B', alias: 'B', amounts: [Amount.from_s('$15.00')]),
        Account.new(name: 'Equity', amounts: [Amount.from_s('$-30.00')])
      ]
    end

    it "should expand aliases of further subdivided accounts" do
      j = Journal.new(accounts: [
                        Account.new(:name => 'Assets', :alias => 'A'),
                        Account.new(:name => 'Assets:Account A', :alias => 'SomethingElse'),
                        Account.new(:name => 'Assets:Account B'),
                        Account.new(name: 'Equity')],
                      transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('A:Account A   $10.00'),
                                          Posting.from_s('A:Account B   $20.00'),
                                          Posting.from_s('Equity    $-30.00')]),
                        Transaction.new(postings: [
                                          Posting.from_s('A:Account A   $5.00'),
                                          Posting.from_s('A:Account B   $-5.00')])])

      j.balance.must_equal [
        Account.new(name: 'Assets:Account A', alias: 'SomethingElse',
                    amounts: [Amount.from_s('$15.00')]),
        Account.new(name: 'Assets:Account B', amounts: [Amount.from_s('$15.00')]),
        Account.new(name: 'Equity', amounts: [Amount.from_s('$-30.00')])
      ]
    end
  end

  describe "#valid?" do
    it "should return false if the Journal contains unbalanced Transactions" do
      j = Journal.new(accounts: [
                        Account.new(name: 'Account A'),
                        Account.new(name: 'Account B')],
                      transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('Account A   $10.00'),
                                          Posting.from_s('Account B   $-5.00')])])

      j.valid?.must_equal false
    end

    it "should return false if the Journal contains Transactions with undefined Accounts" do
      j = Journal.new(accounts: [
                        Account.new(name: 'Account B')],
                      transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('Account A   $10.00'),
                                          Posting.from_s('Account B   $-10.00')])])

      j.valid?.must_equal false
    end

    it "should return true if the Journal's Transactions are balanced and its Accounts defined" do
      j = Journal.new(accounts: [
                        Account.new(name: 'Account A'),
                        Account.new(name: 'Account B')],
                      transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('Account A   $10.00'),
                                          Posting.from_s('Account B   $-10.00')])])

      j.valid?.must_equal true
    end
  end

  describe "#transactions_balanced?" do
    it "should return false if the Journal contains unbalanced Transactions" do
      j = Journal.new(transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('Account A   $10.00'),
                                          Posting.from_s('Account B   $-10.00')]),
                        Transaction.new(postings: [
                                          Posting.from_s('Account A   $10.00'),
                                          Posting.from_s('Account B   $-5.00')])])

      j.transactions_balanced?.must_equal false
    end

    it "should return true if all Transactions are balanced" do
      j = Journal.new(transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('Account A   $10.00'),
                                          Posting.from_s('Account B   $-10.00')]),
                        Transaction.new(postings: [
                                          Posting.from_s('Account A   $10.00'),
                                          Posting.from_s('Account B   $-10.00')])])

      j.transactions_balanced?.must_equal true
    end
  end

  describe "#undefined_account_names" do
    it "should be return a list of the names all undefined accounts used in the Transactions" do
      j = Journal.new(accounts: [
                        Account.new(name: 'Account B')],
                      transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('Account A   $10.00'),
                                          Posting.from_s('Account B   $-10.00')])])

      j.undefined_account_names.must_equal ['Account A']
    end

    it "should not return known aliases" do
      j = Journal.new(accounts: [
                        Account.new(:name => 'Account A', :alias => 'Alias'),
                        Account.new(name: 'Account B')],
                      transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('Alias   $10.00'),
                                          Posting.from_s('Account B   $-10.00')])])

      j.undefined_account_names.must_equal []
    end

    it "should not return the names of subaccounts of aliased accounts" do
      j = Journal.new(accounts: [
                        Account.new(:name => 'Account', :alias => 'Alias'),
                        Account.new(name: 'Account:A'),
                        Account.new(name: 'Account:B')],
                      transactions: [
                        Transaction.new(postings: [
                                          Posting.from_s('Alias:A   $10.00'),
                                          Posting.from_s('Account:B   $-10.00')])])

      j.undefined_account_names.must_equal []
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
account Account
  alias A

2015/05/30 Description
  Account   $1
  Account
EoT
)
      j.transactions.count.must_equal 1
      j.transactions.first.line_nr.must_equal 4
      j.accounts.count.must_equal 1
    end
  end

end
