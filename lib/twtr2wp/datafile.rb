# -*- coding: utf-8 -*-
module Twtr2wp
  class DataFile

    CONFIG_FILE = 'data/config.json'

    # timeline (取得したもの) をJSONでファイル保存
    def self.save_timeline timeline, filename
      # ファイルが存在したらマージ
      if File.exists? filename
        File.open(filename) { |f|
          while line = f.gets
            timeline << JSON::parse(line)
          end
        }
      end

      # timelineをJSONにして書き出し
      File.open(filename, 'w') { |w|
        timeline.each do |status|
          w.puts status.to_hash.to_json
        end
      }
    end

    # 既存ファイル (1line = 1JSON)とtimelines(statusのarray)をmergeして書き出す
    def self.marge_sort_write file_name, timelines
      # 既存のデータファイルを読み込んで渡された配列に足す
      if File.exists? file_name
        src = File.open(file_name).read.split("\n")
        src.each do |src_json|
          timelines << JSON.parse(src_json)
        end
      end
      # mergeされた配列をソート、重複idを取り除いて書き出す
      current_id = nil
      File.open(file_name, "w") { |f|
        timelines.sort_by { |status| status['id'] }.reverse.each do |status|
          next if current_id == status['id']
          current_id = status['id']
          f.puts status.to_json
        end
      }
    end

    # 設定ファイルの読み込み
    def self.load_config
      unless File.exists? CONFIG_FILE
        return { }
      end
      config = File.open(CONFIG_FILE).read
      JSON::parse(config)
    end

    # 設定ファイルの書き込み
    def self.save_config config
      File.open(CONFIG_FILE, 'w') { |f|
        f.write config.to_json
      }
    end

  end
end
