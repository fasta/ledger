module Ledger
  class Transaction
    attr_accessor :date, :description, :postings
    attr_reader :line_nr

    def initialize(options={})
      @date = options[:date]
      @description = options[:description]
      @line_nr = options[:line_nr]
      @postings = options[:postings] || []
    end

    def balanced?
      raise ArgumentError if postings.select {|p| p.amount.nil? }.count > 1

      sum = postings.select {|p| !p.amount.nil? }.map {|p| p.amount }.reduce(:+)
      if p = postings.select {|p| p.amount.nil?}.first
        p.amount = Amount.new(commodity: sum.commodity, quantity: (sum.quantity * -1))
        sum += p.amount
      end

      (sum.quantity == 0) ? true : false
    end

    def self.from_s(string, options={})
      tx = Transaction.new(options)

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

