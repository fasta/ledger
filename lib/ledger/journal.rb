module Ledger
  class Journal
    attr_accessor :transactions, :accounts

    def initialize(options={})
      @accounts = options[:accounts] || []
      @transactions = options[:transactions] || []
    end

    def balance
      raise ArgumentError unless valid?

      aliases = accounts.map(&:alias).compact

      Account.from_transactions(transactions).map do |account_total|
        if aliases.include?(account_total.name)
          a = accounts.select {|a| a.alias == account_total.name }.first.clone

          # The amounts of the declared accounts can be set without regard for
          # the pre-existing value because these accounts are created from the
          # 'account' command directive, which can not specify amounts.
          # Amounts are calculated only from transactions involving the account
          # name. Also aggregating amounts of subaccounts happens in the
          # Account.organise class method.
          a.amounts = account_total.amounts
          a
        elsif aliases.include?(account_total.name.split(':', 2).first)
          _alias, name = account_total.name.split(':', 2)
          name = "#{accounts.select {|a| a.alias == _alias }.first.name}:#{name}"

          a = accounts.select {|a| a.name == name }.first.clone
          # See comment above
          a.amounts = account_total.amounts
          a
        else
          account_total
        end
      end
    end

    def valid?
      transactions_balanced? && undefined_account_names.empty?
    end

    def transactions_balanced?
      transactions.all?(&:balanced?)
    end

    def undefined_account_names
      account_names = transactions.map {|tx| tx.postings.map(&:account_name) }.flatten
      # Remove all defined account names
      account_names -= accounts.map(&:name)
      # Remove all names that are (or start with) a known alias
      account_names.reject {|a| accounts.map(&:alias).include?(a.split(':', 2).first) }
    end

    # Parses the given representations of command directives and transactions,
    # and creates a journal object.
    #
    # @note This method is not necessarily efficient performance-wise. It first
    #   splits the provided string into blocks of directives/transactions, which
    #   are then iterated over once for directives and once for transactions
    #   (which is when the parsing happens). This may have been handled more
    #   efficiently, but at a cost to readability. It is assumed that most ledger
    #   files will not be large enough for this to matter, which is why the more
    #   readable way has been chosen.
    def self.parse(string)
      journal = Journal.new

      # Group lines in blocks, representing a command directive, comment or
      # transaction
      blocks = parse_to_blocks(string)

      # Parse blocks
      journal.accounts = blocks.select {|line, block| block =~ /^account / }
        .map {|line, block| Account.from_s(block) }
      journal.transactions = blocks.select {|line, block| block =~ /^\d{4}\/\d{2}\/\d{2} / }
        .map {|line, block| Transaction.from_s(block, line_nr: line) }

      journal
    end

    def self.parse_to_blocks(string)
      blocks = {}
      block = nil
      nr = 0

      string.split("\n").each_with_index do |line, i|
        if line =~ /^\S+/
          blocks[nr] = block if block

          block = line
          nr = i + 1
        else
          block += "\n" + line if block
        end
      end 
      blocks[nr] = block if block

      blocks
    end

  end
end
