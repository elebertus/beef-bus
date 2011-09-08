# todo: add adn ADMINS plugin to list, and modify
# the list of admins, or people who can delete
# users in the AOP list
#
# Figure out the :static and :admins

require 'redis'
module Cinch::Plugins
  module BEEF

    class REDIS 

      attr_writer :chan

        def chan
          @chan = "dongtown"
        end

        def initialize(*args)
          super(*args)
          @db = Redis.new(:path => "/tmp/redis.sock")
        end

        def print_list
          @db.smembers(chan)
        end

        def user_check(name)
          @db.sismember(chan, name)
        end

        def user_add(name)
          v = @db.sismember(chan, name).to_s
          if v == "false"
           @db.sadd(chan, name)
          end
        end
       
        def user_del(name)
          @db.srem(chan, name)
        end
    end

    class SEARCH
      include Cinch::Plugin

      def initialize(*args)
        super *args
        @db = REDIS.new
      end

      match %r/(search\s.+)/, :use_prefix => true, :use_suffix => true
 
      react_on :channel

      def execute(m, query)
        response = query.gsub(/search/, "").lstrip
        unless !@db.user_check(response)
          m.reply "#{response} is in the list"
        else
          m.reply "#{response} is not on the list" 
          m.reply "to add them to the aop list use !add #{response}"
        end
      end
    end

    class ADD
      include Cinch::Plugin

      def initialize(*args)
        super *args
        @db = REDIS.new
      end

      match %r/(add\s.+)/, :use_prefix => true, :use_suffix => true
      
      react_on :channel

      def execute(m, query)
        user = query.gsub(/add/, "").lstrip
	if (1..14).include?(user.length)
          @db.user_add(user)
          m.reply "adding #{user} to aop list"
	else
          m.reply "#{user} can be a maximum of 14 characters"
	end
      end
    end

    class DELETE
      include Cinch::Plugin

      attr_writer :static
      attr_writer :admins

      def static
        @static = %w[eblack erikh PopeKetric Dav3xor sam]
      end

      def admins
        @admins = %w[eblack]
      end

      def initialize(*args)
        super *args
        @db = REDIS.new
      end

      match %r/(delete\s.+)/, :use_prefix => true, :use_suffix => true
      react_on :channel

      def execute(m, query)
        user = query.gsub(/delete/, "").lstrip
        op = "#{m.user.nick}"
        if self.admins.include?(op)
          if self.static.include?("#{user}")
            m.user.send "Can't remove protected user #{user}"
          else
            @db.user_del(user)
          end
        end
       end 
    end

    class HELP
      include Cinch::Plugin

      def initialize(*args)
        super(*args)
      end

      match %r/(help)/, :use_prefix => true, :use_suffix => false

      def execute(m)
        m.user.send "Welcome to #dongtown!"
        m.user.send "To list the users on the aop list use !print"
        m.user.send "To see if a user is on the aop list use !search nick"
        m.user.send "To add a user to the list use !add user"
        m.user.send "To op your self use !opme"
      end
    end

    class OPONJOIN
      include Cinch::Plugin
    
      def initialize(*args)
        super(*args)
        @db = REDIS.new
      end

      listen_to :join

      def listen(m)
        unless m.user.nick == bot.nick
          if @db.user_check("#{m.user.nick}")
            m.channel.op(m.user)
          end
        end
      end
    end

    class OPME
      include Cinch::Plugin
      def initialize(*args)
       super(*args)
       @db = REDIS.new
      end

     match %r/(opme)/, :use_prefix => true, :use_suffix => false
     react_on :channel

     def execute(m)
       if @db.user_check("#{m.user.nick}")
         m.channel.op(m.user)
       end
     end
    end

    class PRINT
      include Cinch::Plugin

      def initialize(*args)
        super(*args)
        @db = REDIS.new
      end

      match %r/(print)/, :use_prefix => true, :use_suffix => false
      react_on :channel

      def execute(m)
          m.user.send(@db.print_list)
      end
    end
  end
end
