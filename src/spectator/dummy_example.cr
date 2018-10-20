require "./runnable_example"

module Spectator
  # Example that does nothing.
  # This is to workaround a Crystal compiler bug.
  # See: [Issue 4225](https://github.com/crystal-lang/crystal/issues/4225)
  # If there are no concrete implementations of an abstract class,
  # the compiler gives an error.
  # The error indicates an abstract method is undefined.
  # This class shouldn't be used, it's just to trick the compiler.
  private class DummyExample < RunnableExample
    # Dummy description.
    def what
      "DUMMY"
    end

    # Dummy run that does nothing.
    def run_instance
      # ...
    end
  end
end