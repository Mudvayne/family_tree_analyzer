class GedcomFile < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :filename
end
