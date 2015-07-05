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
          a.amounts = account_total.amounts
          a
        elsif aliases.include?(account_total.name.split(':', 2).first)
          _alias, name = account_total.name.split(':', 2)
          name = "#{accounts.select {|a| a.alias == _alias }.first.name}:#{name}"

          a = accounts.select {|a| a.name == name }.first.clone
          a.amounts = account_total.amounts
          a
        else
          account_total
        end
      end
    end

    def valid?
      transactions_balanced = transactions.reduce(true) {|mem, tx| (mem) ? tx.balanced? : false }

      accounts_defined = transactions.map {|tx| tx.postings.map(&:account_name) }.flatten
      accounts_defined -= accounts.map(&:name)
      unless accounts_defined.empty?
        accounts_defined = accounts_defined.map {|a| a.split(':', 2).first } - accounts.map(&:alias)
      end
      accounts_defined = accounts_defined.empty?

      transactions_balanced && accounts_defined
    end

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
