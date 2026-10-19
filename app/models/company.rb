class Company < ApplicationRecord
  has_many :employees
  has_many :assessments
  has_many :admin_users
end
