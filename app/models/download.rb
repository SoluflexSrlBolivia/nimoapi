class Download < ActiveRecord::Base
  belongs_to :folder
  belongs_to :archive

  include PgSearch
    pg_search_scope :search, :associated_against=> {
    	:archive=>[:digital_file_name]
    }

end
