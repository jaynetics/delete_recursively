class DeliveryService < ApplicationRecord
  has_many :pizzas, dependent: :delete_recursively
end
