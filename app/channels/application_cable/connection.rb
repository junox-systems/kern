module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_operator

    def connect
      set_current_operator || reject_unauthorized_connection
    end

    private
      def set_current_operator
        if session = Session.find_by(id: cookies.signed[:session_id])
          self.current_operator = session.operator
        end
      end
  end
end
