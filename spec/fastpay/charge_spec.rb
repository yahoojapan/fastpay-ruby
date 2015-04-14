require 'spec_helper'

describe Fastpay::Charge do

  describe "#create" do
    it "creates Charge object via POST /charges" do
      VCR.use_cassette('charges_create') do
        charge = Fastpay::Charge.new("xxxxxxxxxxxxxxxxxxxxxxxx")
        charge.create({
          :amount => 400,
          :card => "tok_8d62d3931cfdb4262b48e8480af8e56e45b239a1",
          :description => "fastpay@example.com",
          :capture => false
        })
        expect(charge.object).to eq "charge"
        expect(charge.id).to match(/ch_[0-9]+/)
        expect(charge.amount).to eq 400
        expect(charge.captured).to eq false
        expect(charge.card.id).to match(/card_.+/)
      end
    end
  end

  describe "#retrieve" do
    it "retrieves Charge object via GET /charges/CHARGE_ID" do
      VCR.use_cassette('charges_retrieve') do
        charge = Fastpay::Charge.new("xxxxxxxxxxxxxxxxxxxxxxxx")
        charge.retrieve("ch_14314060225230681")
        expect(charge.object).to eq "charge"
        expect(charge.id).to match(/ch_[0-9]+/)
        expect(charge.captured).to eq true
      end
    end
  end

  describe "#capture" do
    it "captures uncaptured Charge object via POST /charges/CHARGE_ID/capture" do
      VCR.use_cassette('charges_capture') do
        charge = Fastpay::Charge.new("xxxxxxxxxxxxxxxxxxxxxxxx")
        charge.retrieve("ch_14314060225230681")
        expect(charge.captured).to eq false
        charge.capture()
        expect(charge.object).to eq "charge"
        expect(charge.id).to eq "ch_14314060225230681"
        expect(charge.captured).to eq true
      end
    end
  end

  describe "#refund" do
    it "refunds captured Charge object via POST /charges/CHARGE_ID/refund" do
      VCR.use_cassette('charges_refund') do
        charge = Fastpay::Charge.new("xxxxxxxxxxxxxxxxxxxxxxxx")
        charge.retrieve("ch_14314060225230681")
        expect(charge.refunded).to eq false
        charge.refund()
        expect(charge.object).to eq "charge"
        expect(charge.id).to eq "ch_14314060225230681"
        expect(charge.refunded).to eq true
        expect(charge.refunds[0].object).to eq "refund"
      end
    end

    it "partially refunds captured Charge object via POST /charges/CHARGE_ID/refund" do
      VCR.use_cassette('charges_partial_refund') do
        charge = Fastpay::Charge.new("xxxxxxxxxxxxxxxxxxxxxxxx")
        charge.retrieve("ch_95115033050003540")
        expect(charge.refunded).to eq false
        # 一部返金
        charge.refund(100)
        expect(charge.refunded).to eq false
        expect(charge.refunds[0].amount).to eq 100
        expect(charge.amount_refunded).to eq 100
        # 2回め返金
        charge.refund(100)
        expect(charge.refunded).to eq false
        expect(charge.refunds[0].amount).to eq 100
        expect(charge.refunds[1].amount).to eq 100
        expect(charge.amount_refunded).to eq 200
        # 全額返金
        charge.refund(200)
        expect(charge.refunded).to eq true # 全額返金されたのでtrue
        expect(charge.refunds[0].amount).to eq 100
        expect(charge.refunds[1].amount).to eq 100
        expect(charge.refunds[2].amount).to eq 200
        expect(charge.amount_refunded).to eq 400

      end
    end
  end

  describe "#all" do
    it "gets a list of Charge object via GET /charges" do
      VCR.use_cassette('charges_all') do
        charge = Fastpay::Charge.new("xxxxxxxxxxxxxxxxxxxxxxxx")
        list = charge.all()
        expect(list.length).to eq 10
        expect(list[0].object).to eq "charge"
        expect(list[1].object).to eq "charge"
      end
    end
  end

  context "when request is not valid" do
    it "raises InvalidRequestError" do
      VCR.turned_off do
        body = '{"error":{"type":"invalid_request_error","message":"No such charge: tok_xxxxxxxxxxxxxx","code":null,"param":"id"}}'
        stub_request(:post, "https://INVALID_SECRET_KEY:@fastpay.yahooapis.jp/v1/charges").to_return(:status => 404, :body => body)

        charge = Fastpay::Charge.new("INVALID_SECRET_KEY")
        expect { charge.create({
          :amount => 100,
          :card => "tok_71763fc37c1f0749f8f1545d235c77afac93b53e",
          :description => "fastpay@example.com"
        })  }.to raise_error(Fastpay::InvalidRequestError)

        WebMock.reset!
      end
    end
  end

  context "when card is not valid" do
    it "raises CardError" do
      VCR.turned_off do
        body = '{"error":{"type":"card_error","message":"Your card was declined. Your request was in test mode, but used a non test card.","code":"card_declined","param":null}}'
        stub_request(:post, "https://xxxxxxxxxxxxxxxxxxxxxxxx:@fastpay.yahooapis.jp/v1/charges").to_return(:status => 402, :body => body)
        charge = Fastpay::Charge.new("xxxxxxxxxxxxxxxxxxxxxxxx")
        expect { charge.create({
          :amount => 100,
          :card => "tok_71763fc37c1f0749f8f1545d235c77afac93b53e",
          :description => "fastpay@example.com"
        })  }.to raise_error(Fastpay::CardError) do|exception|
          expect(exception.code).to eq "card_declined"
          expect(exception.message).to eq "Your card was declined. Your request was in test mode, but used a non test card."
        end
      end
    end
  end

  context "when error occured in Fastpay API" do
    it "raises ApiError" do
      VCR.turned_off do
        body = '{"error":{"type":"api_error","message":"Failed to process charge","code":null,"param":null}} '
        stub_request(:post, "https://xxxxxxxxxxxxxxxxxxxxxxxx:@fastpay.yahooapis.jp/v1/charges").to_return(:status => 500, :body => body)
        charge = Fastpay::Charge.new("xxxxxxxxxxxxxxxxxxxxxxxx")
        expect { charge.create({
          :amount => 100,
          :card => "tok_71763fc37c1f0749f8f1545d235c77afac93b53e",
          :description => "fastpay@example.com"
        })  }.to raise_error(Fastpay::ApiError) do |exception|
          expect(exception.message).to eq "Failed to process charge"
        end
      end
    end
  end

  context "when unexpected response returned" do
    it "raises UnexpectedError" do
      VCR.turned_off do
        body = '{"error":{"type":"unexpected", "message":"unexpected"}}'
        stub_request(:post, "https://xxxxxxxxxxxxxxxxxxxxxxxx:@fastpay.yahooapis.jp/v1/charges").to_return(:status => 500, :body => body)
        charge = Fastpay::Charge.new("xxxxxxxxxxxxxxxxxxxxxxxx")
        expect { charge.create({
          :amount => 100,
          :card => "tok_71763fc37c1f0749f8f1545d235c77afac93b53e",
          :description => "fastpay@example.com"
        })  }.to raise_error(Fastpay::UnexpectedError) do |exception|
          expect(exception.message).to eq "unexpected"
        end
      end
    end
  end

  context "when response is not valid JSON" do
    it "raises UnexpectedError" do
      VCR.turned_off do
        body = 'xxxxxxxxxxxxxxxxxxxx'
        stub_request(:post, "https://xxxxxxxxxxxxxxxxxxxxxxxx:@fastpay.yahooapis.jp/v1/charges").to_return(:status => 500, :body => body)
        charge = Fastpay::Charge.new("xxxxxxxxxxxxxxxxxxxxxxxx")
        expect { charge.create({
          :amount => 100,
          :card => "tok_71763fc37c1f0749f8f1545d235c77afac93b53e",
          :description => "fastpay@example.com"
        })  }.to raise_error(Fastpay::UnexpectedError) do |exception|
          expect(exception.message).to eq "unexpected error"
        end
      end
    end
  end

end
