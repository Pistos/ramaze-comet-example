require 'rubygems'
require 'ramaze'

require 'file-tail'

$queue = []

File::Tail::Logfile.tail( 'ramaze-comet-example.log', :backward => 10 ) do |line|
  $queue << line
end

class MainController < Ramaze::Controller
  def index
    @file_contents = %{
      Hello there
      this is a file
    }
  end

  def next_lines
    sleep( rand( 5 ) )
    'line'
  end
end

Ramaze.start :adapter => :mongrel, :port => 7000