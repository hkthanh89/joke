class Joke < ActiveRecord::Base

  scope :find_unread_jokes, ->(read_joke_ids) { where.not(id: read_joke_ids) }
end
