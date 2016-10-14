class Group < ActiveRecord::Base
    has_many :posts
    has_many :user_groups
    has_many :users, through: :user_groups
    has_one  :folder, :as=> :folderable, dependent: :destroy
    has_one :archive, :as=> :archivable, dependent: :destroy

    validates :name, presence: true
    after_create :create_folders

    attr_accessor :admin, :rate

    include PgSearch
    pg_search_scope :search, :against => [:name, :description],
    :using => {
              :tsearch => {:prefix => true},
              :trigram => {:only => [:name, :description]}
            },
    ignoring: :accents

  #change status deleted to true
  def delete_group
    begin
      if self.posts.count == 0 && self.user_groups.count == 1
        return  self.destroy
      end

      self.deleted = true
      self.save!
    rescue => e
      puts "error:delete_group:#{e}"
      return false
    end

    true
  end

  #Create the root folder
  def create_folders
    root_folder = Folder.new(:name=>".", :owner_type=>"Group", :owner_id=>self.id)
    self.folder = root_folder
    
    self.save!
  end

  def admin
    User.find self.admin_id
  end

  def rate
    sum_rate_total = self.user_groups.calculate(:sum, :rate)
    votes_total = self.user_groups.calculate(:count, :rate)

    return 0 if votes_total <= 0
    
    sum_rate_total / votes_total
  end
end
