class Api::V1::GroupSerializer < Api::V1::BaseSerializer
  #just some basic attributes
  attributes :id, :name, :description, :keyword, :privacity, :archive_id, :admin, :notification, :rate, :member, :my_rate, :alias
  
  has_one :folder

  #delegate :current_user, :to => :scope
  
  def archive_id
  	object.archive.try(:id) || nil
  end

  def admin
  	Api::V1::UserArchiveSerializer.new(object.admin, root: false)
  end

  def my_rate
    current_user = scope[:current_user]
    if current_user.present?
      user_group = UserGroup.find_by(:user_id=>current_user.id, :group_id=>object.id)
      return 0 if user_group.nil?

      return user_group.rate
    end
    0
  end

  def rate
  	object.rate
  end

  def notification
    current_user = scope[:current_user]
    if current_user.present?
      user_group = UserGroup.find_by(:user_id=>current_user.id, :group_id=>object.id)
      return nil if user_group.nil?

      return user_group.notification
    end
  end

  def member
    current_user = scope[:current_user]
    if current_user.present?
      ug = object.user_groups.find_by_user_id current_user.id
      return 1 unless ug.nil?
      return 0
    end
  end

  def alias
    current_user = scope[:current_user]
    if current_user.present?
      user_group = UserGroup.find_by(:user_id=>current_user.id, :group_id=>object.id)
      return nil if user_group.nil?

      return user_group.alias
    end
  end
end
