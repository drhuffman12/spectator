require "./value_matcher"

module Spectator::Matchers
  # Matcher for checking that the contents of one array (or similar type)
  # has the exact same contents as another and in the same order.
  struct ArrayMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      actual = partial.actual.to_a
      values = ExpectedActual.new(expected, label, actual, partial.label)
      if values.expected.size == values.actual.size
        index = 0
        values.expected.zip(values.actual) do |expected, actual|
          return ContentMatchData.new(index, values) unless expected == actual
          index += 1
        end
        IdenticalMatchData.new(values)
      else
        SizeMatchData.new(values)
      end
    end

    # Common functionality for all match data for this matcher.
    private abstract struct CommonMatchData(ExpectedType, ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @values : ExpectedActual(ExpectedType, ActualType))
        super(matched)
      end

      # Basic information about the match.
      def named_tuple
        {
          expected: NegatableMatchDataValue.new(@values.expected),
          actual:   @values.actual,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@values.actual_label} contains exactly #{@values.expected_label}"
      end
    end

    # Match data specific to this matcher.
    # This type is used when the actual value matches the expected value.
    private struct IdenticalMatchData(ExpectedType, ActualType) < CommonMatchData(ExpectedType, ActualType)
      # Creates the match data.
      def initialize(values : ExpectedActual(ExpectedType, ActualType))
        super(true, values)
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} does not contain exactly #{@values.expected_label}"
      end
    end

    # Match data specific to this matcher.
    # This type is used when the actual size differs from the expected size.
    private struct SizeMatchData(ExpectedType, ActualType) < CommonMatchData(ExpectedType, ActualType)
      # Creates the match data.
      def initialize(values : ExpectedActual(ExpectedType, ActualType))
        super(false, values)
      end

      # Information about the match.
      def named_tuple
        super.merge({
          "expected size": NegatableMatchDataValue.new(@values.expected.size),
          "actual size":   @values.actual.size,
        })
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} does not contain exactly #{@values.expected_label} (size differs)"
      end
    end

    # Match data specific to this matcher.
    # This type is used when the actual contents differs from the expected contents.
    private struct ContentMatchData(ExpectedType, ActualType) < CommonMatchData(ExpectedType, ActualType)
      # Creates the match data.
      def initialize(@index : Int32, values : ExpectedActual(ExpectedType, ActualType))
        super(false, values)
      end

      # Information about the match.
      def named_tuple
        super.merge({
          index:              @index,
          "expected element": NegatableMatchDataValue.new(@values.expected[@index]),
          "actual element":   @values.actual[@index],
        })
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} does not contain exactly #{@values.expected_label} (content differs)"
      end
    end
  end
end