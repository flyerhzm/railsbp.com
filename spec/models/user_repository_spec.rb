require 'spec_helper'

describe UserRepository do
  it { should belong_to(:user) }
  it { should belong_to(:repository) }

  let(:user) { Factory(:user) }
  let(:repository) { Factory(:repository) }

  before do
    Repository.any_instance.stubs(:sync_github)
    User.current = user
  end

  context "increment_user_own_repositories_count" do
    it "should increase if own is true" do
      lambda {
        user.user_repositories.create(repository: repository, own: true)
        user.reload
      }.should change(user, :own_repositories_count).by(1)
    end

    it "should not increase if own is false" do
      lambda {
        user.user_repositories.create(repository: repository, own: false)
        user.reload
      }.should_not change(user, :own_repositories_count)
    end
  end

  context "decrement_user_own_repositories_count" do
    it "should decrease if own is true" do
      user_repository = user.user_repositories.create(repository: repository, own: true)
      user.reload
      lambda {
        user_repository.destroy
        user.reload
      }.should change(user, :own_repositories_count).by(-1)
    end

    it "should not decrease if own is false" do
      user_repository = user.user_repositories.create(repository: repository, own: false)
      user.reload
      lambda {
        user_repository.destroy
        user.reload
      }.should_not change(user, :own_repositories_count)
    end
  end
end
