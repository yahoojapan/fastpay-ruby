# This file is part of FastPay.
#
# Copyright (c) 2015 Yahoo Japan Corporation
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.

module Fastpay
  class FastpayObject
    attr_accessor :values

    def initialize
      @values = {}
    end

    def method_missing(name, *args)
      return super unless values.key?(name.to_s)
      @values[name.to_s]
    end
  end
end
