# This file is part of FastPay.
#
# Copyright (c) 2015 Yahoo Japan Corporation
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.

module Fastpay
  class FastpayError < StandardError
    attr_reader :message, :body
    def initialize(message, body)
      @message = message
      @body = body
    end
  end
end
