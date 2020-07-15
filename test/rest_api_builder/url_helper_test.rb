require "test_helper"
require "rest_api_builder/url_helper"

describe RestAPIBuilder::UrlHelper do
  include RestAPIBuilder::UrlHelper

  describe '#full_url' do
    it 'joins url with path' do
      assert_equal('test.com/things', full_url('test.com/', '/things'))
    end

    it 'returns url if path is nil' do
      assert_equal('test.com', full_url('test.com', nil))
    end
  end
end
