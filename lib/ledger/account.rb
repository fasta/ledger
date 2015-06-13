module Ledger
  class Account
    attr_accessor :name, :amounts

    def initialize(options={})
      @name = options[:name] || nil
      @amounts = options[:amounts] || []
    end

    def self.from_transactions(transactions)
      raise ArgumentError unless transactions.reject(&:complete?).empty?
      raise ArgumentError unless transactions.reject(&:balanced?).empty?

      transactions.reduce([]) do |accounts, tx|
        tx.postings.each do |p|
          if account = accounts.select {|a| a.name == p.account }.first
            # Update total amount if commodity is already present
            account.amounts.map! do |a|
              (a.commodity == p.amount.commodity) ? a + p.amount : a
            end
            # Add commodity otherwise
            unless account.amounts.map(&:commodity).include?(p.amount.commodity)
              account.amounts << p.amount
            end
          else
            accounts << Account.new(name: p.account, amounts: [p.amount])
          end
        end

        accounts
      end
    end

    def ==(other)
      (name == other.name && amounts == other.amounts) ? true : false
    end

  end
end
