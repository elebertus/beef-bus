#!/home/eblack/.rvm/rubies/ruby-1.9.2-p180/bin/ruby

require 'redis'

class BeefDB

  attr_accessor :socket
  attr_accessor :chan
  attr_accessor :db

  def initialize(socket, chan)
    self.socket = '/tmp/redis.sock'
    self.chan = chan
    self.db = Redis.new(:sock => self.socket)
  end

  # repopulate the list #dongtown with a static array
  def rebase
    base = %w[ eblack erikh popeketric dhoss gaziel uncle_fungus bluepojo randallman Malcalypse Dav3xor sean ]
    base.each do |s|
     db.sadd(self.chan, s)
    end
  end

  # pushes a key to the end of the list
  def list_push(value)
    db.sadd(self.chan, value)
  end

  # pulls all values in list #dongtown
  # eg, puts foo.pull
  def pull
    db.smembers(self.chan)
  end
  
  def check(member)
    db.sismember(self.chan, member)
  end

  # clears 500 values in key #dongtown
  def clear_set
    a = (db.smembers(self.chan))
     a.each do |s|
       db.srem(self.chan, s)
     end
  end
end
#foo = BeefDB.new(:socket, 'dongtown')
