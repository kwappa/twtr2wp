#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
CURRENT_DIR = File.dirname(File.expand_path(__FILE__))
$: << File.join(CURRENT_DIR, 'lib')
require 'rubygems'
require 'bundler'
Bundler.setup
require 'twtr2wp'
