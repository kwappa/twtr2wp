# -*- coding: utf-8 -*-
module Twtr2wp
  class Api

    attr_reader :client

    # コンストラクタ : クライアントの準備
    def initialize
      consumer = ::OAuth::Consumer.new(
                                     Account::CONSUMER_KEY,
                                     Account::CONSUMER_SECRET,
                                     :site => 'http://twitter.com'
                                     )

      token = ::OAuth::AccessToken.new(
                                     consumer,
                                     Account::ACCESS_TOKEN,
                                     Account::ACCESS_SECRET
                                     )

      @client = ::OAuthRubytter.new(token)

    end

    # 自分のタイムラインを取得
    def my_timeline count, page, since_id = 1
      @client.user_timeline(Account::LOGIN, :count => count, :page => page, :since_id => since_id)
    end

    # 自分のお気に入りを取得
    def my_favorites page
      @client.favorites(:page => page)
    end

    def method_missing name, *args
      if @client.respond_to? name
        @client.send(name, *args)
      end
    end


  end
end
