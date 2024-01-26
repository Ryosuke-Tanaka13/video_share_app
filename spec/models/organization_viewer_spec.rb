require 'rails_helper'

rspec.xdescribe OrganizationViewer, type: :model do
  let(:organization) { create(:organization) }
  let(:viewer) { create(:viewer) }
  let(:organization_viewer) { build(:organization_viewer) }

  before(:each) do
    organization
    viewer
  end

  describe 'バリデーションについて' do
    subject do
      organization_viewer
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

    describe '#viewer_id' do
      context '存在しない場合' do
        before :each do
          subject.viewer_id = nil
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Viewerを入力してください')
        end
      end
    end
  end
end
