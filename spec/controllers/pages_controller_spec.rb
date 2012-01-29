require 'spec_helper'

describe PagesController do

  describe "GET 'show'" do
    before do
      @page = Factory(:page, name: "test", body: "test content")
    end

    it "returns http success" do
      get 'show', name: "test"
      response.should be_success
    end

    it "should render 404 page" do
      get 'show', name: "non"
      response.should_not be_success
      response.code.should == "404"
    end
  end

end
