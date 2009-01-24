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

  def new_lines( ptr_id )
    @mutex.synchronize do
      ptr = @seen_pointers[ ptr_id ]
      @seen_pointers[ ptr_id ] = @lines.size
      @lines[ ptr..-1 ]
    end
  end
end

$producer ||= Producer.new

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

Ramaze.start :adapter => :mongrel, :port => 7000