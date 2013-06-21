class AlleleAdminGenerator < Rails::Generators::Base

  def allele_admin

    gem("jquery-rails", "2.3.0")
    gem("activeadmin", '~> 0.6.0')
    gem("cancan")

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

    inject_into_class "app/models/user.rb", User do
      "\n# Privileges are inherited between roles in the order specified in the ROLES
      # array. E.g. An admin can do the same as an moderator + more.
      # If the role attribute is not set, the user does not have any privileges.
      ROLES = %w(moderator admin)
      def role?(base_role)
        return false unless role # A user has a role attribute.
        ROLES.index(base_role.to_s) <= ROLES.index(role)
      end\n\n"
    end

    generate("active_admin:install --skip-users")

    inject_into_file "config/initializers/active_admin.rb", :after => "ActiveAdmin.setup do |config|\n" do
      "config.authorization_adapter = ActiveAdmin::CanCanAdapter"
    end

    gsub_file 'config/initializers/active_admin.rb', '# config.logout_link_method = :delete', 'config.logout_link_method = :delete'
    gsub_file 'config/initializers/active_admin.rb', 'destroy_admin_user_session_path', 'destroy_user_session_path'
    gsub_file 'config/initializers/active_admin.rb', 'current_admin_user', 'current_user'
    gsub_file 'config/initializers/active_admin.rb', 'authenticate_admin_user!', 'authenticate_user!'

    rake("db:migrate")
  
  end

end