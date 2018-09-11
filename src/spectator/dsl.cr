require "./example_group"

module Spectator
  module DSL
    macro describe(what, type = "Describe", &block)
      context({{what}}, {{type}}) {{block}}
    end

    macro context(what, type = "Context", &block)
      {% safe_name = what.id.stringify.gsub(/\W+/, "_") %}
      {% module_name = (type.id + safe_name.camelcase).id %}
      {% context_module = CONTEXT_MODULE %}
      {% parent_given_vars = GIVEN_VARIABLES %}
      module {{module_name.id}}
        include ::Spectator::DSL

        CONTEXT_MODULE = {{context_module.id}}::{{module_name.id}}
        GIVEN_VARIABLES = [
          {{ parent_given_vars.join(", ").id }}
        ]{% if parent_given_vars.empty? %} of Object{% end %}

        module Locals
          include {{context_module.id}}::Locals

          {% if what.is_a?(Path) %}
            def described_class
              {{what}}
            end
          {% end %}
        end

        {{block.body}}
      end
    end

    macro it(description, &block)
      {% safe_name = description.id.stringify.gsub(/\W+/, "_") %}
      {% class_name = (safe_name.camelcase + "Example").id %}
      {% given_vars = GIVEN_VARIABLES %}
      {% var_names = given_vars.map { |v| v[0] } %}
      class {{class_name.id}} < ::Spectator::Example
        include Locals

        {% unless given_vars.empty? %}
          def initialize({{ var_names.join(", ").id }})
            {% for var_name in var_names %}
              self.{{var_name}} = {{var_name}}
            {% end %}
          end
        {% end %}

        def run
          {{block.body}}
        end
      end

      {% if given_vars.empty? %}
        ::Spectator::ALL_EXAMPLES << {{class_name.id}}.new
      {% else %}
        {% for given_var in given_vars %}
          {% var_name = given_var[0] %}
          {% collection = given_var[1] %}
          {{collection}}.each do |{{var_name}}|
        {% end %}
        ::Spectator::ALL_EXAMPLES << {{class_name.id}}.new({{var_names.join(", ").id}})
        {% for given_var in given_vars %}
          end
        {% end %}
      {% end %}
    end

    def it_behaves_like
      raise NotImplementedError.new("Spectator::DSL#it_behaves_like")
    end

    macro subject(&block)
      let(:subject) {{block}}
    end

    macro let(name, &block)
      let!({{name}}!) {{block}}

      module Locals
        @%wrapper : ValueWrapper?

        def {{name.id}}
          if (wrapper = @%wrapper)
            wrapper.as(TypedValueWrapper(typeof({{name.id}}!))).value
          else
            {{name.id}}!.tap do |value|
              @%wrapper = TypedValueWrapper(typeof({{name.id}}!)).new(value)
            end
          end
        end
      end
    end

    macro let!(name, &block)
      module Locals
        def {{name.id}}
          {{block.body}}
        end
      end
    end

    macro given(collection, &block)
      context({{collection}}, "Given") do
        {% var_name = block.args.empty? ? "value".id : block.args.first %}
        {% if GIVEN_VARIABLES.find { |v| v[0].id == var_name.id } %}
          {% raise "Duplicate given variable name \"#{var_name.id}\"" %}
        {% end %}

        module Locals
          @%wrapper : ValueWrapper?

          private def %collection
            {{collection}}
          end

          private def %collection_first
            %collection.first
          end

          def {{var_name.id}}
            @%wrapper.as(TypedValueWrapper(typeof(%collection_first))).value
          end

          private def {{var_name.id}}=(value)
            @%wrapper = TypedValueWrapper(typeof(%collection_first)).new(value)
          end
        end

        {% GIVEN_VARIABLES << {var_name, collection} %}

        {{block.body}}
      end
    end

    def before_all
      raise NotImplementedError.new("Spectator::DSL#before_all")
    end

    def before_each
      raise NotImplementedError.new("Spectator::DSL#before_each")
    end

    def after_all
      raise NotImplementedError.new("Spectator::DSL#after_all")
    end

    def after_each
      raise NotImplementedError.new("Spectator::DSL#after_each")
    end

    def around_each
      raise NotImplementedError.new("Spectator::DSL#around_each")
    end

    def include_examples
      raise NotImplementedError.new("Spectator::DSL#include_examples")
    end
  end
end
