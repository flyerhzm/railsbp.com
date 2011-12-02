require 'spec_helper'

describe RepositoriesController do
  context "GET :index" do
    it "should get unauthorized if user sync_repos is false" do
      user = Factory(:user)
      sign_in user
      get :index, :format => 'json'
      response.should be_ok
      ActiveSupport::JSON.decode(response.body).should == {"error" => "not_ready"}
    end

    it "should get repositories if user sync_repos is true" do
      user = Factory(:user, :sync_repos => true)
      repo1 = Factory(:repository)
      repo2 = Factory(:repository)
      user.repositories << repo1
      user.repositories << repo2
      sign_in user
      get :index, :format => 'json'
      response.should be_ok
      repos = ActiveSupport::JSON.decode(response.body)
      repos[0]["name"].should == repo1.name
      repos[1]["name"].should == repo2.name
    end
  end

  context "GET :show" do
    it "should assign repository" do
      repository = Factory(:repository)
      get :show, :id => repository.id
      response.should be_ok
      assigns(:repository).should == repository
    end
  end

  context "GET :sync" do
    let(:hook_json) { ActiveSupport::JSON.decode(File.read(Rails.root.join("spec/fixtures/github_hook.json"))) }

    it "should generate build for repository" do
      repository = Factory.stub(:repository)
      Repository.expects(:where).with(:url => "http://github.com/defunkt/github").returns([repository])
      repository.expects(:generate_build).with(:last_commit_id => "41a212ee83ca127e3c8cf465891ab7216a705f59")
      post :sync, :payload => hook_json, :format => 'json'
      response.should be_ok
    end
  end
end
