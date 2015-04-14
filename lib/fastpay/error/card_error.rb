# This file is part of FastPay.
#
# Copyright (c) 2015 Yahoo Japan Corporation
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.

module Fastpay
  class CardError < FastpayError
    INCORRECT_NUMBER      = "incorrect_number"
    INVALID_NUMBER        = "invalid_number"
    INVALID_EXPIRY_MONTH  = "invalid_expiry_month"
    INVALID_EXPIRY_YEAR   = "invalid_expiry_year"
    INVALID_CVC           = "invalid_cvc"
    INVALID_WALLET        = "invalid_wallet"
    EXPIRED_CARD          = "expired_card"
    INCORRECT_CVC         = "incorrect_cvc"
    CARD_DECLINED         = "card_declined"
    MISSING               = "missing"
    PROCESSING_ERROR      = "processing_error"

    attr_reader :code, :message, :body
    def initialize(code, message, body)
      @code = code
      @message = message
      @body = body
    end
  end
end
