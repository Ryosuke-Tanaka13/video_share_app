# frozen_string_literal: true

require 'rails_helper'

RSpec.xdescribe User, type: :model do
  let(:organization) { create(:organization) }
  let(:user_staff) { build(:user_staff) }

  before(:each) do
    organization
    user_staff
  end

  xdescribe 'バリデーションについて' do
    subject do
      user_staff
    end

    it 'バリデーションが通ること' do
      expect(subject).to be_valid
    end

    xdescribe '#email' do
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
          user_staff = create(:user_staff)
          subject.email = user_staff.email
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

    xdescribe '#name' do
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
end
