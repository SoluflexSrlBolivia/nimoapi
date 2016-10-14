class Alias < ActiveRecord::Base
  belongs_to :aliasable, polymorphic: true
  has_one :archive, :as=> :archivable, dependent: :destroy

  validates :name,  presence: true
  
end
