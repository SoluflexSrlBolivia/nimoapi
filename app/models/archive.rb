class Archive < ActiveRecord::Base
	belongs_to :archivable, polymorphic: true
	
	has_many :comments, :as=> :commentable
  has_many :downloads
  has_many :rates, :class_name => "RateArchive", :foreign_key => :archive_id

  has_attached_file :digital,
                    styles: { :full=>{ :geometry => "1024x1024>", :format => 'jpg', :time => 10 }, :medium=>{ :geometry => "800x800>", :format => 'jpg', :time => 10 }, :thumb=> { :geometry => "400x400>", :format => 'jpg', :time => 10 } },
                    :use_timestamp => true,
                    default_style: :medium#,
                    #convert_options: { all: '-strip -auto-orient -colorspace sRGB' }

  attr_accessor :owner, :uploader, :rate

  validates :digital, attachment_presence: true
  validates :owner_id, presence: true
  validates :owner_type, presence: true
  validates :uploader_id, presence: true

  validates_attachment :digital
  do_not_validate_attachment_file_type :digital

  after_destroy :remove_dependencies

	include PgSearch
    pg_search_scope :search, :against => [:digital_file_name, :description, :digital_content_type],
    :using => {
              :tsearch => {:prefix => true},
              :trigram => {:only => [:digital_file_name, :description]}
            },
    ignoring: :accents

  #before_create :randomize_file_name

  def randomize_file_name
    self.original_file_name = self.digital_file_name
    extension = File.extname(self.digital_file_name).downcase
    self.digital.instance_write(:file_name, "#{SecureRandom.hex(16)}#{extension}")
  end

  def owner
    self.owner_type.singularize.classify.constantize.find self.owner_id
  end

  def uploader
    User.find self.uploader_id
  end
  def rate
    sum_rate_total = self.rates.calculate(:sum, :rate)
    votes_total = self.rates.calculate(:count, :rate)

    return 0 if votes_total <= 0
    
    sum_rate_total / votes_total
  end
  private 
    def remove_dependencies
      self.digital = nil
      self.save

      self.downloads.destroy_all
      self.rates.destroy_all
      self.comments.destroy_all
    end
    
end
