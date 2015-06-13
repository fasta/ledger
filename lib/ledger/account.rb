module Ledger
  class Account
    attr_accessor :name, :amount

    def initialize(options={})
      @name = options[:name] || nil
      @amount = options[:amount] || nil
    end

    def self.from_transactions(transactions)
      raise ArgumentError unless transactions.reject(&:complete?).empty?
      raise ArgumentError unless transactions.reject(&:balanced?).empty?

      transactions.reduce([]) do |accounts, tx|
        tx.postings.each do |p|
          if account = accounts.select {|a| a.name == p.account }.first
            account.amount += p.amount
          else
            accounts << Account.new(name: p.account, amount: p.amount)
          end
        end

        accounts
      end
    end

    def ==(other)
      (name == other.name && amount == other.amount) ? true : false
    end

  end
end
