require 'spec_helper'

describe PlansController do

  describe "GET 'index'" do
    it "returns http success" do
      user = FactoryGirl.create(:user)
      sign_in user
      get 'index'
      response.should be_success
    end
  end

end
