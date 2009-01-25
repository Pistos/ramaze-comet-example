require 'rubygems'
require 'ramaze'

Ramaze::acquire 'src/*'

$producer ||= TailerQueue.new

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

Ramaze.start :adapter => :mongrel, :port => 7001
