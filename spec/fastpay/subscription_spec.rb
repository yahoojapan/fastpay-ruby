require 'spec_helper'

describe Fastpay::Subscription do

  describe "#activate" do
    it "activates Subscription object via POST /subscription/CHARGE_ID/activate" do
      VCR.use_cassette('subscription_activate') do
        subscription = Fastpay::Fastpay.new("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx").subscription

        subscription.activate({
            :subscription_id => "subs_fXFlqO9xeCNKKEK3fnX82JBV",
            :description => "my plan"
        })
        expect(subscription.object).to eq "subscription"
        expect(subscription.status).to eq "active"
        expect(subscription.activation_date).to eq 1418620022
        expect(subscription.id).to match(/subs_.+/)
      end
    end
  end

  describe "#cancel" do
    it "cancels Subscription object via POST /subscription/CHARGE_ID/cancel" do
      VCR.use_cassette('subscription_cancel') do
        subscription = Fastpay::Fastpay.new("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx").subscription

        subscription.cancel("subs_EzWJ9SOjU8Mv1GEFamEWEjEf")
        expect(subscription.object).to eq "subscription"
        expect(subscription.status).to eq "cancelled"
        expect(subscription.activation_date).to eq 1418626404
        expect(subscription.id).to match(/subs_.+/)
      end
    end
  end
end
