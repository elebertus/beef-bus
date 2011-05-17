#!/home/eblack/.rvm/rubies/ruby-1.9.2-p180/bin/ruby

require 'rubygems'
require 'redis'

module Cinch::Pluginss
 module BEEF
  class REDIS

  @db = Redis.new(:socket => "/tmp/redis.sock")
  def show(key, range)
   @db.lrange
 end
end
end

@autoop        = true

class AOPS
 include Cinch::Plugin

   def opme
      @db.show(:key => "#dongtown", :range => "0 99").each { |s|
       m.user == s
       #m.channel.op(m.user) 
       m.reply "${m}"
       if @autop
     end}
   end
  end

 class OPTRON
  include Cinch::Plugin

    def botcheck
     m.reply "!opme for ops"
    end

    def calling
     @db.randomkey
    end

    def oplist
     m.reply @db.show(:key => "#dongtown", :range => "0 99")
    end
 end

 class LISTENING
  include Cinch::Plugin

   def initialize(*args)
    super *args
    @db = REDIS.new
   end

   match %r/(botcheck|beef-bus|oplist|opme)/, :use_prefix =>false, :use_suffix => true

   react_on :channel

  def execute(m, query)
   case query
   when  'botcheck'
    OPTRON.botcheck 
   when 'beef-bus'
    OPTRON.calling
   when 'oplist'
    OPTRON.oplist
   when 'opme'
    AOPS.opme
   end
  end
end
end
