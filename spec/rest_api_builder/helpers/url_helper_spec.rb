require "spec_helper"
require "rest_api_builder/helpers/url_helper"

RSpec.describe RestAPIBuilder::Helpers::UrlHelper do
  include RestAPIBuilder::Helpers::UrlHelper

  describe '#full_url' do
    it 'joins url with path' do
      expect(full_url('test.com/', '/things')).to eq('test.com/things')
    end

    it 'returns url if path is nil' do
      expect(full_url('test.com', nil)).to eq('test.com')
    end
  end
end
