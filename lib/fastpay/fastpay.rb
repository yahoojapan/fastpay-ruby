# This file is part of FastPay.
#
# Copyright (c) 2015 Yahoo Japan Corporation
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.

module Fastpay
  class Fastpay
    attr_accessor :secret

    def initialize(secret)
      self.secret = secret
    end

    def charge
      Charge.new(secret)
    end

    def subscription
      Subscription.new(secret)
    end
  end
end
