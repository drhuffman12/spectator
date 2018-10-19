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

    # Asserts that the `#actual` value matches some criteria.
    # The criteria is defined by the matcher passed to this method.
    def to(matcher : Matchers::ValueMatcher(ExpectedType)) : Nil forall ExpectedType
      expectation = ValueExpectation.new(self, matcher)
      result = expectation.eval
      Internals::Harness.current.report_expectation(result)
    end

    # Asserts that the `#actual` value *does not* match some criteria.
    # This is effectively the opposite of `#to`.
    def to_not(matcher : Matchers::ValueMatcher(ExpectedType)) : Nil forall ExpectedType
      expectation = ValueExpectation.new(self, matcher)
      result = expectation.eval(true)
      Internals::Harness.current.report_expectation(result)
    end

    # ditto
    @[AlwaysInline]
    def not_to(matcher : Matchers::ValueMatcher(ExpectedType)) : Nil forall ExpectedType
      to_not(matcher)
    end
  end
end
