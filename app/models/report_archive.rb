class ReportArchive < ActiveRecord::Base
  belongs_to :archive
  belongs_to :group

  attr_accessor :informer

  def informer
    User.find self.informer_id
  end
end
