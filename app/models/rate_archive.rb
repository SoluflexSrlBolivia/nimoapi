class RateArchive < ActiveRecord::Base
  belongs_to :user
  belongs_to :archive

  validates :user_id, presence: true
  validates :archive_id, presence: true
end
