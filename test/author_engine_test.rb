require "test_helper"

class AuthorEngineTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::AuthorEngine::VERSION
  end
end
