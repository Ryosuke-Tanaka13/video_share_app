# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Viewer, type: :model do
  let :viewer do
    build(:viewer)
  end

  describe 'バリデーションについて' do
    subject do
      viewer
    end

    it 'バリデーションが通ること' do
      expect(subject).to be_valid
    end

    describe '#email' do
      context '存在しない場合' do
        before :each do
          subject.email = nil
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Eメールを入力してください')
        end
      end

      context 'uniqueでない場合' do
        before :each do
          viewer = create(:viewer)
          subject.email = viewer.email
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Eメールはすでに存在します')
        end
      end

      %i[
        email0.com
        あああ.com
        今井.com
        @@.com
      ].each do |email|
        context '不正なemailの場合' do
          before :each do
            subject.email = email
          end

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
        before :each do
          subject.name = nil
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Nameを入力してください')
        end
      end

      context '文字数が1文字の場合' do
        before :each do
          subject.name = 'a' * 1
        end

        it 'バリデーションが通ること' do
          expect(subject).to be_valid
        end
      end

      context '文字数が10文字の場合' do
        before :each do
          subject.name = 'a' * 10
        end

        it 'バリデーションが通ること' do
          expect(subject).to be_valid
        end
      end

      context '文字数が11文字の場合' do
        before :each do
          subject.name = 'a' * 11
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Nameは10文字以内で入力してください')
        end
      end

      context '空白の場合' do
        before :each do
          subject.name = ' '
        end

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

  let(:organization) { create(:organization) }
  let!(:system_admin) { create(:system_admin) }
  let!(:user_owner) { create(:user_owner, organization: organization) }
  let!(:viewer1) { create(:viewer1, is_valid: true) }
  let!(:another_viewer) { create(:another_viewer, is_valid: false) }
  let!(:organization_viewer1) { create(:organization_viewer, viewer: viewer1, organization: organization) }
  let!(:organization_viewer2) { create(:organization_viewer2, viewer: another_viewer, organization: organization) }

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