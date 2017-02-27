require 'rails_helper'

RSpec.describe ContactsController, type: :controller do
  context "#new" do
    it "should assign contact" do
      get :new

      expect(response).to be_ok
      expect(assigns(:contact)).to be_kind_of(Contact)
    end

    it "should assign contact with current_user" do
      user = create(:user)
      sign_in user
      get :new

      expect(response).to be_ok
      contact = assigns(:contact)
      expect(contact.name).to eq user.name
      expect(contact.email).to eq user.email
    end

    it "should assign contact with custom message" do
      get :new, message: "be aware<nl>report wrong analyze result"

      expect(response).to be_ok
      contact = assigns(:contact)
      expect(contact.message).to eq "be aware\r\nreport wrong analyze result"
    end
  end
end
