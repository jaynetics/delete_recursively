class Pizza < ApplicationRecord
  belongs_to :programmer, dependent: :delete_recursively # lest he starve
  belongs_to :baker, class_name: 'Pizza::Baker', dependent: :destroy
  has_one :box, dependent: :delete_recursively
  has_many :toppings, class_name: 'Ingredient',
                      foreign_key: :dish_id,
                      dependent: :delete_recursively
  has_many :flavors
  has_one :price, as: :product
end
