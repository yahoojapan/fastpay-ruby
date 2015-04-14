# This file is part of FastPay.
#
# Copyright (c) 2015 Yahoo Japan Corporation
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.

require "rest_client"
require "json"
require "uri"

require "fastpay/version"
require "fastpay/fastpay"
require "fastpay/fastpay_object"
require "fastpay/api_client"
require "fastpay/charge"
require "fastpay/subscription"
require "fastpay/card"
require "fastpay/error/fastpay_error"
require "fastpay/error/api_error"
require "fastpay/error/card_error"
require "fastpay/error/invalid_request_error"
require "fastpay/error/unexpected_error"

module Fastpay
  API_VERSION = "v1"
  API_BASE    = "https://fastpay.yahooapis.jp/#{API_VERSION}"
end
