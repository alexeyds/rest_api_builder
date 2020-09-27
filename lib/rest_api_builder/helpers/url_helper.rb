module RestAPIBuilder
  module Helpers
    module UrlHelper
      module_function

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
