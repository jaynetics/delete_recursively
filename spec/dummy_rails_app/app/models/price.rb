class Price < ApplicationRecord
  belongs_to :delivery_service
  belongs_to :product, polymorphic: true, dependent: :delete_recursively
end
