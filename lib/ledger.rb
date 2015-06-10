require 'rubygems'
require 'bundler/setup'


libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)


require 'ledger/journal'
require 'ledger/transaction'
require 'ledger/posting'
require 'ledger/amount'



module Ledger

  def self.balance(transactions)
    raise ArgumentError unless transactions.select {|t| !t.complete? }.empty?
    raise ArgumentError unless transactions.select {|t| !t.balanced? }.empty?

    transactions.reduce({}) do |accounts, tx|
      tx.postings.each do |p|
        accounts[p.account] = (accounts[p.account]) ? accounts[p.account] + p.amount : p.amount
      end

      accounts
    end
  end

end

