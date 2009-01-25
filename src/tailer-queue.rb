require 'file/tail'

# Tails a file and lets subscribers retrieve the lines asynchronously.

class TailerQueue
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

