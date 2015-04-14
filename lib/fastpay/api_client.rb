# This file is part of FastPay.
#
# Copyright (c) 2015 Yahoo Japan Corporation
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.

require "rest_client"
require "json"

module Fastpay
  class ApiClient < FastpayObject
    attr_reader :secret
    OBJECT_MAP = { "charge" => "Charge", "card" => "Card" }

    def initialize(secret)
      @secret = secret
      super()
    end

    def post(uri, params = {})
      @values = parse(request(:post, uri, params)).values
    end

    def get(uri)
      @values = parse(request(:get, uri)).values
    end

    def get_list(uri)
      parse(request(:get, uri))
    end

    def request(method, uri, *args)
      # use block to handle non-2xx response
      res = rest_client(uri).send(method, *args) { |response, _, _| response }
      begin
        validate_response(res)
        JSON.parse(res.body)
      rescue JSON::ParserError
        # JSON Parse失敗
        raise UnexpectedError.new("unexpected error", res.body)
      end
    end

    def validate_response(res)
      return if (200..207).include? res.code # valid response
      error_res = JSON.parse(res.body)
      error = error_res["error"]
      case error["type"]
      when 'card_error'
        fail CardError.new(error["code"], error["message"], res.body)
      when 'api_error'
        fail ApiError.new(error["message"], res.body)
      when 'invalid_request_error'
        fail InvalidRequestError.new(error["message"], res.body)
      else
        fail UnexpectedError.new(error["message"], res.body)
      end
    end

    def rest_client(uri)
      url = "#{API_BASE}#{uri}"
      headers = { "User-Agent" => "FastPay-ruby #{VERSION}" }
      RestClient::Resource.new(url, user: secret, password: '', headers: headers)
    end

    def parse(obj)
      case obj
      when Array
        # 配列の場合再帰的に適用
        obj.map { |n| parse(n) }
      when Hash
        obj_name = obj["object"]

        # listは配列部分のみを返却
        return obj["data"].map { |n| parse(n) } if obj_name == "list"

        if OBJECT_MAP.key?(obj_name)
          new_obj = Object.const_get("Fastpay").const_get(OBJECT_MAP[obj_name]).new(secret)
        else
          new_obj = FastpayObject.new
        end

        obj.each { |k, v| new_obj.values[k] = parse(v) }
        new_obj
      else
        obj
      end
    end
  end
end
