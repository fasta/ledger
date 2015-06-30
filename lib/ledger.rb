require 'rubygems'
require 'bundler/setup'


libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)


require 'ledger/journal'
require 'ledger/transaction'
require 'ledger/posting'
require 'ledger/amount'
require 'ledger/account'



module Ledger

  def self.balance(transactions)
    raise ArgumentError unless transactions.select {|t| !t.complete? }.empty?
    raise ArgumentError unless transactions.select {|t| !t.balanced? }.empty?

    accounts = transactions.reduce({}) do |accounts, tx|
      tx.postings.each do |p|
        accounts[p.account_name] =
          (accounts[p.account_name]) ? accounts[p.account_name] + p.amount : p.amount
      end

      accounts
    end

    accounts.keys.map {|k| account_hierarchy(k) }.flatten.uniq.each do |superior|
      total = accounts.select {|name, amount| name.start_with?(superior) }
        .map {|name, amount| amount }.reduce(:+)

      accounts[superior] = total
    end

    accounts
  end

  def self.account_hierarchy(name, separator=':')
    name.split(separator).reduce([]) do |memo, part|
      if memo.last
        memo << [memo.last, part].join(':')
      else
        memo << part
      end

      memo
    end
  end

end

