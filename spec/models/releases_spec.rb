require 'rails_helper'

describe Release do
  it 'has a valid factory' do
    expect(build(:release)).to be_valid
  end

  it 'is invalid without a title' do
    expect(build(:release, title: nil)).to_not be_valid
  end
end
