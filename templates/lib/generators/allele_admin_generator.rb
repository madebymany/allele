class AlleleAdminGenerator < Rails::Generators::Base

# Include them gems
  
gem "active_admin", '~> 0.6.0'
gem "cancan"
  
# Create a standard CanCan ability for Active Admin
  
create_file 'app/models/ability.rb' do <<-'FILE'
class Ability
  include CanCan::Ability
  def initialize(user)
    user ||= User.new
    can :read, ActiveAdmin::Page, :name => 'Dashboard'
    if user.role?('admin')
      can :manage, :all
    end 
  end
end
FILE
end

generate("migration", "AddRoleToUsers role:string")
# append role methods

# Privileges are inherited between roles in the order specified in the ROLES 
# array. E.g. An admin can do the same as an moderator + more.
# If the role attribute is not set, the user does not have any privileges.
#ROLES = %w(moderator admin)
# 
#def role?(base_role)
#  return false unless role # A user has a role attribute. 
#  ROLES.index(base_role.to_s) <= ROLES.index(role)
#end

generate("active_admin:install --skip-users")
# delete comment/note migrations
# edit aa settings

rake("db:migrate")
  
end