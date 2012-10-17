require 'spec_helper'

describe RepositoriesController do
  before { skip_repository_callbacks }

  context "GET :show" do
    it "should assign repository" do
      user = Factory(:user)
      repository = Factory(:repository)
      user.repositories << repository
      build = Factory(:build, :repository => repository)
      sign_in user
      get :show, id: repository.id
      response.should be_ok
      assigns(:repository).should_not be_nil
    end
  end

  context "GET :new" do
    it "should assign repository" do
      user = Factory(:user, nickname: "flyerhzm")
      sign_in user
      get :new
      response.should be_ok
      assigns(:repository).should_not be_nil
    end

    it "should redirect to user/edit page if current_user didn't input email" do
      user = Factory(:user, nickname: "flyerhzm", email: "flyerhzm@fakemail.com")
      sign_in user
      get :new
      response.should redirect_to(edit_user_registration_path)
    end
  end

  context "POST :create" do
    before do
      user = Factory(:user, nickname: "flyerhzm")
      sign_in user
    end

    it "should redirect to show if success" do
      post :create, repository: {github_name: "flyerhzm/railsbp.com"}
      repository = assigns(:repository)
      response.should redirect_to(edit_repository_path(repository))
    end

    it "should render new action if failed" do
      User.any_instance.stubs(:org_repository?).returns(false)
      post :create, repository: {github_name: ""}
      response.should render_template(action: "new")
    end

    it "should redirect to user/edit page if current_user didn't input email" do
      user = Factory(:user, nickname: "flyerhzm", email: "flyerhzm@fakemail.com")
      sign_in user
      post :create, repository: {github_name: "flyerhzm/railsbp.com"}
      response.should redirect_to(edit_user_registration_path)
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
      repository = Factory.stub(:repository, html_url: "https://github.com/railsbp/rails-bestpractices.com", authentication_token: "123456789")
      Repository.expects(:where).with(html_url: "https://github.com/railsbp/rails-bestpractices.com").returns([repository])
      repository.expects(:generate_build).with("develop", last_message)
      post :sync, token: "123456789", payload: hook_json, format: 'json'
      response.should be_ok
      response.body.should == "success"
    end

    it "should not generate build if authentication_token does not match" do
      repository = Factory.stub(:repository, html_url: "https://github.com/railsbp/rails-bestpractices.com", authentication_token: "987654321")
      Repository.expects(:where).with(html_url: "https://github.com/railsbp/rails-bestpractices.com").returns([repository])
      post :sync, token: "123456789", payload: hook_json, format: 'json'
      response.should be_ok
      response.body.should == "not authenticate"
    end

    it "should not generate build if authentication_token does not exist" do
      post :sync, payload: hook_json, format: 'json'
      response.should be_ok
      response.body.should == "not authenticate"
    end

    it "should not generate build and notify privacy if repository is private" do
      repository = Factory.stub(:repository, private: true, html_url: "https://github.com/railsbp/rails-bestpractices.com", authentication_token: "123456789")
      Repository.expects(:where).with(html_url: "https://github.com/railsbp/rails-bestpractices.com").returns([repository])
      repository.expects(:notify_privacy)
      post :sync, token: "123456789", payload: hook_json, format: 'json'
      response.should be_ok
      response.body.should == "no private repository"
    end

    it "should not generate build if repository is not rails" do
      repository = Factory.stub(:repository, rails: false, html_url: "https://github.com/railsbp/rails-bestpractices.com", authentication_token: "123456789")
      Repository.expects(:where).with(html_url: "https://github.com/railsbp/rails-bestpractices.com").returns([repository])
      post :sync, token: "123456789", payload: hook_json, format: 'json'
      response.should be_ok
      response.body.should == "not rails repository"
    end
  end
end
