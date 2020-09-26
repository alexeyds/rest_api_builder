require "spec_helper"
require "rest_api_builder/url_helper"

describe RestAPIBuilder::UrlHelper do
  include RestAPIBuilder::UrlHelper

  describe '#full_url' do
    it 'joins url with path' do
      expect(full_url('test.com/', '/things')).to eq('test.com/things')
    end

    it 'returns url if path is nil' do
      expect(full_url('test.com', nil)).to eq('test.com')
    end
  end
end
