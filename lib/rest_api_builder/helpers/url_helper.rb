module RestAPIBuilder
  module Helpers
    module UrlHelper
      def full_url(url, path)
        if path
          File.join(url, path)
        else
          url
        end
      end
    end
  end
end
