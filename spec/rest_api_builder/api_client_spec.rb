require "spec_helper"
require "rest_api_builder"

describe RestAPIBuilder::APIClient do
  class RestAPIBuilder::APIClient::MyResource
    def hello
      'Hello'
    end
  end

  describe '#define_resource_shortcuts' do
    it 'defines readers for each resource' do
      api_client_class = Class.new do
        include RestAPIBuilder::APIClient

        def initialize
          define_resource_shortcuts(
            [:my_resource],
            resources_scope: RestAPIBuilder::APIClient,
            init_with: ->(resource_class) { resource_class.new }
          )
        end
      end

      api_client = api_client_class.new
      expect(api_client.my_resource.hello).to eq('Hello')
    end
  end
end
