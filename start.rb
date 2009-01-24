require 'rubygems'
require 'ramaze'

require 'file/tail'

$lines = []
$mutex = Mutex.new

$producer ||= Thread.new do
  File::Tail::Logfile.tail( 'ramaze-comet-example.log' ) do |line|
    $mutex.synchronize do
      $lines << line
    end
  end
end

class MainController < Ramaze::Controller
  def index
    @file_contents = %{
      Hello there
      this is a file
    }
    session[ :ptr ] = 0
  end

  def next_lines
    catch :new_data do
      loop do
        $mutex.synchronize do
          if $lines.size > session[ :ptr ]
            Ramaze::Log.debug "New data!"
            throw :new_data
          end
        end
        Ramaze::Log.debug "Waiting for data..."
        sleep 3
      end
    end

    lines = nil
    $mutex.synchronize do
      lines = $lines[ session[ :ptr ]..-1 ]
      session[ :ptr ] = $lines.size
    end
    lines
  end
end

Ramaze.start :adapter => :mongrel, :port => 7000