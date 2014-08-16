
module QuerySyntax
  #
  # Scopes are conditions seperated by operators (NOT | AND | OR)
  #

  class Scope
    def initialize(operator="AND")
      @operator = operator
    end

    attr_accessor :operator
  end
end

require 'query_syntax/scope/criteria'
require 'query_syntax/scope/nested'

