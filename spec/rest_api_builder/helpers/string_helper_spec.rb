require "spec_helper"
require "rest_api_builder/helpers/string_helper"

describe RestAPIBuilder::Helpers::StringHelper do
  include RestAPIBuilder::Helpers::StringHelper

  describe '#camelize' do
    it 'camelizes string' do
      expect(camelize("foo_bar")).to eq("FooBar")
    end
  end
end
