require 'rails_helper'

RSpec.describe OrganizationLoginlessViewer, type: :model do
  let(:organization) { create(:organization) }
  let(:loginless_viewer) { create(:loginless_viewer) }
  let(:organization_loginless_viewer) { build(:organization_loginless_viewer) }

  before(:each) do
    organization
    loginless_viewer
  end

  describe 'バリデーションについて' do
    subject do
      organization_loginless_viewer
    end

    it 'バリデーションが通ること' do
      expect(subject).to be_valid
    end

    describe '#organization_id' do
      context '存在しない場合' do
        before :each do
          subject.organization_id = nil
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Organizationを入力してください')
        end
      end
    end

    describe '#loginless_viewer_id' do
      context '存在しない場合' do
        before :each do
          subject.loginless_viewer_id = nil
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Loginless viewerを入力してください')
        end
      end
    end
  end
end
