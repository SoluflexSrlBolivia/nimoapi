require 'net/http'
require 'openssl'

class Device < ActiveRecord::Base
  belongs_to :user
  
  validates :user_id, presence: true

  #after_create :register 

  def register
  	uri = URI.parse('http://api.devicepush.com/mobile')
			
		header = {"Content-Type": "application/x-www-form-urlencoded\r\ntoken: #{USER_ID}"}
		request = Net::HTTP::Post.new(uri.path, initheader = header)
		request.set_form_data(
			'idApplication' => PUSH_idApplication, 
	    'idDevice' => "57a26c789217c99e5f3b0869",
	    'icon' => 'default',
	    'title' => 'Title from Rails',
	    'content' => "apn Rails",
	    'sound' => 'default',
	    'vibrate' => true,
	    'badge' => 0
		)
		res = Net::HTTP.start(uri.hostname, uri.port) do |http|
		  http.request(request)
		end

		case res
			when Net::HTTPSuccess, Net::HTTPRedirection
			  puts "ok:#{res.body}"
			else
			  puts "fail:#{res.value}"
		end
  end
end
