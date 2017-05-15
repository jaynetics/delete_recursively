class Pizza < ApplicationRecord
  belongs_to :programmer, dependent: :delete_recursively # lest he starve
  has_one :box, dependent: :delete_recursively
  has_many :toppings, class_name: 'Ingredient',
                      foreign_key: :dish_id,
                      dependent: :delete_recursively
end
