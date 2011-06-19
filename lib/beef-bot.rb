require 'redis'
module Cinch::Plugins
  module BEEF
    class REDIS 

      # Since this is mostly a learning exercise
      # I wrote a class to interact with Redis
      # This could all be removed and have the 
      # Cinch::Plugin classes connect to Redis
      # directly
      attr_writer :chan

      # Channel name without hash
      def chan
        @chan = "channel"
      end

      # This is assuming you're running redis locally
      # and have it configured to write the .sock file
      # to /tmp
      def initialize(*args)
        super(*args)
        @db = Redis.new(:path => "/tmp/redis.sock")
      end
      
      # Print all users in the aop list
      def print_list
        @db.smembers(@chan)
      end
  
      # Check to see if the users exists
      def user_check(name)
        @db.sismember(@chan, name)
      end

      # Add a user to the aop list
      # since this is a list the check
      # could be removed
      def user_add(name)
        v = @db.sismember(@chan, name).to_s
        if v == "false"
         @db.sadd(@chan, name)
        end
      end
   
      # Delete a user from the aop list 
      def user_del(name)
        @db.srem(@chan, name)
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

      # This might be a hack to clean up the query
      # so that it's the bare username
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
        m.reply "adding #{user} to aop list"
        @db.user_add(user)
      end
    end

    class DELETE
      include Cinch::Plugin

      attr_writer :static
      attr_writer :admins

      # A list of users who cannot be removed from the
      # aop list.
      def static
        @static = %w[foo bar baz]
      end

      # A list of admins users who can delete users
      # from the aop list. This could also be used
      # if you wanted to restric the other actions.
      def admins
        @admins = %w[foo]
      end

      def initialize(*args)
        super *args
        @db = REDIS.new
      end

      match %r/(delete\s.+)/, :use_prefix => true, :use_suffix => true
      react_on :channel

      # Checks to see if the calling user is in the
      # @admins list. If they are, it verifies that
      # the user being deleted is not in @static
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
      react_on :channel

      def execute(m)
        m.user.send "Welcome to #dongtown!"
        m.user.send "To list the users on the aop list use !print"
        m.user.send "To see if a user is on the aop list use !search nick"
        m.user.send "To add a user to the list use !add user"
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
