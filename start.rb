require 'rubygems'
require 'ramaze'

Ramaze::acquire 'src/*'

$tailer ||= TailerQueue.new
$chitchat ||= ChatChannel.new

# Produce random lines, simulating chat
Thread.new do
  counter = 0

  loop do
    $chitchat.push("random #{counter}: #{rand}")
    counter += 1
    sleep rand(10)
  end
end

Ramaze.start :adapter => :mongrel, :port => 7001
