class Service::Notification < ActiveRecord::Base
  def self.notify identifier
    params = {
  			'idApplication' => PUSH_idApplication, 
		    'idDevice' => identifier,
		    'icon' => 'name file',
		    'title' => 'Title from PHP',
		    'content' => 'Text from PHP',
		    'sound' => 'default',
		    'vibrate' => trur,
		    'badge' => 1
      }

		uri = URI.parse('http://api.devicepush.com/send')
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true

		request = Net::HTTP::Post.new(uri.path,
		                              'Content-Type'  => 'application/json',
		                              'header'				=> 'token: USER_ID',
		                              'Authorization' => "Basic NGEwMGZmMjItY2NkNy0xMWUzLTk5ZDUtMDAwYzI5NDBlNjJj")
		request.body = params.as_json.to_json
		response = http.request(request) 
		puts response.body
    
  end
  
end
