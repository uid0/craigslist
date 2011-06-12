require 'test_helper'

class CraigslistPostingTest < ActiveSupport::TestCase
  def teardown
    Craigslist::Posting.destroy_all
  end
  
  def test_schema_loaded
    assert_equal([], Craigslist::Posting.all)
  end
end
