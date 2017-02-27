module RepositoriesHelper
  def all_categories
    Category.includes(:configurations => :parameters).all
  end
end
