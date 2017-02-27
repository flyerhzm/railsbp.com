require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:user_repositories) }
  it { is_expected.to have_many(:repositories).through(:user_repositories) }

  context "#add_repository" do
    before do
      skip_repository_callbacks
      @user = create(:user, nickname: "flyerhzm", github_uid: 66836)
      @repository = create(:repository, github_name: "flyerhzm/old")
      @user.repositories << @repository
    end

    it "should create a new repository within his own account" do
      expect { @user.add_repository("flyerhzm/new") }.to change(@user.repositories, :count).by(1)
    end

    it "should create a new repository when he is a collaborator" do
      stub_request(:get, "https://api.github.com/repos/railsbp/railsbp.com/collaborators").
        to_return(headers: { "Content-Type": "application/json" }, body: File.new(Rails.root.join("spec/fixtures/collaborators.json")))
      expect { @user.add_repository("railsbp/railsbp.com") }.to change(@user.repositories, :count).by(1)
    end

    it "should not create a new repository when he don't have privilege" do
      stub_request(:get, "https://api.github.com/repos/test/test.com/collaborators").
        to_return(body: MultiJson.decode("[]"))
      expect { @user.add_repository("test/test.com") }.to raise_exception(AuthorizationException)
    end

    it "should attach to an old repository" do
      expect { @user.add_repository("flyerhzm/old") }.not_to change(@user.repositories, :count)
    end
  end

  context "#fakemail?" do
    context "flyerhzm" do
      subject { create(:user, email: "flyerhzm@gmail.com") }
      describe '#fakemail?' do
        subject { super().fakemail? }
        it { is_expected.to be_falsey }
      end
    end
    context "flyerhzm-test" do
      subject { create(:user, email: "flyerhzm-test@fakemail.com") }
      describe '#fakemail?' do
        subject { super().fakemail? }
        it { is_expected.to be_truthy }
      end
    end
  end
end
