require 'rails_helper'

RSpec.describe 'ViewerRegistrationSystem', type: :system do
  let(:deactivated_viewer) { create(:deactivated_viewer, confirmed_at: Time.now) }

  before(:each) do
    deactivated_viewer
  end

  describe '正常' do
    it '視聴者新規作成' do
      visit new_viewer_registration_path
      expect {
        fill_in 'viewer[name]', with: 'test'
        fill_in 'viewer[email]', with: 'test@email.com'
        fill_in 'viewer[password]', with: 'password'
        fill_in 'viewer[password_confirmation]', with: 'password'
        check 'agreeTerms'
        click_button 'アカウント登録'
      }.to change(Viewer, :count).by(1)
    end

    it '非アクティブアカウントと同じメールアドレスは新規作成可能' do
      visit new_viewer_registration_path
      expect {
        fill_in 'viewer[name]', with: 'test'
        fill_in 'viewer[email]', with: deactivated_viewer.email
        fill_in 'viewer[password]', with: 'password'
        fill_in 'viewer[password_confirmation]', with: 'password'
        check 'agreeTerms'
        click_button 'アカウント登録'
      }.to change(Viewer, :count).by(1)
    end
  end

  describe '異常' do
    it '入力が不十分だと作成されない' do
      visit new_viewer_registration_path
      expect {
        fill_in 'viewer[name]', with: ''
        fill_in 'viewer[email]', with: 'test@email.com'
        fill_in 'viewer[password]', with: 'password'
        fill_in 'viewer[password_confirmation]', with: 'password'
        check 'agreeTerms'
        click_button 'アカウント登録'
      }.not_to change(Viewer, :count)
    end
  end
end
