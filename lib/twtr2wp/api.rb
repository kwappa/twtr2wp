# -*- coding: utf-8 -*-
module Twtr2wp
  class Api

    # コンストラクタ : クライアントの準備
    def initialize
      @client = Twitter::Client.new(:login    => Account::LOGIN,
                                    :password => Account::PASSWORD)
    end

    # 自分のタイムラインを取得
    def my_timeline count, page, since_id = 1
      @client.timeline_for(:me, :count => count, :page => page, :since_id => since_id)
    end

    # 自分のお気に入りを取得
    def my_favorites page
      @client.favorites(:page => page)
    end

  end
end
