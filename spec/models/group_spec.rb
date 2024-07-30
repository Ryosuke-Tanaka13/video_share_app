require 'rails_helper'

RSpec.describe Group, type: :model do
  let(:organization) { Organization.create(name: 'organization_name') }
  let(:group) { described_class.new(name: 'group_name', organization: organization) }

  describe 'バリデーション' do
    context '名前が設定されている場合' do
      it 'バリデーションが通る' do
        expect(group.valid?).to eq(true)
      end
    end

    context '名前が設定されていない場合' do
      it 'バリデーションが通らない' do
        group.name = nil
        expect(group.valid?).to eq(false)
      end
    end
  end
end
