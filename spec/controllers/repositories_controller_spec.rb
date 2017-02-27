require 'rails_helper'

RSpec.describe RepositoriesController, type: :controller do
  before { skip_repository_callbacks }

  context "GET :show" do
    it "should assign repository" do
      user = create(:user)
      repository = create(:repository)
      user.repositories << repository
      create(:build, :repository => repository)
      sign_in user
      get :show, id: repository.id
      expect(response).to be_ok
      expect(assigns(:repository)).not_to be_nil
    end
  end

  context "GET :new" do
    it "should assign repository" do
      user = create(:user, nickname: "flyerhzm")
      sign_in user
      get :new
      expect(response).to be_ok
      expect(assigns(:repository)).not_to be_nil
    end

    it "should redirect to user/edit page if current_user didn't input email" do
      user = create(:user, nickname: "flyerhzm", email: "flyerhzm@fakemail.com")
      sign_in user
      get :new
      expect(response).to redirect_to(edit_user_registration_path)
    end
  end

  context "POST :create" do
    before do
      user = create(:user, nickname: "flyerhzm")
      sign_in user
    end

    it "should redirect to show if success" do
      post :create, repository: {github_name: "flyerhzm/railsbp.com"}
      repository = assigns(:repository)
      expect(response).to redirect_to(edit_repository_path(repository))
    end

    it "should render new action if failed" do
      allow_any_instance_of(User).to receive(:org_repository?).and_return(false)
      post :create, repository: {github_name: ""}
      expect(response).to redirect_to(new_repository_path)
    end

    it "should redirect to user/edit page if current_user didn't input email" do
      user = create(:user, nickname: "flyerhzm", email: "flyerhzm@fakemail.com")
      sign_in user
      post :create, repository: {github_name: "flyerhzm/railsbp.com"}
      expect(response).to redirect_to(edit_user_registration_path)
    end
  end

  context "POST :sync" do
    let(:hook_json) { File.read(Rails.root.join("spec/fixtures/github_hook.json")) }
    let(:last_message) {
      {
        "id" => "473d12b3ca40a38f12620e31725922a9d88b5386",
        "url" => "https://github.com/railsbp/rails-bestpractices.com/commit/473d12b3ca40a38f12620e31725922a9d88b5386",
        "author" => {
          "email" => "flyerhzm@gmail.com",
          "name" => "Richard Huang"
        },
        "message" => "copy config yaml files for travis",
        "timestamp" => "2011-12-25T20:36:34+08:00"
      }
    }

    it "should generate build" do
      repository = build(:repository, html_url: "https://github.com/railsbp/rails-bestpractices.com", authentication_token: "123456789")
      expect(Repository).to receive(:where).with(html_url: "https://github.com/railsbp/rails-bestpractices.com").and_return([repository])
      expect(repository).to receive(:generate_build).with("develop", last_message)
      post :sync, token: "123456789", payload: hook_json, format: 'json'
      expect(response).to be_ok
      expect(response.body).to eq "success"
    end

    it "should not generate build if authentication_token does not match" do
      repository = build(:repository, html_url: "https://github.com/railsbp/rails-bestpractices.com", authentication_token: "987654321")
      expect(Repository).to receive(:where).with(html_url: "https://github.com/railsbp/rails-bestpractices.com").and_return([repository])
      post :sync, token: "123456789", payload: hook_json, format: 'json'
      expect(response).to be_ok
      expect(response.body).to eq "not authenticate"
    end

    it "should not generate build if authentication_token does not exist" do
      post :sync, payload: hook_json, format: 'json'
      expect(response).to be_ok
      expect(response.body).to eq "not authenticate"
    end

    it "should not generate build and notify privacy if repository is private" do
      repository = build(:repository, private: true, html_url: "https://github.com/railsbp/rails-bestpractices.com", authentication_token: "123456789")
      expect(Repository).to receive(:where).with(html_url: "https://github.com/railsbp/rails-bestpractices.com").and_return([repository])
      expect(repository).to receive(:notify_privacy)
      post :sync, token: "123456789", payload: hook_json, format: 'json'
      expect(response).to be_ok
      expect(response.body).to eq "no private repository"
    end

    it "should not generate build if repository is not rails" do
      repository = build(:repository, rails: false, html_url: "https://github.com/railsbp/rails-bestpractices.com", authentication_token: "123456789")
      expect(Repository).to receive(:where).with(html_url: "https://github.com/railsbp/rails-bestpractices.com").and_return([repository])
      post :sync, token: "123456789", payload: hook_json, format: 'json'
      expect(response).to be_ok
      expect(response.body).to eq "not rails repository"
    end
  end
end
