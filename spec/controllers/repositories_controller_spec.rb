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

  context "GET :sync" do
    let(:hook_json) { File.read(Rails.root.join("spec/fixtures/github_hook.json")) }

    it "should generate build for master branch" do
      repository = Factory.stub(:repository, html_url: "http://github.com/defunkt/github")
      Repository.expects(:where).with(html_url: "http://github.com/defunkt/github").returns([repository])
      repository.expects(:generate_build).with('id' => '41a212ee83ca127e3c8cf465891ab7216a705f59', 'url' => 'http://github.com/defunkt/github/commit/41a212ee83ca127e3c8cf465891ab7216a705f59', 'author' => {'email' => 'chris@ozmm.org', 'name' => 'Chris Wanstrath'}, 'message' => 'okay i give in', 'timestamp' => '2008-02-15T14:57:17-08:00', 'added' => ['filepath.rb'])
      post :sync, payload: hook_json, format: 'json'
      response.should be_ok
      response.body.should == "success"
    end

    it "should not generate build for develop branch" do
      repository = Factory.stub(:repository, branch: "develop", html_url: "http://github.com/defunkt/github")
      Repository.expects(:where).with(html_url: "http://github.com/defunkt/github").returns([repository])
      post :sync, payload: hook_json, format: 'json'
      response.should be_ok
      response.body.should == "skip"
    end
  end
end
