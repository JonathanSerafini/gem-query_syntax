# QuerySyntax

Provides chainable objects to build Chef search queries as well as a method to share, re-use and extend queries.

## Installation

Add this line to your application's Gemfile:

    gem 'query_syntax'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install query_syntax

** NOTE ** Updated, as of 1.0.4 only compatible with newer chefs with filter_results

## Usage

QuerySyntax::Query provides bang and non-bang methods for and, or, not, where which determine whether we are modifying the current object or whether we are returning a new object. In most cases though, QuerySyntax will return the QuerySyntax object so that we can chain at will.

The following methods are most likely to be used : 

`.where!(hash)` 
An AND-ed hash of criteria to search for within a single (scope). If multiple values are provided for a single key from subsequent where! or where calls, then the value is converted to an array of values which are OR-ed.

Also notice that, as long as we chain where!, we are contribution criteria to the same scope.

```
Query.where!(a:1).to_s
> a:1

Query.where!(a:1, b:1).to_s
> (a:1 AND b:1)

Query.where!(a:1, b:1).where!(a:2,b:2).to_s
> ((a:1 OR a:2) AND (b:1 OR b:2))
```

`.and!(hash)`
Very similar to where!, we add additional criteria which we AND to the query. Unlike where!, however, and! generates a new (scope).

If and! is specified without a hash, we decide that the entire left most portion of the statement is to be made it's own composite scope.

```
Query.where!(a:1, b:1).where!(a:2,b:2).to_s
> ((a:1 OR a:2) AND (b:1 OR b:2))

Query.where!(a:0,b:1).where!(a:2,b:2).and!(a:2,b:2).to_s
> ((a:0 OR a:2) AND (b:1 OR b:2)) AND (a:2 AND b:2)
```

`.or!(hash) and .not!(hash)` function exactly like .and, however with a different operator than AND.

`.push(object)` may be used to begin with a baseline and build on top of it.

# Examples
```
# Create a baseline query
Chef::Search.add_query("base")
Chef::Search.base.
  where!(chef_environment:"production").to_s
> chef_environment:production

# Create peers query
Chef::Search.add_query("peers")
Chef::Search.peers.push(Chef::Search.base).
  where!(roles:"load_balancer").to_s
> chef_environment:production AND roles:load_balancer

# Update the baseline
Chef::Search.base.
  not!(tags:"maintenance").to_s
> chef_environment:production NOT tags:maintenance

Chef::Search.peers.to_s
> (chef_environment:production NOT tags:maintenance) AND roles:load_balancer

# Return an updated peers query for single use, notice there's no ! symbol
Chef::Search.peers.where(roles:"shard1").to_s
> (chef_environment:production NOT tags:maintenance) AND roles:load_balancer AND roles:shard1

Chef::Search.base.to_s
# Unchanged
> chef_environment:production NOT tags:maintenance

Chef::Search.peers.to_s
# Unchanged
> (chef_environment:production NOT tags:maintenance) AND roles:load_balancer

# Perform a search
Chef::Search.peers.search.map { |item| item.node_name }
> [node,node,node]

# Perform a partial search
# notice we automatically ensure values are Arrays when they are strings
Chef::Search.peers.partial(
  keys:{chef_environment:"chef_environment",hostname:["hostname"]
)
> [{chef_environment:"production", hostname:"host1"}]
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/query_syntax/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
