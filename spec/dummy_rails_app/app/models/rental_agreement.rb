class RentalAgreement < ApplicationRecord
  belongs_to :renter
  belongs_to :house
end
