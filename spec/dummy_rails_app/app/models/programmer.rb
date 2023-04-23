class Programmer < ApplicationRecord
  has_one :colleague, class_name: 'Programmer', foreign_key: :colleague_id,
          dependent: :delete_recursively # they like to quit in waves
  has_one :compensation, as: :beneficiary, class_name: 'Pizza',
          dependent: :delete_recursively
end
