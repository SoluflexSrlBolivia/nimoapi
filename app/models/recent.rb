class Recent
  include ActiveModel::Serialization
  include ActiveModel::SerializerSupport

  attr_accessor :posts, :archives
  def initialize(posts, archives)
    @posts, @archives = posts, archives
  end
end