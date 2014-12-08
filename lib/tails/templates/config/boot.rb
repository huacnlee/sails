require 'rubygems'
require 'bundler/setup'

$:.unshift File.expand_path('../', __FILE__)
require "application"

Tails.start!("nonblocking")