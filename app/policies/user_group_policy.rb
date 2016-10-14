class UserGroupPolicy < ApplicationPolicy

  def search?
    return true
  end

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
    return true
  end

  def destroy?
    return true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
