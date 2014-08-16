
require 'forwardable'
require 'query_syntax/scope'

module QuerySyntax
  #
  # Criteria Scopes are scopes containing key:value conditions
  # ex.: where!(a:0, b:1).where!(a:2) becomes (a=0 OR a=2) AND b=1
  #

  class CriteriaScope < Scope
    extend Forwardable

    def initialize(operator, conditions={})
      super operator
      @conditions = conditions
      where!(conditions)
    end

    attr_accessor :conditions

    def_delegators(:@conditions, 
      *(Hash.instance_methods - Object.instance_methods))

    def where!(args={})
      args.each do |k,v|
        next if v.nil?
        @conditions[k] = [] unless conditions.key?(k)
        @conditions[k].concat(Array(v)).uniq!
      end
      self
    end

    #
    # Collapse all conditions to a string
    #
    def to_s
      @conditions.map do |key,values|
        query = values.map { |value| "#{key}:#{value}" }.join(" OR ")
        values.count > 1 ? "(#{query})" : query
      end.join(" AND ")
    end
  end
end

