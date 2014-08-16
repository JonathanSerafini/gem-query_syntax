
require 'query_syntax/scope'
require 'query_syntax/scope/criteria'

module QuerySyntax
  #
  # Nested Scopes are scopes used for nesting other related scopes within ()
  #

  class NestedScope < Scope
    def initialize(operator, *scopes)
      super operator
      @scopes = scopes
    end

    attr_accessor :scopes

    #
    # Return a new CriteriaScope which is added to previous scopes
    #
    def scope!(operator)
      scope = CriteriaScope.new(operator)
      scopes << scope
      scope
    end

    def not!(args={})
      scope!("NOT")
      where!(args)
    end

    def and!(args={})
      scope!("AND")
      where!(args)
    end

    def or!(args={})
      scope!("OR")
      where!(args)
    end

    #
    # Return the last scope so that we can continue adding to it
    #
    def scope
      scope!("AND") if @scopes.empty?
      @scopes.last
    end

    #
    # Return the last scope's criteria
    #
    def conditions
      scope.conditions
    end

    #
    # Add criteria to the last scope
    #
    def where!(args={})
      scope.where!(args)
      self
    end

    #
    # Collapse all scopes to a string
    #
    def to_s
      values = scopes.map do |scope|
        operator = scope.operator
        value = scope.to_s
        next if value.empty?
        value = scope.is_a?(NestedScope) ? "(#{value})" : value
        [operator, value]
      end

      values = values.flatten
      values.shift
      values.join(" ")
    end
  end
end

