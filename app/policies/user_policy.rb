class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user && user.admin?
  end

  def show?
    user && (user.admin? || user.id == record.id)
  end

  def new?
    user && user.zeus?
  end

  def edit?
    user && user.admin?
  end

  def create?
    user && user.zeus?
  end

  def update?
    user && (user.zeus? || (user.staff? && !record.zeus?))
  end

  def destroy?
    user && user.zeus?
  end

  def permitted_attributes
    if user && user.zeus?
      [:username, :ugent_id, :first_name, :last_name, :email, :permission]
    elsif user && user.staff?
      [:permission]
    else
      []
    end
  end
end
