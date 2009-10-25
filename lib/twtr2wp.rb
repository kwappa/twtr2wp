# -*- coding: utf-8 -*-
require 'rubygems'
require 'twitter'
require 'json'
require 'pp'
# require 'CGI'

require 'twtr2wp/account'
require 'twtr2wp/api'
require 'twtr2wp/datafile'
require 'twtr2wp/process'
require 'twtr2wp/renderer'
require 'twtr2wp/util'

module Twtr2wp
  class Twtr2wp

    # コンストラクタ : 設定を読み込み
    def initialize
      @config = DataFile.load_config
    end

    # メイン処理
    def run
      case ARGV[0]

      # 自分のつぶやきを保存
      when 'store'
        # タイムラインを3,200件取得して保存
        if last_id = Process.save_my_timeline(@config['last_status_id'])
          # データファイルを月別に切り出し
          if last_id > @config['last_status_id']
            Process.datalize
            @config['last_status_id'] = last_id
            save_config
          end
        end

      when 'render'
        # FIXME
        rendering

      else
        puts 'usage : twtr2wp store|render'
        return
      end

    end

    # 設定を保存
    def save_config
      DataFile::save_config @config
    end

    # FIXME : レンダリング
    def rendering
      ym         = ARGV[1] ||= Time.now.strftime('%Y%m')
      status_erb = ARGV[2] ||= 'simple'
      body_erb   = ARGV[3] ||= 'basic'

      renderer = Renderer.new
      timeline = renderer.render_timeline "data/monthly/#{Account::LOGIN}_#{ym}.txt", status_erb
      page     = renderer.render_page timeline, body_erb

      File.open("data/result/#{ym}.html", 'w') { |w|
        w.write page
      }
    end

  end

  Twtr2wp.new.run
end