require 'rails_helper'

RSpec.xdescribe Organization, type: :model do
  let :organization do
    build(:organization)
  end

  describe 'バリデーションについて' do
    subject do
      organization
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
          expect(subject.errors.full_messages).to include('組織のEメールは不正な値です')
        end
      end

      context 'uniqueでない場合' do
        before :each do
          organization = create(:organization)
          subject.email = organization.email
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('組織のEメールはすでに存在します')
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
            expect(subject.errors.full_messages).to include('組織のEメールは不正な値です')
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
          expect(subject.errors.full_messages).to include('組織名は1文字以上で入力してください')
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
          expect(subject.errors.full_messages).to include('組織名は10文字以内で入力してください')
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
          expect(subject.errors.full_messages).to include('組織名を入力してください')
        end
      end
    end

    describe '#plan' do
      context 'nilの場合' do
        before :each do
          subject.plan = nil
        end

        it 'バリデーションが通ること' do
          expect(subject).to be_valid
        end
      end

      context '0, 1000, 2000を代入した場合' do
        it 'バリデーションが通ること' do
          [-1, 0, 1000, 2000].each do |valid_plan|
            subject.plan = valid_plan
            expect(subject).to be_valid
          end
        end
      end

      context '0, 1000, 2000以外が代入された場合' do
        before :each do
          subject.plan = 500
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Planは一覧にありません')
        end
      end
    end

    describe '#customer_id' do
      context 'nilの場合' do
        before :each do
          subject.customer_id = nil
        end

        it 'バリデーションが通ること' do
          expect(subject).to be_valid
        end
      end

      context 'uniqueの場合' do
        before :each do
          subject.customer_id = 'unique_id'
        end

        it 'バリデーションに通ること' do
          expect(subject).to be_valid
        end
      end

      context 'uniqueでない場合' do
        before :each do
          organization = create(:organization)
          subject.customer_id = organization.customer_id
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Customerはすでに存在します')
        end
      end
    end

    describe '#subscription_id' do
      context 'nilの場合' do
        before :each do
          subject.subscription_id = nil
        end

        it 'バリデーションが通ること' do
          expect(subject).to be_valid
        end
      end

      context 'uniqueの場合' do
        before :each do
          subject.subscription_id = 'unique_id'
        end

        it 'バリデーションが通ること' do
          expect(subject).to be_valid
        end
      end

      context 'uniqueでない場合' do
        before :each do
          organization = create(:organization)
          subject.subscription_id = organization.subscription_id
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('Subscriptionはすでに存在します')
        end
      end
    end
  end
end
