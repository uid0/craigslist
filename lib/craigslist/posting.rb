module Craigslist
  class Posting < ActiveRecord::Base
    set_table_name "craigslist_postings"
    
    validates :title, :presence => true, :uniqueness => {:scope => :posted_at}
    validates :link, :presence => true
    validates :description, :presence => true

    # Determine and document:
    # * contact methods
    # ...for this posting
    # Puts the phone number in the format XXX.XXX.XXXX, and extracts the email if one exists
    def process_contact_info
      phone_regex = /\(?\d{3}+\)?[\s\-\.]*\d{3}[\s\-\.]*\d{4}/
      phone_match = description.match(phone_regex)
      self.phone = phone_match.to_s.gsub(/[\(\s]+/, '').gsub(/[\)\-]/, '.')
      
      email_regex = /[A-Z0-9._%-]+@[A-Z0-9.-]+\.(?:com|org|net|biz|info|name|aero|jobs|museum|edu|pro|[A-Z]{2})/xi
      email_match = description.match(email_regex)
      self.email = email_match.to_s
      save
    end

    def process
      process_contact_info
    end
  end
end
