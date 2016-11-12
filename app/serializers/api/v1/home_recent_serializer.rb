class Api::V1::HomePostSerializer < Api::V1::BaseSerializer
  has_many :posts, embed: :objects
  has_many :arvhives, embed: :objects

end