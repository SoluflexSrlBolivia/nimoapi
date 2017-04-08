class ReportPost < ActiveRecord::Base
  belongs_to :post
  belongs_to :group

  def informer
    User.find self.informer_id
  end
end
