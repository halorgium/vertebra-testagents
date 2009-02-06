require File.dirname(__FILE__) + '/bot'

module Irc
  class Actor < Vertebra::Actor
    def initialize
      start_bot
      @channels = []
    end
    attr_reader :bot

    provides '/irc'

    bind_op "/irc/join", :irc_join
    desc "/irc/join", "Join a channel on IRC"
    def irc_join(options = {})
      unless channel = options["channel"]
        raise "no channel!"
      end
      key = options["key"]

      puts "Joining #{channel}"
      bot.join_channel(channel, key)
      @channels << channel

      true
    end

    bind_op "/irc/push", :irc_push
    desc "/irc/push", "Send something on IRC"
    def irc_push(options = {})
      unless message = options["message"]
        raise "no message!"
      end
      unless channel = options["channel"]
        raise "no channel!"
      end
      key = options["key"]
      unless @channels.include?(channel)
        irc_join("channel" => channel, "key" => key)
      end
      puts "Saying #{message.inspect} on #{channel}"
      bot.say(channel, message)
      true
    end

    def start_bot
      Thread.new {
        begin
          puts "I am #{$$}"
          @bot = Bot.new("irc.freenode.net", "6667", "vertebra-#{$$}")
          @bot.run
        rescue
          puts "irccat fail: #{Vertebra.exception($!)}"
        end
      }
    end
  end
end

