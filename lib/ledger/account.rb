module Ledger
  class Account
    attr_accessor :name, :amounts
    attr_accessor :subaccounts

    def initialize(options={})
      @name = options[:name] || nil
      @amounts = options[:amounts] || []
      @subaccounts = options[:subaccounts] || []
    end

    def self.organize(accounts)
      raise ArgumentError if accounts.map(&:name).uniq.count != accounts.count

      organized = []
      accounts.each do |account|

        a = account.name.split(':').reduce(nil) do |parent, child_name|
          child = Account.new(name: child_name)

          # If no parent is set, the Account name must be on the top level,
          # in which case it cannot be retrieved from the parents' subaccounts,
          # but may be retrieved from the array containing already organized
          # Accounts.
          if parent.nil?
            # Check if an Account with this name already exists. If not,
            # add a new Account for this name, else use the existing one.
            if c = organized.select {|o| o.name == child_name }.first
              child = c
            else
              organized << child
            end
          else
            # Check if an Account with this name already exists. If not,
            # add a new Account for this name, else use the existing one.
            if c = parent.subaccounts.select {|s| s.name == child_name }.first
              child = c
            else
              parent.subaccounts << child
            end
          end

          child
        end
        a.amounts = account.amounts

      end

      organized
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
      if name == other.name &&
         amounts == other.amounts &&
         subaccounts == other.subaccounts
        true
      else
        false
      end
    end

  end
end
