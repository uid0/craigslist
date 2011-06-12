require 'active_support'
require 'craigslist/posting'
require 'open-uri'
require 'nokogiri'

module Craigslist
  class Parser < Object
    MAIN_URL = 'http://craigslist.com'
    DEFAULT_SEARCH_PATH = "/search/eng?query=rails|ruby&srchType=A&addOne=telecommuting&format=rss"

    attr_reader :search_path
    attr_reader :postings

    # :search_path = craigslist search path minus the protocol and host name. You need to pass this
    #   value unless you specifically want "internet engineer" job postings returned from the parser
    #   DEFAULT_SEARCH_PATH = "/search/eng?query=rails|ruby&srchType=A&addOne=telecommuting&format=rss".
    #   Pass your own path for different postings (Note: I've not tested other postings, I just don't care
    #   right now.)
    def initialize(args = {})
      @search_path = args[:search_path] || DEFAULT_SEARCH_PATH
      @postings = []
      @world_feed_urls = []
    end

    def feed_urls(force = false)
      return @world_feed_urls unless force || @world_feed_urls.nil? || @world_feed_urls.empty?
      begin
        doc = Nokogiri::HTML(open(MAIN_URL))
      rescue Exception => e
        Rails.logger.error(e)
        return nil
      end
      doc.css('.colleft a').each do |link|
        url = "#{link.attr('href')}#{@search_path}"
        puts ">>> Adding: [#{url}]"
        @world_feed_urls << url
      end
      @world_feed_urls
    end
    
    def before_get_postings; end
    def after_get_postings; end

    # This is a long operation, so use callback hooks for before and after
    # :url  => override get_feed_urls with this single url, good for testing
    # :count  => stop and return as soon as we get at least this many results
    def get_postings(args = {})
      before_get_postings
      urls = []
      if args[:url]
        urls << args[:url]
      else
        urls = feed_urls
      end
      urls.each do |url|
        begin
          # puts ">>> url: [#{url}]"
          doc = Nokogiri::XML(open(URI.escape(url)))
        rescue Exception => e
          Rails.logger.error(e)
        end
        doc.css('item').each do |item|
          begin
            @postings << Craigslist::Posting.create!(
              :title       => item.css('title').text,
              :link        => item.css('link').text,
              :description => item.css('description').text,
              :posted_at   => Time.parse(item.css('dc|date').text).gmtime,
              :language    => item.css('dc|language').text
            )
          rescue Exception => e
            Rails.logger.error(e)
          end
        end if doc
        break if args[:count] && @postings.length >= args[:count]
      end
      after_get_postings
      @postings
    end
  end
end