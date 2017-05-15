class Letterbox < ApplicationRecord
  has_many :letters, dependent: :destroy
end
