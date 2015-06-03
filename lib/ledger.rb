require 'rubygems'
require 'bundler/setup'


libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)


require 'ledger/journal'
require 'ledger/transaction'
require 'ledger/posting'
require 'ledger/amount'



module Ledger; end

