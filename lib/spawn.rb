#!/bin/env ruby
require 'rubygems'
require 'cinch'
require 'yaml'

fail "Where you be yaml config file. Dun puts it up in huur" unless ARGV[0]

config = YAML.load_file ARGV[0]

$:.unshift '.'
(config["plugins"] || []).each do |key, value|
  require value if value
end
$:.shift

bot = Cinch::Bot.new do
  configure do |c|
    c.server = config["server"]
    c.channels = config["channels"]
    c.nick = config["nickname"]
    c.ssl = config["ssl"]
    c.plugins.plugins = (config["plugins"] || []).map do |key, value|
      key.split(/::/).inject(Object) { |x, y| x.const_get(y) }
    end
  end

  on :join do |m|
    if m.user == bot and config["welcome_text"]
      bot.msg(m.channel, config["welcome_text"])
    end
  end
end

if config["daemonize"]
  fork do
    $stdout.reopen('/dev/null')
    $stderr.reopen('/dev/null')
    $stdin.reopen('/dev/null')

    Process.setsid

    bot.start
  end
else
  bot.start
end

