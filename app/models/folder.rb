class Folder < ActiveRecord::Base
	has_many :folders, :as=> :folderable, :dependent => :destroy
	has_many :archives, :as=> :archivable, dependent: :destroy
  has_many :downloads, dependent: :destroy
  
	belongs_to :folderable, polymorphic: true

	attr_accessor :owner

	validates :name, presence: true
	validates :owner_id, presence: true
	validates :owner_type, presence: true

  after_destroy :remove_dependencies

  include PgSearch
  pg_search_scope :search, :against => [:name, :description],
  :using => {
              :tsearch => {:prefix => true},
              :trigram => {:only => [:name, :description]}
            },
  ignoring: :accents

  def owner
  	self.owner_type.singularize.classify.constantize.find self.owner_id
  end

  private
    def remove_dependencies
      self.downloads.destroy_all
      self.archives.where("owner_type='User'").destroy_all
    end
end
