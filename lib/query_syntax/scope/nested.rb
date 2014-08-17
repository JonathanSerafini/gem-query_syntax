
require 'forwardable'
require 'query_syntax/scope'
require 'query_syntax/scope/criteria'

module QuerySyntax
  #
  # Nested Scopes are scopes used for nesting other related scopes within ()
  #

  class NestedScope < Scope
    extend Forwardable
    
    def initialize(operator, *scopes)
      super operator
      @scopes = scopes
    end

    attr_accessor :scopes
    
    def_delegators(:@scopes, 
      *(Array.instance_methods - Object.instance_methods))

    #
    # Return a new CriteriaScope which is added to previous scopes
    #
    def scope!(operator)
      scope = CriteriaScope.new(operator)
      scopes << scope
      self
    end

    def nest!(operator)
      @scopes = [NestedScope.new(operator, *scopes)]
      scope!(operator)
      self
    end

    def not!(args={})
      if args.empty? then nest!("NOT")
      else scope!("NOT").where!(args)
      end
      self
    end

    def and!(args={})
      if args.empty? then nest!("AND")
      else scope!("AND").where!(args)
      end
      self
    end

    def or!(args={})
      if args.empty? then nest!("OR")
      else scope!("OR").where!(args)
      end
      self
    end

    #
    # Return the last scope so that we can continue adding to it
    #
    def scope
      scope!(operator)  if @scopes.empty?
      scope!("AND")     if @scopes.last.is_a?(NestedScope)
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
    # Convenience
    #

    def empty?
      compact.empty?
    end

    def compact
      scopes.reject { |scope| scope.empty? }
    end

    def compact!
      scopes = compact
      self
    end

    def push(other)
      scopes << other
      scope!(operator)
      self
    end

    #
    # Collapse all scopes to a string
    #
    def to_s
      values = compact.map do |scope|
        value = scope.to_s
        value = if scope.is_a?(NestedScope)
                  scope.compact.count > 1 ? "(#{value})" : value
                else value
                end
        [scope.operator, value]
      end

      values = values.flatten
      values.shift
      values.join(" ")
    end
  end
end

