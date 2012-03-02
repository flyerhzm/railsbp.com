# RailsAdmin config file. Generated on January 01, 2012 23:06
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|

  # If your default_local is different from :en, uncomment the following 2 lines and set your default locale here:
  # require 'i18n'
  # I18n.default_locale = :de

  config.current_user_method { current_user } # auto-generated

  # Set the admin name here (optional second array element will appear in a beautiful RailsAdmin red ©)
  config.main_app_name = ['Railsbp Com', 'Admin']
  # or for a dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  config.authorize_with :cancan

  #  ==> Global show view settings
  # Display empty fields in show views
  # config.compact_show_view = false

  #  ==> Global list view settings
  # Number of default rows per-page:
  # config.default_items_per_page = 20

  #  ==> Included models
  # Add all excluded models here:
  # config.excluded_models = [Build, Category, Configuration, Page, Parameter, Repository, User, UserRepository]

  # Add models here if you want to go 'whitelist mode':
  config.included_models = [Build, Category, Configuration, Page, Parameter, Repository, User, UserRepository, Delayed::Job]

  # Application wide tried label methods for models' instances
  # config.label_methods << :description # Default is [:name, :title]

  #  ==> Global models configuration
  # config.models do
  #   # Configuration here will affect all included models in all scopes, handle with care!
  #
  #   list do
  #     # Configuration here will affect all included models in list sections (same for show, export, edit, update, create)
  #
  #     fields_of_type :date do
  #       # Configuration here will affect all date fields, in the list section, for all included models. See README for a comprehensive type list.
  #     end
  #   end
  # end
  #
  #  ==> Model specific configuration
  # Keep in mind that *all* configuration blocks are optional.
  # RailsAdmin will try his best to provide the best defaults for each section, for each field.
  # Try to override as few things as possible, in the most generic way. Try to avoid setting labels for models and attributes, use ActiveRecord I18n API instead.
  # Less code is better code!
  # config.model MyModel do
  #   # Cross-section field configuration
  #   object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #   label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #   label_plural 'My models'      # Same, plural
  #   weight -1                     # Navigation priority. Bigger is higher.
  #   parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #   navigation_label              # Sets dropdown entry's name in navigation. Only for parents!
  #   # Section specific configuration:
  #   list do
  #     filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #     items_per_page 100    # Override default_items_per_page
  #     sort_by :id           # Sort column (default is primary key)
  #     sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     # Here goes the fields configuration for the list view
  #   end
  # end

  # Your model's configuration, to help you get started:

  # All fields marked as 'hidden' won't be shown anywhere in the rails_admin unless you mark them as visible. (visible(true))

  # config.model Build do
  #   # Found associations:
  #     configure :repository, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :warning_count, :integer
  #     configure :repository_id, :integer         # Hidden
  #     configure :aasm_state, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :last_commit_id, :string
  #     configure :last_commit_message, :text
  #     configure :position, :integer
  #     configure :duration, :integer
  #     configure :finished_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Category do
  #   # Found associations:
  #     configure :configurations, :has_many_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :name, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Configuration do
  #   # Found associations:
  #     configure :parameters, :has_many_association
  #     configure :category, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :name, :string
  #     configure :description, :string
  #     configure :url, :string
  #     configure :category_id, :integer         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end

  config.model Page do
    configure :name, :string
    configure :body, :text
    list do
      field :id
      field :name
    end
    edit do
      field :name
      field :body, :text do
        ckeditor true
      end
    end
  end

  # config.model Parameter do
  #   # Found associations:
  #     configure :configuration, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :name, :string
  #     configure :kind, :string
  #     configure :value, :string
  #     configure :description, :string
  #     configure :configuration_id, :integer         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Repository do
  #   # Found associations:
  #     configure :user_repositories, :has_many_association
  #     configure :users, :has_many_association
  #     configure :builds, :has_many_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :git_url, :string
  #     configure :name, :string
  #     configure :description, :string
  #     configure :private, :boolean
  #     configure :fork, :boolean
  #     configure :pushed_at, :datetime
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :github_id, :integer
  #     configure :html_url, :string
  #     configure :ssh_url, :string
  #     configure :github_name, :string
  #     configure :builds_count, :integer
  #     configure :branch, :string
  #     configure :authentication_token, :string
  #     configure :visible, :boolean   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model User do
  #   # Found associations:
  #     configure :user_repositories, :has_many_association
  #     configure :repositories, :has_many_association
  #     configure :own_repositories, :has_many_association
  #     configure :invoices, :has_many_association
  #     configure :credit_card, :has_one_association
  #     configure :plan, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :email, :string
  #     configure :password, :password         # Hidden
  #     configure :password_confirmation, :password         # Hidden
  #     configure :reset_password_token, :string         # Hidden
  #     configure :reset_password_sent_at, :datetime
  #     configure :remember_created_at, :datetime
  #     configure :sign_in_count, :integer
  #     configure :current_sign_in_at, :datetime
  #     configure :last_sign_in_at, :datetime
  #     configure :current_sign_in_ip, :string
  #     configure :last_sign_in_ip, :string
  #     configure :created_at, :datetime
  #     configure :updated_at, :datetime
  #     configure :github_uid, :integer
  #     configure :nickname, :string
  #     configure :name, :string
  #     configure :github_token, :string
  #     configure :sync_repos, :boolean
  #     configure :stripe_customer_token, :string
  #     configure :plan_id, :integer         # Hidden
  #     configure :aasm_state, :string   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model UserRepository do
  #   # Found associations:
  #     configure :user, :belongs_to_association
  #     configure :repository, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer
  #     configure :repository_id, :integer         # Hidden
  #     configure :user_id, :integer         # Hidden
  #     configure :own, :boolean   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
end
