module Ledger
  class Posting
    attr_accessor :account, :amount
    attr_accessor :commodity_price

    def self.from_s(string)
      posting = Posting.new

      posting.account, posting.amount = string.split(/\s\s+/, 2).map {|e| e.strip }
      if posting.amount
        amount, price = posting.amount.split(' @ ', 2)

        posting.amount = Amount.from_s(amount)

        if price
          posting.commodity_price = Amount.from_s(price)
        end
      end

      posting
    end

    def price
      return amount unless commodity_price

      Amount.new(commodity: commodity_price.commodity,
                 quantity: amount.quantity * commodity_price.quantity)
    end

  end
end
