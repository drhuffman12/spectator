require "./expectation_partial"

module Spectator::Expectations
  # Expectation partial variation that operates on a value.
  struct ValueExpectationPartial(ActualType) < ExpectationPartial
    # Actual value produced by the test.
    # This is the value passed to the `#expect` call.
    getter actual

    # Creates the expectation partial.
    # The label should be a string representation of the actual value.
    # The actual value is stored for later use.
    protected def initialize(label : String, @actual : ActualType)
      super(label)
    end

    # Creates the expectation partial.
    # The label is generated by calling `#to_s` on the actual value.
    # The actual value is stored for later use.
    protected def initialize(@actual : ActualType)
      super(@actual.to_s)
    end
  end
end
