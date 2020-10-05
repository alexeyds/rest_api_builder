require "spec_helper"
require "rest_api_builder"

module ReadmeExamples
  module Resources
    class Octocat
      def orgs
        RestClient::Request.execute(method: :get, url: 'https://api.github.com/users/octocat/orgs')
      end
    end
  end
end

RSpec.describe "RestAPIBuilder::APIClient README", :http_request do
  GITHUB_API = Class.new do
    include RestAPIBuilder::APIClient

    def initialize
      define_resource_shortcuts(
        [:octocat],
        resources_scope: ReadmeExamples::Resources,
        init_with: ->(resource_class) { resource_class.new }
      )
    end
  end.new

  describe "#define_resource_shortcuts" do
    it 'defines shortcuts' do
      response = GITHUB_API.octocat.orgs

      expect(response.body).to eq('[]')
      expect(response.code).to eq(200)
    end
  end
end
