require 'spec_helper'

describe AccountCell do
  context "cell rendering" do

    context "rendering tabs" do
      subject { render_cell(:account, :tabs, "plans") }

      it { should have_link("Account Overview") }
      it { should have_css("li.active a", :text => "Plan & Billing") }
    end

  end


  context "cell instance" do
    subject { cell(:account) }

    it { should respond_to(:tabs) }
  end
end
