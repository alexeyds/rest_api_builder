require 'rest_api_builder/helpers/string_helper'

module RestAPIBuilder
  module APIClient
    def define_resource_shortcuts(resources, resources_scope:, init_with:)
      resources.each do |name|
        class_name = RestAPIBuilder::Helpers::StringHelper.camelize(name.to_s)
        resource_class = Object.const_get("#{resources_scope}::#{class_name}")

        define_singleton_method(name) do
          init_with.call(resource_class)
        end
      end
    end
  end
end
