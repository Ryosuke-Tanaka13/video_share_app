require 'rails_helper'

RSpec.xdescribe Group, type: :model do
  let(:organization) { Organization.create(name: 'organization_name') }
  let(:group) { Group.new(name: 'group_name', organization: organization) }
  
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