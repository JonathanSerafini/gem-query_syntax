
require 'query_syntax/scope'

module QuerySyntax
  class Query < NestedScope
    def initialize(index)
      super "AND"
      @index = index
      @ignore_failure = true
    end

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

    def search(&block)
      begin
        if Kernel.block_given?
          Chef::Search::Query.new.search(index, encode, &block)
        else 
          results = Array.new
          search { |result| results << result }
          results
        end
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

      begin
        if Kernel.block_given?
          Chef::PartialSearc.new.search(index, encode, keys:keys, &block)
        else
          results = Array.new
          partial(keys) { |result| results << result }
          results
        end
      rescue Net::HTTPServerException => e
        error = Chef::JSONCompat.from_json(e.response.body)["error"].first
        Chef::Log.error("Search failed with : #{error}")

        if @ignore_failure
        then Array.new
        else raise Net::HTTPServerException
        end
      end
    end

    def each(&block)
      search(&block)
    end
  end
end

