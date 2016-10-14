require 'net/http'
require 'openssl'

class Notification < ActiveRecord::Base
  belongs_to :user
  #notification_type, 1:normal new, 2:request to acces to some group, 3:accepted, 4:rejected
	NOTIFICATION_TYPE_NORMAL_NEWS				= 1
	NOTIFICATION_TYPE_REQUEST_GROUP			= 2
	NOTIFICATION_TYPE_GROUP_ACCEPT			= 3
	NOTIFICATION_TYPE_GROUP_REJECT			= 4

	NOTIFICATION_NEW_COMMENT 						= "NOTIFICATION_NEW_COMMENT"
	NOTIFICATION_NEW_POST								= "NOTIFICATION_NEW_POST"
	NOTIFICATION_REQUEST_TO_JOIN_GROUP 	= "NOTIFICATION_REQUEST_TO_JOIN_GROUP"
	NOTIFICATION_GROUP_ACCEPTED					= "NOTIFICATION_GROUP_ACCEPTED"
	NOTIFICATION_GROUP_REJECTED					= "NOTIFICATION_GROUP_REJECTED"
  NOTIFICATION_NOTICE                 = "NOTIFICATION_NOTICE"

  def send_notification
  	action = eval self.action
    if self.user.devices.count > 0

			uri = URI.parse('http://api.devicepush.com/send')
			
			header = {"Content-Type": "application/x-www-form-urlencoded\r\ntoken: #{USER_ID}"}
			request = Net::HTTP::Post.new(uri.path, initheader = header)
			request.set_form_data(
				'idApplication' => PUSH_idApplication, 
		    'idDevice' => self.user.devices.map{|d| d.idDevice},
		    'icon' => 'default',
		    'title' => self.title,
		    'content' => self.message,
		    'sound' => 'default',
		    'vibrate' => true,
		    'badge' => 0
			)
			res = Net::HTTP.start(uri.hostname, uri.port) do |http|
			  http.request(request)
			end

			case res
				when Net::HTTPSuccess, Net::HTTPRedirection
				  puts "bien:#{res.body}"
				else
				  puts "mal:#{res.value}"
			end
		end
  end

  def self.send_notification title, message, idDevices
  	uri = URI.parse('http://api.devicepush.com/send')
		
		header = {"Content-Type": "application/x-www-form-urlencoded\r\ntoken: #{USER_ID}"}
		request = Net::HTTP::Post.new(uri.path, initheader = header)
		request.set_form_data(
			'idApplication' => PUSH_idApplication, 
	    'idDevice' => idDevices,
	    'icon' => 'default',
	    'title' => title,
	    'content' => message,
	    'sound' => 'default',
	    'vibrate' => true,
	    'badge' => 0
		)
		res = Net::HTTP.start(uri.hostname, uri.port) do |http|
		  http.request(request)
		end

		case res
			when Net::HTTPSuccess, Net::HTTPRedirection
			  puts "bien:#{res.body}"
			else
			  puts "mal:#{res.value}"
		end
  end
end
