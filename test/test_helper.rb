require 'minitest/autorun'
require 'minitest/reporters'
require 'webmock/minitest'

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]
