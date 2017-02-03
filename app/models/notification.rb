require 'net/http'
require 'openssl'

class Notification < ActiveRecord::Base
  belongs_to :user

	ONESIGNAL_APP_ID										= "950e90d5-74ca-42f4-b025-8c078d10201e"
	ONESIGNAL_API_KEY										= "MTgyNDlkMDQtNDdmNi00Y2ExLTliYmMtMzU4NTM3Y2IzYjhl"

	NOTIFICATION_NEW_COMMENT 						= "NOTIFICATION_NEW_COMMENT"
	NOTIFICATION_NEW_POST								= "NOTIFICATION_NEW_POST"
	NOTIFICATION_REQUEST_TO_JOIN_GROUP 	= "NOTIFICATION_REQUEST_TO_JOIN_GROUP"
	NOTIFICATION_GROUP_ACCEPTED					= "NOTIFICATION_GROUP_ACCEPTED"
	NOTIFICATION_GROUP_REJECTED					= "NOTIFICATION_GROUP_REJECTED"
  NOTIFICATION_NOTICE                 = "NOTIFICATION_NOTICE"
	NOTIFICATION_MEMBER_ADDED_TO_GROUP	= "NOTIFICATION_MEMBER_ADDED_TO_GROUP"

	def self.send_notification message, devices, extra_data
		params = {"app_id" => ONESIGNAL_APP_ID,
							"contents" => {"en" => message},
							"include_player_ids" => devices,
							"ios_sound" => "default",
							"android_sound" => "default",
							"data" => extra_data,
							"content_available" => 1,
							"mutable_content" => 1
		}
		uri = URI.parse('https://onesignal.com/api/v1/notifications')
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true

		request = Net::HTTP::Post.new(uri.path,
																	'Content-Type'  => 'application/json;charset=utf-8',
																	'Authorization' => "Basic #{ONESIGNAL_API_KEY}")
		request.body = params.as_json.to_json
		response = http.request(request)
		puts response.body
	end



end
