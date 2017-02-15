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
      return true if record.owner.admin_id == user.id
    end
  end

  def destroy?
    return true if user.admin?
    return true if record.owner_type == "User" && record.owner_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
