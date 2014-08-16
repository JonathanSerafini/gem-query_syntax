
class Chef
  class Search
    def self.add_query(name, index = :node)
      self.class.instance_eval do
        define_method "#{name}" { instance_variable_get("@#{name}") }
        define_method "#{name}" { |val| instance_variable_set("@#{name}",val) }
      end

      instance_variable_set("@#{name}", QuerySyntax::Query.new(index))
    end
  end
end

