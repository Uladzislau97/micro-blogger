require 'jumpstart_auth'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing MicroBlogger \n\n"
    @client = JumpstartAuth.twitter
  end

  def run
    puts "Welcome to the JSL Twitter Client! \n\n"

    command = ''
    until command == 'q'
      print 'enter command: '
      input = gets.chomp.split(' ')
      command = input[0]

      case command
        when 'q'
          puts "\nGoodbye!"
        when 't'
          message = input[1..-1].join(' ')
          tweet(message)
        when 's'
          message = input[1..-1].join(' ')
          spam_my_followers(message)
        when 'elt'
          everyones_last_tweet
        when 'dm'
          target = input[1]
          message_words = input[2..-1]

          if message_words.nil?
            puts "Target can't be empty"
            next
          end

          message = message_words.join(' ')

          direct_message(target, message)
        else
          puts "Sorry, I don't know how to #{command}"
      end
    end
  end

  private

  def tweet(message)
    if message.to_s.length == 0
      puts "You can't tweet an empty message"
    elsif message.to_s.length <= 140
      @client.update(message)
    else
      puts 'You message length should be less or equal than 140 characters!'
    end
  end

  def direct_message(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message

    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }

    unless screen_names.include?(target)
      puts "You can't send a message to the users, who don't follow you"
      return
    end

    message = "d @#{target} #{message}"
    tweet(message)
  end

  def followers_list
    screen_names = []

    @client.followers.each do |follower|
      screen_names << @client.user(follower).screen_name
    end

    screen_names
  end


  def spam_my_followers(message)
    screen_names = followers_list

    screen_names.each { |name| direct_message(name, message) }
  end

  public

  def everyones_last_tweet
    friends = @client.friends
    friends.each do |friend|
      name = @client.user(friend).screen_name
      time = @client.user(friend).status.created_at
      tweet = @client.user(friend).status.text
      
      puts "@#{name} last tweet, created at #{time.getgm} :\n#{tweet}"
      puts ''
    end
  end
end

blogger = MicroBlogger.new
blogger.everyones_last_tweet


