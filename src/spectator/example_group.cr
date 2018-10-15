require "./example_component"

module Spectator
  abstract class ExampleGroup < ExampleComponent
    include Enumerable(ExampleComponent)
    include Iterable(ExampleComponent)

    def initialize(@hooks : ExampleHooks)
      @before_all_hooks_run = false
      @after_all_hooks_run = false
    end

    private getter! children : Array(ExampleComponent)

    def children=(children : Array(ExampleComponent))
      raise "Attempted to reset example group children" if @children
      @children = children
    end

    def each
      children.each do |child|
        yield child
      end
    end

    def each : Iterator(ExampleComponent)
      children.each
    end

    def example_count : Int
      children.sum(&.example_count)
    end

    def [](index : Int) : Example
      raise IndexError.new if index < 0
      offset = index
      found = children.find do |child|
        count = child.example_count
        if offset < count
          true
        else
          offset -= count
          false
        end
      end
      if found
        found[offset]
      else
        raise IndexError.new
      end
    end

    # TODO: Remove this method.
    def all_examples
      Array(Example).new(example_count).tap do |array|
        children.each do |child|
          if child.is_a?(Example)
            array << child
          else
            array.concat(child.as(ExampleGroup).all_examples)
          end
        end
      end
    end

    def finished? : Bool
      children.all?(&.finished?)
    end

    def run_before_all_hooks : Nil
      unless @before_all_hooks_run
        @hooks.run_before_all
        @before_all_hooks_run = true
      end
    end

    def run_before_each_hooks : Nil
      @hooks.run_before_each
    end

    def run_after_all_hooks : Nil
      unless @after_all_hooks_run
        if finished?
          @hooks.run_after_all
          @after_all_hooks_run = true
        end
      end
    end

    def run_after_each_hooks : Nil
      @hooks.run_after_each
    end

    def wrap_around_each_hooks(&block : ->) : ->
      @hooks.wrap_around_each(&block)
    end
  end
end
