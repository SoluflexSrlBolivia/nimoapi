class Archive < ActiveRecord::Base
	belongs_to :archivable, polymorphic: true
	
	has_many :comments, :as=> :commentable
  has_many :downloads
  has_many :rates, :class_name => "RateArchive", :foreign_key => :archive_id

  #http://stackoverflow.com/questions/20920212/generate-thumbnail-from-pdf-in-rails-paperclip
  has_attached_file :digital,
                    styles: lambda { |a| a.instance.check_file_type },
                    processors: lambda {
                        |a| a.is_video? ? [ :transcoder ] : [ :thumbnail ]
                    },
                    :default => :default_images

=begin
                    styles: {
                        :full=>{ :geometry => "1024x1024>", :format => 'jpg', :time => 10 },
                        :medium=>{ :geometry => "800x800>", :format => 'jpg', :time => 10 },
                        :thumb=> { :geometry => "400x400>", :format => 'jpg', :time => 10 }
                    },
                    :use_timestamp => false
                    #default_style: :medium,
                    #convert_options: { all: '-strip -auto-orient -colorspace sRGB' }
=end

  before_post_process :apply_post_processing?

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

  before_create :randomize_file_name

  def default_images
    if has_default_image?
      ":rails_root/public/default/:extension.png"
    else
      ":rails_root/public/default/default.png"
    end
  end
  def is_image?
    self.digital.content_type =~ %r(image)
  end

  def is_video?
    self.digital.content_type =~ %r(video)
  end

  def is_audio?
    self.digital.content_type =~ /\Aaudio\/.*\Z/
  end

  def is_plain_text?
    self.digital_file_name =~ %r{\.(txt)$}i
  end

  def is_excel?
    self.digital_file_name =~ %r{\.(xls|xlt|xla|xlsx|xlsm|xltx|xltm|xlsb|xlam|csv|tsv)$}i
  end

  def is_word_document?
    self.digital_file_name =~ %r{\.(docx|doc|dotx|docm|dotm)$}i
  end

  def is_powerpoint?
    self.digital_file_name =~ %r{\.(pptx|ppt|potx|pot|ppsx|pps|pptm|potm|ppsm|ppam)$}i
  end

  def is_pdf?
    self.digital_file_name =~ %r{\.(pdf)$}i
  end

  def has_default_image?
    is_audio?
    is_plain_text?
    is_excel?
    is_word_document?
  end

  # If the uploaded content type is an audio file,
  # return false so that we'll skip audio post processing
  def apply_post_processing?
    if self.has_default_image?
      return false
    else
      return true
    end
  end

  # Method to be called in order to determine what styles we should
  # save of a file.
  def check_file_type
    if self.is_image?
      {
          :thumb => "400x400>",
          :medium => "800x800>",
          :full => "1024x1024>"
      }
    elsif self.is_pdf?
      {
          :thumb => ["200x200>", :png],
          :medium => ["500x500>", :png]
      }

    elsif self.is_video?
      {
          :thumb => {
              :geometry => "200x200>",
              :format => 'jpg',
              :time => 0
          },
          :medium => {
              :geometry => "500x500>",
              :format => 'jpg',
              :time => 0
          }
      }
    elsif self.is_audio?
      {
          :audio => {
              :format => "mp3"
          }
      }
    else
      {}
    end
  end

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
    def resize_archives
      return false unless (image? || video?)
    end

    
end
