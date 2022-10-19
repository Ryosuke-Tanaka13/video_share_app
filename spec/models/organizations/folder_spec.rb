require 'rails_helper'

RSpec.describe Folder, type: :model do
  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id) }
  let(:folder_celeb) { create(:folder_celeb, organization_id: user_owner.organization_id) }
  let(:folder_tech) { create(:folder_tech, organization_id: user_owner.organization_id) }

  before(:each) do
    organization
    user_owner
    folder_celeb
    folder_tech
  end

  describe '正常' do
    it '正常値で保存可能' do
      folder_celeb = create(:folder_celeb, name: 'セレブエンジニア2')
      expect(folder_celeb.valid?).to eq(true)
    end
  end

  describe 'バリデーション' do
    describe '名前' do
      it '空白' do
        folder_celeb.name = ''
        expect(folder_celeb.valid?).to eq(false)
        expect(folder_celeb.errors.full_messages).to include('名前を入力してください')
      end

      it '重複' do
        folder_tech.name = 'セレブエンジニア'
        expect(folder_tech.valid?).to eq(false)
        expect(folder_tech.errors.full_messages).to include('名前はすでに存在します')
      end
    end

    describe '組織ID' do
      it '空白' do
        folder_celeb.organization_id = ''
        expect(folder_celeb.valid?).to eq(false)
        expect(folder_celeb.errors.full_messages).to include('組織を入力してください')
      end
    end
  end
end
