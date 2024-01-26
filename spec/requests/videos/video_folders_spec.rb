require 'rails_helper'

Rspec.xdescribe 'VideoFolders', type: :request do
  let(:system_admin) { create(:system_admin, confirmed_at: Time.now) }

  let(:organization) { create(:organization) }
  let(:user_owner) { create(:user_owner, organization_id: organization.id, confirmed_at: Time.now) }
  let(:user_staff) { create(:user_staff, organization_id: organization.id, confirmed_at: Time.now) }
  let(:viewer) { create(:viewer, confirmed_at: Time.now) }

  let(:folder_celeb) { create(:folder_celeb, organization_id: user_owner.organization_id) }
  let(:folder_tech) { create(:folder_tech, organization_id: user_owner.organization_id) }
  let(:video_sample) do
    create(:video_sample, organization_id: user_owner.organization.id, user_id: user_owner.id, folders: [folder_celeb, folder_tech])
  end
  let(:video_test) { create(:video_test, organization_id: user_staff.organization.id, user_id: user_staff.id, folders: [folder_celeb]) }

  let(:another_organization) { create(:another_organization) }
  let(:another_user_owner) { create(:another_user_owner, organization_id: another_organization.id, confirmed_at: Time.now) }
  let(:another_video) { create(:another_video, organization_id: another_user_owner.organization.id, user_id: another_user_owner.id) }

  let(:video_folder) { create(:video_folder, video_id: video_sample.id, folder_id: folder_celeb.id) }
  let(:video_folder2) { create(:video_folder, video_id: video_test.id, folder_id: folder_celeb.id) }

  before(:each) do
    system_admin
    organization
    another_organization
    user_owner
    another_user_owner
    user_staff
    viewer
    folder_celeb
    folder_tech
    video_folder
    video_folder2
  end

  describe 'DELETE #destroy' do
    describe 'システム管理者が現在のログインユーザー' do
      before(:each) do
        sign_in system_admin
      end

      describe '正常' do
        it 'フォルダ内の動画を削除する' do
          expect {
            delete video_video_folder_path(video_sample, video_folder, folder_id: folder_celeb.id, organization_id: organization.id)
          }.to change(VideoFolder, :count).by(-1)
        end

        it 'folders#showにリダイレクトされる' do
          expect(
            delete(video_video_folder_path(video_sample, video_folder, folder_id: folder_celeb.id, organization_id: organization.id))
          ).to redirect_to organization_folder_path(folder_celeb, organization_id: organization.id)
        end
      end
    end

    describe 'オーナーが現在のログインユーザー' do
      before(:each) do
        sign_in user_owner
      end

      describe '正常' do
        it 'フォルダ内の動画を削除する' do
          expect {
            delete video_video_folder_path(video_sample, video_folder, folder_id: folder_celeb.id, organization_id: organization.id)
          }.to change(VideoFolder, :count).by(-1)
        end

        it 'folders#showにリダイレクトされる' do
          expect(
            delete(video_video_folder_path(video_sample, video_folder, folder_id: folder_celeb.id, organization_id: organization.id))
          ).to redirect_to organization_folder_url(folder_celeb, organization_id: organization.id)
        end
      end
    end

    describe '動画投稿者本人が現在のログインユーザ' do
      before(:each) do
        sign_in user_staff
      end

      describe '正常' do
        it 'フォルダ内の動画を削除する' do
          expect {
            delete video_video_folder_path(video_test, video_folder2, folder_id: folder_celeb.id, organization_id: organization.id)
          }.to change(VideoFolder, :count).by(-1)
        end

        it 'folders#showにリダイレクトされる' do
          expect(
            delete(video_video_folder_path(video_test, video_folder2, folder_id: folder_celeb.id, organization_id: organization.id))
          ).to redirect_to organization_folder_url(folder_celeb, organization_id: organization.id)
        end
      end
    end

    describe '本人以外の動画投稿者が現在のログインユーザ' do
      before(:each) do
        sign_in user_staff
      end

      describe '異常' do
        it '本人以外の動画投稿者は削除できない' do
          expect {
            delete video_video_folder_path(video_sample, video_folder, folder_id: folder_celeb.id, organization_id: organization.id)
          }.not_to change(VideoFolder, :count)
        end
      end
    end

    describe '別組織のオーナーが現在のログインユーザ' do
      before(:each) do
        sign_in another_user_owner
      end

      describe '異常' do
        it '別組織のオーナーは削除できない' do
          expect {
            delete video_video_folder_path(video_sample, video_folder, folder_id: folder_celeb.id, organization_id: organization.id)
          }.not_to change(VideoFolder, :count)
        end
      end
    end

    describe '視聴者が現在のログインユーザ' do
      before(:each) do
        sign_in viewer
      end

      describe '異常' do
        it '視聴者は削除できない' do
          expect {
            delete video_video_folder_path(video_sample, video_folder, folder_id: folder_celeb.id, organization_id: organization.id)
          }.not_to change(VideoFolder, :count)
        end
      end
    end

    describe '非ログイン' do
      describe '異常' do
        it '非ログインは削除できない' do
          expect {
            delete video_video_folder_path(video_sample, video_folder, folder_id: folder_celeb.id, organization_id: organization.id)
          }.not_to change(VideoFolder, :count)
        end
      end
    end
  end
end
