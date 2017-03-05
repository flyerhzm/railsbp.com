require 'rails_helper'

RSpec.describe UserRepository, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:repository) }

  let(:user) { create(:user) }
  let(:repository) { create(:repository) }

  before do
    User.current = user
  end

  context "increment_user_own_repositories_count" do
    it "should increase if own is true" do
      expect { user.user_repositories.create(repository: repository, own: true)
        user.reload }.to change(user, :own_repositories_count).by(1)
    end

    it "should not increase if own is false" do
      expect { user.user_repositories.create(repository: repository, own: false)
        user.reload }.not_to change(user, :own_repositories_count)
    end
  end

  context "decrement_user_own_repositories_count" do
    it "should decrease if own is true" do
      user_repository = user.user_repositories.create(repository: repository, own: true)
      user.reload
      expect { user_repository.destroy
        user.reload }.to change(user, :own_repositories_count).by(-1)
    end

    it "should not decrease if own is false" do
      user_repository = user.user_repositories.create(repository: repository, own: false)
      user.reload
      expect { user_repository.destroy
        user.reload }.not_to change(user, :own_repositories_count)
    end
  end
end
