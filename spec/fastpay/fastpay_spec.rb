require 'spec_helper'

describe Fastpay::Fastpay do
  describe ".new" do
    it "keeps a secret key" do 
      fastpay = Fastpay::Fastpay.new("mysecret")
      expect(fastpay.secret).to eq "mysecret"
    end
  end

  describe "#charge" do
    it "creates charge object with its secret" do 
      charge = Fastpay::Fastpay.new("mysecret").charge
      expect(charge.secret).to eq "mysecret"
    end
  end
end
