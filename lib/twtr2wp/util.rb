# -*- coding: utf-8 -*-
module Twtr2wp
  class Util

    # リンクを生成
    def self.link_status_text status, options = { }
      options[:br] ||= '<br />'
      text = status['text'].gsub(/\r?\n/, options[:br])

      if options[:unescape]
        text = CGI::unescapeHTML text
      end

      text = self.link_url text
      text = self.link_user text
      text = self.link_hash_tag text
      text
    end

    # 本文中の#HASHTAGに対するリンク
    def self.link_hash_tag text
      result = text
      pattern = '/[\s+|^](#)([0-9a-zA-Z_-]+|([\x00-\x7f]|[\xC0-\xDF][\x80-\xBF]|[\xE0-\xEF][\x80-\xBF]{2}|[\xF0-\xF7][\x80-\xBF]{3})+_)([^0-9a-zA-Z_-]|$)/'
      result.scan(pattern).each do |m|
        result.gsub!(m[0] + m[1], "<a href=\"http://twitter.com/search?q=%23#{m[1]}\" target=\"_blank\">##{m[1]}</a>")
      end
      result
    end

    # 本文中のURLに対するリンク
    def self.link_url text
      result = text
      result.scan(/https?:\/\/[-_.!~*'()a-zA-Z0-9;\/?:@&=+$,%#]+/).each do |m|
        result.sub!(m, "<a href=\"#{m}\" target=\"_blank\">#{m}</a>")
      end
      result
    end

    # 本文中の@userに対するリンク
    def self.link_user text
      result = text
      result.scan(/(@)([0-9a-zA-Z_]+)([^0-9a-zA-Z_]|$)/).each do |m|
        result.gsub!(m[0] + m[1], "<a href=\"http://twitter.com/#{m[1]}\" target=\"_blank\">#{m[0]}#{m[1]}</a>")
      end
      result
    end

    # 発言に対するリンク
    def self.get_link_to_status status, options = { }
      # デフォルトはcreated_at, formatも指定する
      options[:target] ||= 'created_at'
      options[:format] ||= '%H:%M:%S'

      if options[:target] == 'created_at'
        link_str = Time.parse(status['created_at']).strftime(options[:format])
      else
        link_str = status["#{options[:target]}"]
      end

      "<a href=\"http://twitter.com/#{status['user']['screen_name']}/status/#{status['id']}\" target=\"_blank\">#{link_str}</a>"
    end

    # 発言がリプライの場合オリジナル発言へのリンク
    def self.get_link_in_reply_to status
      reply_user = status['in_reply_to_user_id'] || return
      url = "http://twitter.com/#{status['in_reply_to_screen_name']}"
      if (reply_id = status['in_reply_to_status_id'])
        url += "/status/#{reply_id}"
      end
      "<a href=\"#{url}\" target=\"_blank\">@#{status['in_reply_to_screen_name']}</a>"
    end

    # アイコンのimgタグとhomeへのリンク
    def self.get_icon_tag status
      "<a href=\"http://twitter.com/#{status['user']['name']}\" target=\"_blank\"><img src=\"#{status['user']['profile_image_url']}\" alt=\"#{status['user']['name']}\"></a>"
    end

  end
end
