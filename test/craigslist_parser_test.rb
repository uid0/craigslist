require 'test_helper'
require 'mocha'

class CraigslistParserTest < ActiveSupport::TestCase
  def setup
    urls = [
      "http://sacramento.craigslist.org/search/eng?query=rails|ruby&srchType=A&addOne=telecommuting&format=rss",
      "http://sandiego.craigslist.org/search/eng?query=rails|ruby&srchType=A&addOne=telecommuting&format=rss",
      "http://sfbay.craigslist.org/search/eng?query=rails|ruby&srchType=A&addOne=telecommuting&format=rss",
      "http://slo.craigslist.org/search/eng?query=rails|ruby&srchType=A&addOne=telecommuting&format=rss",
      "http://santabarbara.craigslist.org/search/eng?query=rails|ruby&srchType=A&addOne=telecommuting&format=rss"
      ]
    @parser = Craigslist::Parser.new
    @parser.stubs(:feed_urls).returns(urls)
  end
  
  def teardown
    Craigslist::Posting.destroy_all
  end
  
  def test_schema_loaded
    assert_equal([], Craigslist::Posting.all)
  end
  
  def test_parser_default_search_path
    @parser = Craigslist::Parser.new
    assert_equal(Craigslist::Parser::DEFAULT_SEARCH_PATH, @parser.search_path)
  end
  
  def test_parser_feed_urls
    assert_not_nil(@parser.feed_urls)
    assert(@parser.feed_urls.length > 1)
  end
  
  def test_parser_get_postings
    postings = @parser.get_postings(:url => "http://sfbay.craigslist.org/search/eng?query=rails|ruby&srchType=A&addOne=telecommuting&format=rss")
    assert_not_nil(postings)
  end
end
