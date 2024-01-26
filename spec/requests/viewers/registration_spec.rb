require 'rails_helper'

Rspec.xdescribe 'ViewerRegistration', type: :request do
  describe '視聴者新規作成' do
    describe '正常' do
      it '新規作成' do
        get new_viewer_registration_path
        expect {
          post viewer_registration_path,
            params: {
              viewer: {
                name:                  'test',
                email:                 'test@email.com',
                password:              'password',
                password_confirmation: 'password'
              }
            }
        }.to change(Viewer, :count).by(1)
      end

      it '作成後ログイン画面へリダイレクトされる' do
        expect(
          post(viewer_registration_path,
            params: {
              viewer: {
                name:                  'test',
                email:                 'test@email.com',
                password:              'password',
                password_confirmation: 'password'
              }
            }
          )
        ).to redirect_to new_viewer_session_url
      end
    end

    describe '異常' do
      it '入力が不十分だと新規作成されない' do
        get new_viewer_registration_path
        expect {
          post viewer_registration_path,
            params: {
              viewer: {
                name:                  '',
                email:                 'test@email.com',
                password:              'password',
                password_confirmation: 'password'
              }
            }
        }.to change(User, :count).by(0)
      end

      it '登録失敗するとエラーを出す' do
        expect(
          post(viewer_registration_path,
            params: {
              viewer: {
                name:                  '',
                email:                 'test@email.com',
                password:              'password',
                password_confirmation: 'password'
              }
            }
          )
        ).to render_template :new
      end
    end
  end
end
