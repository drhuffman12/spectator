require "./result"

module Spectator
  class PendingResult < Result
    def passed?
      false
    end

    def failed?
      false
    end

    def errored?
      false
    end

    def pending?
      true
    end

    def initialize(@example)
      super(@example, Time::Span.zero)
    end
  end
end