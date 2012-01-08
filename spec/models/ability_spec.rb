require 'spec_helper'

describe Ability do
  before { Repository.any_instance.stubs(:sync_github) }

  context "new user" do
    before do
      plan = Factory(:plan, allow_privacy: true)
      User.current = Factory(:user).tap { |user| user.update_attribute(:plan, plan) }
      @visible_repository = Factory(:repository, visible: true)
      @private_repository = Factory(:repository, visible: false)
      @ability = Ability.new(nil)
    end

    it "should be able to read visible repository" do
      @ability.should be_able_to(:read, @visible_repository)
    end

    it "should not be able to read private repository" do
      @ability.should_not be_able_to(:read, @private_repository)
    end
  end

  context "user" do
    before do
      @user = Factory(:user)
      @user_repository = Factory(:repository, visible: false)
      @other_repository = Factory(:repository, visible: false)
      @user.repositories << @user_repository
      @own_repository = Factory(:repository, visible: false)
      @user.own_repositories << @own_repository
      @ability = Ability.new(@user)
    end

    it "should be able to read user's private repository" do
      @ability.should be_able_to(:read, @user_repository)
    end

    it "should not be able to read other's private repository" do
      @ability.should_not be_able_to(:read, @other_repository)
    end

    it "should be able to create a repository" do
      @ability.should be_able_to(:create, Repository)
    end

    it "should be able to update an own repository" do
      @ability.should be_able_to(:update, @own_repository)
    end

    it "should not be able to update a not own repository" do
      @ability.should_not be_able_to(:update, @user_repoistory)
    end
  end
end
