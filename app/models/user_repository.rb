class UserRepository < ActiveRecord::Base
  belongs_to :user
  belongs_to :repository

  after_create :increment_user_own_repositories_count
  after_destroy :decrement_user_own_repositories_count

  protected
    def increment_user_own_repositories_count
      user.increment!(:own_repositories_count) if own?
    end

    def decrement_user_own_repositories_count
      user.decrement!(:own_repositories_count) if own?
    end
end
