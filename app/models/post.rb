class Post < ActiveRecord::Base
	belongs_to :group
	belongs_to :user
	has_many :comments, :as=> :commentable
	has_many :rates, :class_name => "RatePost", :foreign_key => :post_id
	has_one :archive, :as=> :archivable

	attr_accessor :rate

	include PgSearch
		pg_search_scope :search, :against => [:post, :description],
	  :using => {
	              :tsearch => {:prefix => true},
	              :trigram => {:only => [:post, :description]}
	            },
	  ignoring: :accents
    pg_search_scope :search, :associated_against=> {
    	:archive=>[:digital_file_name]
    }

  def rate
    sum_rate_total = self.rates.calculate(:sum, :rate)
    votes_total = self.rates.calculate(:count, :rate)

    return 0 if votes_total <= 0
    
    sum_rate_total / votes_total
  end
end
