class Renter < ApplicationRecord
  has_many :letterboxes, dependent: :delete_all
end
