module Ledger
  class Journal
    attr_accessor :transactions

    def initialize
      @transactions = []
    end

    def balance
      transactions.reduce({}) do |bal, tx|
        tx.postings.each do |p|
          # FIXME: Add support for multiple commodities in one account
          bal[p.account] = (bal[p.account]) ? bal[p.account] + p.amount : p.amount
        end

        bal
      end
    end

    def self.parse(string)
      journal = Journal.new

      # Group lines in blocks, representing a command directive, comment or
      # transaction
      blocks = parse_to_blocks(string)

      # Parse blocks
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
