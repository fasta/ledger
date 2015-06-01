module Ledger
  class Journal
    attr_accessor :transactions

    def initialize
      @transactions = []
    end

    def self.parse(string)
      journal = Journal.new

      # Group lines in blocks, representing a command directive, comment or
      # transaction
      blocks = parse_to_blocks(string)

      # Parse blocks
      journal.transactions << blocks.select {|e| e =~ /^\d{4}\/\d{2}\/\d{2} / }
        .map {|e| Transaction.from_s(e) }

      journal
    end

    def self.parse_to_blocks(string)
      blocks = []
      block = nil

      string.split("\n").each do |line|
        if line =~ /^\S+/
          blocks << block if block

          block = line
        else
          block += "\n" + line if block
        end
      end 
      blocks << block if block

      blocks
    end

  end
end
