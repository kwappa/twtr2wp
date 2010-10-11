# -*- coding: utf-8 -*-
require 'erb'
module Twtr2wp
  class Renderer

    # タイムラインをレンダリング
    def render_timeline file_name, erb_name
      unless File.exists? file_name
        raise "datafile #{file_name} is not exists."
      end

      erb_name = "data/erb/status/#{erb_name}.erb"
      unless File.exists? erb_name
        raise "#{erb_name} is not exists."
      end
      @template = File.open(erb_name).read
      @erb = ERB.new @template, nil, '-'

      result = ''
      File.open(file_name) { |f|
        while line = f.gets
          status = JSON::parse(line)
          result += @erb.result(binding)
        end
      }

      result
    end

    # ページをレンダリング
    def render_page rendered_timelines, title, erb_name
      erb_name = "data/erb/layout/#{erb_name}.erb"
      unless File.exists? erb_name
        raise "#{erb_name} is not exists."
      end
      @template = File.open(erb_name).read
      @erb = ERB.new @template, nil, '-'

      @erb.result(binding)
    end

  end
end
