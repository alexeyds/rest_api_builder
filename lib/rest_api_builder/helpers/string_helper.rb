module RestAPIBuilder
  module Helpers
    module StringHelper
      module_function

      # From https://apidock.com/rails/String/camelize
      def camelize(string)
        string
          .sub(/^[a-z\d]*/, &:capitalize)
          .gsub(/(?:_|(\/))([a-z\d]*)/) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}" }
          .gsub("/", "::")
      end
    end
  end
end
