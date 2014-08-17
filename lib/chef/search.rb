
class Chef
  class Search
    def self.add_query(name, index = :node)
      self.class.instance_eval do
        define_method "#{name}" do
          instance_variable_get("@#{name}")
        end

        define_method "#{name}=" do |value|
          instance_variable_set("@#{name}",value)
        end
      end

      instance_variable_set("@#{name}", QuerySyntax::Query.new(index))
    end
  end
end

