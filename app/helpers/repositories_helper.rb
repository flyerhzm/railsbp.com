module RepositoriesHelper
  def all_categories
    Category.includes(:configurations => :parameters).all
  end

  def public_repositories
    Repository.visible.where("builds_count > 0").order("last_build_at desc").limit(10)
  end
end
