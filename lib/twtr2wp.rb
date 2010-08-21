# -*- coding: utf-8 -*-
require 'rubytter'
require 'json'
require 'pp'

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

      when 'render_file'
        # FIXME
        rendering_file

      # 自分のお気に入りを取得
      when 'store_fav'
        Process.save_my_favorites

      # 保存済みファイルからキーワード検索
      when 'search_and_store'
        keyword   = ARGV[1]
        dest_name = ARGV[2]
        if !keyword || !dest_name
          puts 'usage : twtr2wp search_and_store keyword dest_name [ASC|DESC]'
          return
        end
        Process.search_and_store keyword, dest_name, ARGV[3] ||= 'ASC'

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

    # FIXME : ファイル指定してレンダリング
    def rendering_file
      unless src_file = ARGV[1]
        puts 'usage : twtr2wp rendering_file src_file [template]'
      end
      erb_name = ARGV[2] ||= 'blog'

      tmp_file = src_file + ".tmp"
      dst_file = src_file.sub(/#{File.extname(src_file)}$/, '.html')

      tmp = File.open(src_file).read.split("\n").reverse
      File.open(tmp_file, 'w') { |w|
        w.puts tmp
      }

      renderer = Renderer.new
      timeline = renderer.render_timeline tmp_file, 'blog'
      File.open(dst_file, 'w') { |w|
        timeline.each do |tl|
          w.puts tl if tl.chomp.length > 0
        end
      }
      File.unlink tmp_file
    end

  end

end
