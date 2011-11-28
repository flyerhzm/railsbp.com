class Repository < ActiveRecord::Base
  has_many :builds

  validates :github_id, :presence => true, :uniqueness => true

  def generate_build
    builds.create
  end
end
