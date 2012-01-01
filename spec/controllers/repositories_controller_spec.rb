require 'spec_helper'

describe RepositoriesController do
  context "GET :index" do
    it "should get unauthorized if user sync_repos is false" do
      user = Factory(:user)
      sign_in user
      get :index, format: 'json'
      response.should be_ok
      ActiveSupport::JSON.decode(response.body).should == {"error" => "not_ready"}
    end

    it "should get repositories if user sync_repos is true" do
      user = Factory(:user, sync_repos: true)
      User.current = user
      repo1 = Factory(:repository)
      repo2 = Factory(:repository)
      user.repositories << repo1
      user.repositories << repo2
      sign_in user
      get :index, format: 'json'
      response.should be_ok
      repos = ActiveSupport::JSON.decode(response.body)
      repos[0]["name"].should == repo1.name
      repos[1]["name"].should == repo2.name
    end
  end

  context "GET :show" do
    it "should assign repository" do
      user = Factory(:user)
      sign_in user
      repository = Factory(:repository)
      build = Factory(:build, :repository => repository)
      get :show, id: repository.id
      response.should be_ok
      assigns(:repository).should_not be_nil
    end
  end

  context "GET :new" do
    it "should assign repository" do
      user = Factory(:user)
      sign_in user
      get :new
      response.should be_ok
      assigns(:repository).should_not be_nil
    end
  end

  context "POST :create" do
    before do
      user = Factory(:user)
      sign_in user
    end

    it "should redirect to show if success" do
      post :create, repository: {github_name: "flyerhzm/railsbp.com"}
      repository = assigns(:repository)
      response.should redirect_to(repository_path(repository))
    end

    it "should render new action if failed" do
      post :create, repository: {github_name: ""}
      response.should render_template(action: "new")
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

    it "should generate build for master branch" do
      repository = Factory.stub(:repository, html_url: "https://github.com/railsbp/rails-bestpractices.com", authentication_token: "123456789")
      Repository.expects(:where).with(html_url: "https://github.com/railsbp/rails-bestpractices.com").returns([repository])
      repository.expects(:generate_build).with(last_message)
      post :sync, token: "123456789", payload: hook_json, format: 'json'
      response.should be_ok
      response.body.should == "success"
    end

    it "should not generate build for develop branch" do
      repository = Factory.stub(:repository, html_url: "https://github.com/railsbp/rails-bestpractices.com", authentication_token: "123456789", branch: "develop")
      Repository.expects(:where).with(html_url: "https://github.com/railsbp/rails-bestpractices.com").returns([repository])
      post :sync, token: "123456789", payload: hook_json, format: 'json'
      response.should be_ok
      response.body.should == "skip"
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
  end

  context "POST :sync_proxy" do
    let(:proxy_success_json) { File.read(Rails.root.join("spec/fixtures/proxy_success.json")) }
    let(:last_commit) {
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

    it "should generate build for master branch" do
      repository = Factory.stub(:repository, html_url: "https://github.com/railsbp/rails-bestpractices.com", authentication_token: "123456789")
      Repository.expects(:where).with(html_url: "https://github.com/railsbp/rails-bestpractices.com").returns([repository])
      errors = ActiveSupport::JSON.decode(proxy_success_json)["errors"]
      repository.expects(:generate_proxy_build).with(last_commit, errors)
      post :sync_proxy, token: "123456789", repository_url: "https://github.com/railsbp/rails-bestpractices.com", last_commit: last_commit, ref: "refs/heads/master", result: proxy_success_json
      response.should be_ok
      response.body.should == "success"
    end

    it "should not generate build for develop branch" do
      repository = Factory.stub(:repository, html_url: "https://github.com/railsbp/rails-bestpractices.com", authentication_token: "123456789")
      Repository.expects(:where).with(html_url: "https://github.com/railsbp/rails-bestpractices.com").returns([repository])
      post :sync_proxy, token: "123456789", repository_url: "https://github.com/railsbp/rails-bestpractices.com", last_commit: last_commit, ref: "refs/heads/develop", result: proxy_success_json
      response.should be_ok
      response.body.should == "skip"
    end

    it "should not generate build if authentication_token does not exist" do
      post :sync_proxy, repository_url: "https://github.com/railsbp/rails-bestpractices.com", last_commit: last_commit, ref: "refs/heads/develop", result: proxy_success_json
      response.should be_ok
      response.body.should == "not authenticate"
    end

    it "should not generate build if authentication_token does not match" do
      repository = Factory.stub(:repository, html_url: "https://github.com/railsbp/rails-bestpractices.com", authentication_token: "123456789")
      Repository.expects(:where).with(html_url: "https://github.com/railsbp/rails-bestpractices.com").returns([repository])
      post :sync_proxy, token: "987654321", repository_url: "https://github.com/railsbp/rails-bestpractices.com", last_commit: last_commit, ref: "refs/heads/develop", result: proxy_success_json
      response.should be_ok
      response.body.should == "not authenticate"
    end

    it "should retrive an error" do
      error = Exception.new("test")
      repository = Factory.stub(:repository, html_url: "https://github.com/railsbp/rails-bestpractices.com", authentication_token: "123456789")
      Repository.expects(:where).with(html_url: "https://github.com/railsbp/rails-bestpractices.com").returns([repository])
      lambda {
        post :sync_proxy, token: "123456789", repository_url: "https://github.com/railsbp/rails-bestpractices.com", last_commit: last_commit, ref: "refs/heads/master", error: Marshal.dump(error)
      }.should raise_error
    end
  end
end
