require 'rails_helper'

RSpec.describe Viewer, type: :model do
  let(:viewer) { build(:viewer) }
  let(:organization) { create(:organization) }
  let!(:system_admin) { create(:system_admin) }
  let!(:user_owner) { create(:user_owner, organization: organization) }
  let!(:viewer1) { create(:viewer1, is_valid: true) }
  let!(:another_viewer) { create(:another_viewer, is_valid: false) }
  let!(:admin_viewer) { create(:organization_viewer, viewer: viewer1, organization: organization) }
  let!(:member_viewer) { create(:member_viewer, viewer: another_viewer, organization: organization) }

  describe 'バリデーションについて' do
    subject { viewer }

    it 'バリデーションが通ること' do
      expect(subject).to be_valid
    end

    describe '#email' do
      context '存在しない場合' do
        before(:each) { subject.email = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Eメールを入力してください')
        end
      end

      context 'uniqueでない場合' do
        before(:each) do
          existing_viewer = create(:viewer)
          subject.email = existing_viewer.email
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Eメールはすでに存在します')
        end
      end

      %i[email0.com あああ.com 今井.com @@.com].each do |email|
        context '不正なemailの場合' do
          before(:each) { subject.email = email }

          it 'バリデーションに落ちること' do
            expect(subject).to be_invalid
          end

          it 'バリデーションのエラーが正しいこと' do
            subject.valid?
            expect(subject.errors.full_messages).to include('Eメールは不正な値です')
          end
        end
      end
    end

    describe '#name' do
      context '存在しない場合' do
        before(:each) { subject.name = nil }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Nameを入力してください')
        end
      end

      context '文字数が1文字の場合' do
        before(:each) { subject.name = 'a' * 1 }

        it 'バリデーションが通ること' do
          expect(subject).to be_valid
        end
      end

      context '文字数が10文字の場合' do
        before(:each) { subject.name = 'a' * 10 }

        it 'バリデーションが通ること' do
          expect(subject).to be_valid
        end
      end

      context '文字数が11文字の場合' do
        before(:each) { subject.name = 'a' * 11 }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Nameは10文字以内で入力してください')
        end
      end

      context '空白の場合' do
        before(:each) { subject.name = ' ' }

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Nameを入力してください')
        end
      end
    end
  end

  describe '投稿者の場合' do
    context 'for_current_user メソッド' do
      it '組織に所属している視聴者を返す' do
        viewers = described_class.for_current_user(user_owner, organization.id)
        expect(viewers).to include(viewer1)
        expect(viewers).not_to include(another_viewer)
      end

      it '退会済みの視聴者は返さない' do
        viewers = described_class.for_current_user(user_owner, organization.id)
        expect(viewers).not_to include(another_viewer)
      end
    end
  end

  describe 'システム管理者の場合' do
    context 'for_system_admin メソッド' do
      it '組織に所属している視聴者を返す' do
        viewers = described_class.for_system_admin(organization.id)
        expect(viewers).to include(viewer1)
        expect(viewers).not_to include(another_viewer)
      end

      it '退会済みの視聴者は返さない' do
        viewers = described_class.for_system_admin(organization.id)
        expect(viewers).not_to include(another_viewer)
      end
    end
  end
end
