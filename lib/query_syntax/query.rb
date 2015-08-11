
require 'query_syntax/scope'

module QuerySyntax
  class Query < NestedScope
    def initialize(index)
      super "AND"
      @index = index
      @ignore_failure = true
    end

    attr_reader :index
    attr_accessor :ignore_failure

    #
    # Spawn! returns a clone to continue processing without mucking self
    #
    def spawn(operator="AND")
      scope = clone
      scope.scopes = scopes.clone
      scope.scope!(operator)
      scope
    end

    #
    # Spawn a new scopes
    #

    def where(args={})
      scope = spawn("AND")
      scope.where!(args) if args
    end

    def not(args={})
      scope = spawn("NOT")
      scope.not!(args)
    end

    def and(args={})
      scope = spawn("AND")
      scope.and!(args)
    end

    def or(args={})
      scope = spawn("OR")
      scope.or!(args)
    end

    #
    # Search related methods
    #
    def encode
      URI.escape(to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end

    def search(*args, &block)
      begin
        Chef::Search::Query.new.search(index, encode, args, &block)
      rescue Net::HTTPServerException => e
        error = Chef::JSONCompat.from_json(e.response.body)["error"].first
        Chef::Log.error("Search failed with : #{error}")

        if @ignore_failure
        then Array.new
        else raise Net::HTTPServerException
        end
      end
    end

    def partial(keys, &block)
      keys = Hash[keys.map { |k,v| [k,Array(v)] }]
      Chef::Search::Query.new.search(filter_result: keys, &block)
    end

    def each(&block)
      search(&block)
    end
  end
end

