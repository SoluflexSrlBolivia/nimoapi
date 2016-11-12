class Api::V1::HomePostSerializer < Api::V1::BaseSerializer
  attributes :id, :post, :description, :archive, :group, :rate, :user, :comments, :votes, :created_at, :updated_at,
             :name, :size, :content_type, :uploader, :comments, :votes

  def archive
    Api::V1::ArchiveSerializer.new(object.archive, root: false) unless object.archive.nil?
  end
  def name
    object.digital_file_name unless object.digital_file_name.nil?
  end
  def size
    object.digital_file_size unless object.digital_file_size.nil?
  end
  def content_type
    object.digital_content_type unless object.digital_content_type.nil?
  end

  def rate
    object.rate
  end
  def votes
    object.rates.count
  end

  def group
    Api::V1::HomeGroupSerializer.new(object.owner, root: false) unless object.owner.nil?
    Api::V1::HomeGroupSerializer.new(object.group, root: false) unless object.group.nil?
  end

  def uploader
    Api::V1::HomeUserSerializer.new(object.uploader, root: false) unless object.uploader.nil?
  end

  def user
    Api::V1::HomeUserSerializer.new(object.user, root: false) unless object.user.nil?
  end

  def comments
    object.comments.count
  end

end