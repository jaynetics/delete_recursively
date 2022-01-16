class DoomsdayDevice < ApplicationRecord
  has_one :price, as: :product, dependent: :delete_recursively
end
