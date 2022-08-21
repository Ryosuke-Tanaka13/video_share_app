module LoginSupport
  def login(user)
    visit '/users/sign_in'

    fill_in 'Eメール', with: user.email
    fill_in 'パスワード', with: user.password
    click_button 'ログイン'
  end

  def login_session(user)
    allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { user_id: user.id } }
  end

  def current_user(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user) { user }
  end
end
