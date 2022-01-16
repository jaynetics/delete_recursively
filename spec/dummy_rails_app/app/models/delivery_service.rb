class DeliveryService < ApplicationRecord
  has_many :pizzas, dependent: :delete_recursively
  has_many :prices, dependent: :delete_recursively
end
