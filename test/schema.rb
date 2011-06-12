ActiveRecord::Schema.define(:version => 0) do
  create_table :craigslist_postings do |t|
    t.string :title
    t.string :link
    t.text :description
    t.string :language
    t.string :rights
    t.datetime :posted_at
    t.timestamps
  end
end
