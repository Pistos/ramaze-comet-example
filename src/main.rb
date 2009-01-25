class MainController < Ramaze::Controller
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
