class ChatChannel
  STATES = {}
  ATIMES = {}
  TIMEOUT = 10

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
