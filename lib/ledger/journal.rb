module Ledger
  class Journal
    attr_accessor :transactions, :accounts

    def initialize(options={})
      @accounts = options[:accounts] || []
      @transactions = options[:transactions] || []
    end

    def valid?
      accounts_balanced = transactions.reduce(true) {|mem, tx| (mem) ? tx.balanced? : false }

      accounts_defined = (transactions.map {|tx| tx.postings.map(&:account_name) }.flatten -
        accounts.map(&:name)).empty?

      accounts_balanced && accounts_defined
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
