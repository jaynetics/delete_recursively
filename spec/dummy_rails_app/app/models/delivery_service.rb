class DeliveryService < ActiveRecord::Base
  has_many :pizzas, dependent: :delete_recursively
end
