require 'rails_helper'

RSpec.describe PlansController, type: :controller do

  describe "GET 'index'" do
    it "returns http success" do
      user = create(:user)
      sign_in user
      get 'index'
      expect(response).to be_success
    end
  end

end
