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

    def complete?
      (postings.select {|p| p.amount.nil? }.empty?) ? true : false
    end

    def complete!
      raise ArgumentError if postings.select {|p| p.amount.nil? }.count > 1

      sum = postings.select {|p| !p.amount.nil? }.map {|p| p.price }.reduce(:+)

      if elided = postings.select {|p| p.amount.nil? }.first
        elided.amount = Amount.new(commodity: sum.commodity,
                                   quantity: (sum.quantity * -1))
      end

      self
    end

    def balanced?
      elided_amounts = postings.select {|p| p.amount.nil? }.count
      raise ArgumentError if elided_amounts > 1
      complete! if elided_amounts == 1

      sum = postings.map {|p| p.price }.reduce(:+)

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

      raise ArgumentError unless tx.balanced?
      tx
    end

  end
end

