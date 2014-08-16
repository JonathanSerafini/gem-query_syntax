
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
    def spawn!(operator="AND", nested=false)
      scope = clone
      scope.scopes =  if nested
                        [NestedScope.new(operator, *scopes)]
                      else scopes.clone
                      end
      scope.scope!(operator)
      scope
    end

    #
    # Spawn returns a clone with self as a scope for nesting purposes
    #
    def spawn(operator="AND")
      spawn!(operator, true)
    end

    #
    # Spawn a new scopes
    #

    def where(args={})
      if args.nil? or args.empty? then spawn("AND")
      else spawn("AND").where!(args)
      end
    end

    def not(args={})
      scope = spawn("NOT")
      scope.where!(args)
    end

    def and(args={})
      scope = spawn("AND")
      scope.where!(args)
    end

    def or(args={})
      scope = spawn("OR")
      scope.where!(args)
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

