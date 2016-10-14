class AliasPolicy < ApplicationPolicy
  def index?
    return true if user.admin?
    return true if record.user.id == user.id
  end

  def show?
    return true if user.admin?
    return true if record.user.id == user.id
  end

  def create?
    return true
  end

  def update?
    return true if user.admin?
    return true if record.user.id == user.id
  end

  def destroy?
    return true if user.admin?
    return true if record.user.id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
