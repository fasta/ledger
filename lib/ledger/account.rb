module Ledger
  class Account
    attr_accessor :name, :amounts, :alias
    attr_accessor :subaccounts

    def initialize(options={})
      @name = options[:name] || nil
      @amounts = options[:amounts] || []
      @subaccounts = options[:subaccounts] || []
    end

    def total_amounts
      totals = subaccounts.map(&:total_amounts).flatten + amounts

      totals.reduce([]) do |total, amount|
        unless total.map(&:commodity).include?(amount.commodity)
          total << amount
        else
          total.map! {|t| (t.commodity == amount.commodity) ? t + amount : t }
        end

        total
      end
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

    def self.from_s(string)
      a = Account.new

      lines = string.split("\n").map(&:strip)

      a.name = lines.shift.split(' ', 2).last

      _alias = lines.select {|l| l.start_with?('alias ') }.first
      a.alias = _alias.split(' ', 2).last if _alias

      a
    end

    def ==(other)
      if self.name == other.name &&
         self.amounts == other.amounts &&
         self.subaccounts == other.subaccounts &&
         self.alias == other.alias
        true
      else
        false
      end
    end

  end
end
