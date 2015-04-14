# This file is part of FastPay.
#
# Copyright (c) 2015 Yahoo Japan Corporation
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.

module Fastpay
  class Charge < ApiClient
    def create(params)
      post("/charges", params)
      self
    end

    def retrieve(id)
      get("/charges/#{URI.escape(id)}")
      self
    end

    def capture
      post("/charges/#{URI.escape(id)}/capture")
      self
    end

    def refund(amount = nil)
      params = {}
      params["amount"] = amount unless amount.nil?
      post("/charges/#{URI.escape(id)}/refund", params)
      self
    end

    def all
      get_list("/charges")
    end
  end
end
