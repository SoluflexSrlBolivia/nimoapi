namespace :demo do
  desc "demo data"
  task generate: :environment do
    100.times.each do |index|
      first_name = Faker::Name.first_name

      user = nil
      if index == 0 
        user = User.new({:name=>"Demo User", :email=>"demo@gmail.com",:password=>"Demo0001", :password_confirmation=>"Demo0001"})
      else
        user = User.new({:name=>first_name, :email=>Faker::Internet.free_email(first_name),:password=>"Demo0001", :password_confirmation=>"Demo0001"})
      end

      if !user.nil? && user.valid?
        user.save!
        user.activate
        
        Faker::Number.between(1, 10).times.each do |indexGroup|
          privacity = Faker::Number.between(1, 3)
          group = Group.new({:name=>Faker::Company.name, :description=>Faker::Company.catch_phrase, :privacity=>privacity})
          if privacity == 3
            group.keyword = Faker::Internet.password(5)
          end
          group.admin_id = user.id
          group.users << user
          group.save!
          userGroup = UserGroup.where(:user_id=>user.id, :group_id=>group.id).first
          userGroup.rate = Faker::Number.between(1, 5)
          userGroup.save!
        end
        
        notification = Notification.new({:message=>Faker::Lorem.sentence(5), :notification_type=>1, :action=>""})
        user.notifications << notification
        user.save!
        #puts "user:#{user.inspect}"
      else
        #puts "errors:#{user.errors.messages}" 
      end
    end
  end

end
