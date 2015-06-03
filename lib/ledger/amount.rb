module Ledger
  class Amount
    require 'bigdecimal'

    attr_accessor :commodity, :quantity

    def initialize(options={})
      @commodity = options[:commodity] || nil
      @quantity = (options[:quantity]) ? BigDecimal.new(options[:quantity].to_s) : nil
    end

    def +(other)
      raise ArgumentError unless @commodity == other.commodity

      Amount.new(commodity: @commodity, quantity: (@quantity + other.quantity))
    end

    def ==(other)
      ((@commodity == other.commodity) && (@quantity == other.quantity))
    end

    def self.from_s(string)
      pre, quantity, post = string.match(/^(.*?)([-]?[\d,\.]+)(.*?)$/).captures.map {|e| e.strip }

      # FIXME: Assume comma as thousand mark (for now)
      quantity.gsub!(',', '')

      a = Amount.new
      a.commodity = (pre.empty?) ? post : pre
      a.quantity = BigDecimal.new(quantity)
      a
    end

  end
end
