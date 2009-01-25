require 'rubygems'
require 'ramaze'

require 'file/tail'

class Producer
  def initialize
    @lines = []
    @seen_pointers = Hash.new( 0 )
    @mutex = Mutex.new

    @thread = Thread.new do
      File::Tail::Logfile.tail( 'ramaze-comet-example.log', :backward => 10 ) do |line|
        @mutex.synchronize do
          @lines << line
        end
      end
    end
  end

  def new_lines( subscriber_id )
    @mutex.synchronize do
      ptr = @seen_pointers[ subscriber_id ]
      @seen_pointers[ subscriber_id ] = @lines.size
      @lines[ ptr..-1 ]
    end
  end
end

class ChatChannel
  STATES = {}
  ATIMES = {}
  TIMEOUT = 10

  def initialize
  end

  def new_lines(subscriber_id)
    state = touch(subscriber_id)
    if state.empty?
      []
    else
      [ state.shift ]
    end
  end

  def touch(subscriber_id)
    ATIMES[subscriber_id] = Time.now
    STATES[subscriber_id] ||= Queue.new
  end

  def gc
    limit = Time.now - TIMEOUT
    STATES.delete_if{|k,v| ATIMES[k] < limit }
    ATIMES.delete_if{|k,v| v < limit }
  end

  def push(obj)
    gc
    STATES.each{|k,v| p k => v; v.push(obj) }
  end
end

$producer ||= Producer.new
#$producer ||= ChatChannel.new

if $producer.is_a? ChatChannel
  # Produce random lines, simulating chat
  Thread.new do
    counter = 0

    loop do
      $producer.push("random #{counter}: #{rand}")
      counter += 1
      sleep rand(10)
    end
  end
end

# ------------------------------------------------------------

class MainController < Ramaze::Controller
  def index
  end

  def next_lines
    60.times do
      lines = $producer.new_lines( session.session_id )
      if lines.any?
        Ramaze::Log.debug "New data!"
        return lines
      end

      Ramaze::Log.debug "Waiting for data..."
      sleep 1
    end

    Ramaze::Log.debug "(timeout waiting for producer)"
    ''
  end
end

Ramaze.start :adapter => :mongrel, :port => 7001
