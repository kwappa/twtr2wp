# -*- coding: utf-8 -*-
module Twtr2wp
  class Process

    GET_STATUS_COUNT = 200      # 1リクエストで取得する件数
    MAX_STATUS_PAGES =  16      # ループする回数

    # API経由で3,200件自分のpostを取得して保存
    def self.save_my_timeline since_id = nil
      today      = Time.now.strftime('%Y%m%d')
      user       = Account::LOGIN
      api        = Api.new
      since_id ||= 1
      last_id    = since_id

      MAX_STATUS_PAGES.times do |t|
        file_name = sprintf('data/src/src_%s_%s_%02d.txt', user, today, t + 1)

        next if t > 0 and File.exists? file_name

        begin
          timeline = api.my_timeline GET_STATUS_COUNT, t + 1, since_id
          break if timeline.count == 0
          max_id = timeline.max_by { |status| status.id }.id
          last_id = max_id if max_id > last_id
        rescue
          return false
        end
        DataFile::save_timeline timeline, file_name
      end

      last_id
    end

    # 保存済みデータファイルを月別データファイルに切り出し
    def self.datalize date = nil
      user = Account::LOGIN
      date ||= Time.now.strftime('%Y%m%d')

      MAX_STATUS_PAGES.times do |t|
        # データファイルを読み込んでstatusの配列に
        src_file = sprintf('data/src/src_%s_%s_%02d.txt', user, date, t + 1)
        next unless File.exists? src_file
        timeline = []
        File.open(src_file) { |f|
          while line = f.gets do
            timeline << JSON.parse(line)
          end
        }

        # YYYYMMで切り分けて保存
        current_month = nil
        month_array = []
        timeline.each do |status|
          if current_month and current_month != Time.parse(status['created_at']).strftime("%Y%m")
            # 書き込み
            DataFile.marge_sort_write("data/monthly/#{user}_#{current_month}.txt", month_array)
            current_month = nil
            month_array = []
          end
          if !current_month
            current_month = Time.parse(status['created_at']).strftime("%Y%m")
          end
          month_array << status
        end

        # 最後に残った分も書き込む
        if current_month
          DataFile.marge_sort_write("data/monthly/#{user}_#{current_month}.txt", month_array)
        end
      end
    end

    # 月別データを単純テキストに
    def self.textize user
      Dir.glob("data/monthly/#{user}*.txt") do |file_name|
        save_name = file_name.gsub(/monthly/, 'text')

        File.open(file_name) { |r|
          File.open(save_name, 'w') { |w|
            while line = r.gets do
              status = JSON::parse(line)
              id   = sprintf('%10d', status['id'].to_i)
              date = Time::parse(status['created_at']).strftime('%m/%d %X')
              text = CGI::unescapeHTML(status['text'])
              w.puts "#{id} [#{date}] #{text}"
            end
          }
        }
      end
    end

  end
end
