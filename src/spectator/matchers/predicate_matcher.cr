require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests one or more predicates (methods ending in `?`).
  # The `ExpectedType` type param should be a `NamedTuple`.
  # Each key in the tuple is a predicate (without the `?`) to test.
  struct PredicateMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial)
      actual = partial.actual

      # Test each predicate and immediately return false if one is false.
      {% for attribute in ExpectedType.keys %}
      return false unless actual.{{attribute}}?
      {% end %}

      # All checks passed if this point is reached.
      true
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial)
      "Expected #{partial.label} to be #{label}"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial)
      "Expected #{partial.label} to not be #{label}"
    end
  end
end
