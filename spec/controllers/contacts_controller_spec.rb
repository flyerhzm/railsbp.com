require 'spec_helper'

describe ContactsController do
  context "#new" do
    it "should assign contact" do
      get :new

      response.should be_ok
      assigns(:contact).should be_kind_of(Contact)
    end

    it "should assign contact with current_user" do
      user = FactoryGirl.create(:user)
      sign_in user
      get :new

      response.should be_ok
      contact = assigns(:contact)
      contact.name.should == user.name
      contact.email.should == user.email
    end

    it "should assign contact with custom message" do
      get :new, message: "be aware<nl>report wrong analyze result"

      response.should be_ok
      contact = assigns(:contact)
      contact.message.should == "be aware\r\nreport wrong analyze result"
    end
  end
end
