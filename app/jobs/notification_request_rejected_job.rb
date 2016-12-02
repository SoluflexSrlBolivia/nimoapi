class NotificationRequestRejectedJob < ActiveJob::Base
  queue_as :urgent

  def perform(*args)
    # Do something later
  end
end
