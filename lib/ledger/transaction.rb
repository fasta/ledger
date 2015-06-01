module Ledger
  class Transaction
    attr_accessor :date, :description, :postings

    def initialize
      @postings = []
    end

    def self.from_s(string)
      tx = Transaction.new

      head, body = string.split("\n", 2)

      tx.date, tx.description = head.split(" ", 2)
      tx.date = Date.parse(tx.date)

      body.split("\n").map {|e| e.strip }.each do |line|
        tx.postings << Posting.from_s(line)
      end

      tx
    end

  end
end

