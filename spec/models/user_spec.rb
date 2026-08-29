# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:account) }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_inclusion_of(:role).in_array(%w[owner admin staff]) }
  end

  describe "role helpers" do
    it "identifies owner role correctly" do
      user = build(:user, role: "owner")
      expect(user).to be_owner
      expect(user).to be_admin
    end
  end
end
