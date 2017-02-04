class FolderPolicy < ApplicationPolicy
  def index?
    return true
  end

  def show?
    return true
  end

  def create?
    return true
  end

  def update?
    return true if user.admin?
    return true if record.owner_type == "User" && record.owner_id == user.id
    if record.owner_type == "Group"
      member = UserGroup.find_by(:user_id=>user.id, :group_id=>record.owner.id)
      return true unless member.nil?
    end
  end

  def destroy?
    return true if user.admin?
    return true if record.owner_type == "Group" && record.owner_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
