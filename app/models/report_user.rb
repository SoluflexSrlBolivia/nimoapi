class ReportUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  def informer
    User.find self.informer_id
  end
end
