module LoginSupport
  def login(user)
    visit '/users/sign_in'

    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: user.password
    click_button 'ログイン'
  end

  def login_system_admin(system_admin)
    visit '/system_admins/sign_in'
    fill_in 'メールアドレス', with: system_admin.email
    fill_in 'パスワード', with: system_admin.password
    click_button 'ログイン'
  end

  def login_session(user)
    allow_any_instance_of(ActionDispatch::Request).to receive(:session) { { id: user.id } }
  end

  def current_user(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user) { user }
  end

  def current_system_admin(system_admin)
    allow_any_instance_of(ApplicationController).to receive(:current_system_admin) { system_admin }
  end

  def current_viewer(viewer)
    allow_any_instance_of(ApplicationController).to receive(:current_viewer) { viewer }
  end
end
