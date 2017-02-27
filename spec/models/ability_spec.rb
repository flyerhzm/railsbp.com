require 'rails_helper'

RSpec.describe Ability, type: :model do
  before { skip_repository_callbacks }

  context "new user" do
    before do
      User.current = create(:user)
      @visible_repository = create(:repository, visible: true)
      @private_repository = create(:repository, visible: false)
      @ability = Ability.new(nil)
    end

    it "should be able to read visible repository" do
      expect(@ability).to be_able_to(:read, @visible_repository)
    end

    it "should not be able to read private repository" do
      expect(@ability).not_to be_able_to(:read, @private_repository)
    end
  end

  context "user" do
    before do
      @user = create(:user)
      @user_repository = create(:repository, visible: false)
      @other_repository = create(:repository, visible: false)
      @user.repositories << @user_repository
      @own_repository = create(:repository, visible: false)
      @user.own_repositories << @own_repository
      @ability = Ability.new(@user)
    end

    it "should be able to read user's private repository" do
      expect(@ability).to be_able_to(:read, @user_repository)
    end

    it "should not be able to read other's private repository" do
      expect(@ability).not_to be_able_to(:read, @other_repository)
    end

    it "should be able to create a repository" do
      expect(@ability).to be_able_to(:create, Repository)
    end

    it "should be able to update an own repository" do
      expect(@ability).to be_able_to(:update, @own_repository)
    end

    it "should not be able to update a not own repository" do
      expect(@ability).not_to be_able_to(:update, @user_repoistory)
    end
  end
end
