require 'redis'

module Cinch::Plugins
  module BEEF
    class REDIS 

      class << self
        attr_accessor :key
      end

      def initialize(*args)
        super(*args)
        @db = Redis.new(:path => "/tmp/redis.sock")
        self.class.key = print_list
      end

      def print_list
        self.class.key = @db.smembers("channel") # needs to be fixed
      end
    end

    class TALK  
      include Cinch::Plugin

      def initialize(*args)
        super(*args)
        @db = REDIS.new
      end

      match %r/(print)/, :use_prefix => true, :use_suffix => false
      react_on :channel

      def execute(m)
          m.reply(@db.print_list)
      end
    end
  end
end
