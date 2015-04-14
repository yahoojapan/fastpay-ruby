# FastPay SDK for Ruby

FastPayをRubyで簡単に利用するためのSDKです。

## インストール

Gemfileに以下を追加します

    gem 'fastpay'

bundleコマンドでインストールを行います

    $ bundle

## 使い方

FastPayではクレジットカード情報は直接扱わず、FastPay側でトークン化したものを使って安全に決済を行います。
トークン化など全体的な流れについては、FastPayのドキュメント[支払いフロー](https://fastpay.yahoo.co.jp/docs/flow)をご覧ください。


### 課金

詳細についてはFastPayのドキュメント[新規決済の作成](https://fastpay.yahoo.co.jp/docs/pay/new)をご覧ください。

```ruby
require 'fastpay'

# fastpay.jsで取得します。"fastpayToken"というパラメータでhiddenのinputにて送信されます。
token = "CARD_TOKEN"

begin
  charge = Fastpay::Charge.new("シークレット") # シークレットはダッシュボードより確認いただけます
  charge.create({
    :amount => 100,  # 金額
    :card => token,  # fastpay.jsで取得したトークン
    :description => "fastpay@example.com", # 詳細情報。フリーフォームです。
    :capture => false # 確定を行わない場合false。同時確定の場合は省略またはtrueを指定する
  })
  # 例外が上がらなかった場合課金成功
  puts "注文完了 ID:#{charge.id}" # → 注文ID表示
rescue Fastpay::CardError => e
  # カード与信エラー。必要に応じて再度画面を表示など行う
  case e.code
  when Fastpay::CardError::CARD_DECLINED then
    puts "カード決済に失敗しました。（オーソリ時のエラー）"
  when Fastpay::CardError::INCORRECT_CVC then
    puts "セキュリティコードが正しくありません。（オーソリ時のエラー）"
  # 他のコードは https://fastpay.yahoo.co.jp/docs/error を参照
  end
rescue => e
  puts "システムエラー #{e} #{e.message}"
end
```

### 確定
詳細についてはFastPayのドキュメント[決済の確定](https://fastpay.yahoo.co.jp/docs/pay/fixed)をご覧ください。

```ruby
require 'fastpay'

begin
  charge = Fastpay::Charge.new("シークレット")
  charge.retrieve("対象のcharge_id")  
  # 確定を行う
  charge.capture()
  # 例外が上がらなかった場合確定成功
  puts "確定成功"
rescue => e
  puts "システムエラー #{e} #{e.message}"
end
```

### 返金
詳細についてはFastPayのドキュメント[払い戻し処理](https://fastpay.yahoo.co.jp/docs/pay/rtnpay)をご覧ください。


```ruby
require 'fastpay'

begin
  charge = Fastpay::Charge.new("シークレット")
  charge.retrieve("対象のcharge_id")  
  # 払い戻しを行う。引数を与えることで部分返金も可能
  charge.refund()
  # 例外が上がらなかった場合確定成功
  puts "払い戻し成功"
rescue => e
  puts "システムエラー #{e} #{e.message}"
end
```

### 継続課金の開始

継続課金についてはまずはFastPayのドキュメント[継続課金とは](https://fastpay.yahoo.co.jp/docs/guide_subscription)をご覧ください。


```ruby
require 'fastpay'

begin
  subscription = Fastpay::Subscription.new("シークレット")
  subscription.activate({
    :subscription_id => "対象のsubscription_id",
    :description => "説明"
  })
  puts "継続課金開始成功"
rescue => e
  puts "システムエラー #{e} #{e.message}"
end
```

### 継続課金の停止

```ruby
require 'fastpay'

begin
  subscription = Fastpay::Subscription.new("シークレット")
  subscription.cancel("対象のsubscription_id")
  puts "継続課金停止成功"
rescue => e
  puts "システムエラー #{e} #{e.message}"
end
```

## License

MITライセンスにて提供しています。詳しくはLICENSEをご覧ください。
