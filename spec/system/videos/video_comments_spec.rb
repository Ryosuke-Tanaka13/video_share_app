require 'rails_helper'

RSpec.describe 'ビデオコメントの表示・非表示', type: :feature, js: true do
  let!(:organization) { create(:organization) }
  let!(:viewer) { create(:viewer, confirmed_at: Time.now, organizations: [organization]) }
  let!(:video_it) { create(:video_it, organization: organization) }

  before do
    # ログインページにアクセスしてログインする
    visit new_viewer_session_path
    fill_in 'メールアドレス', with: viewer.email
    fill_in 'パスワード', with: viewer.password
    click_button 'ログイン'

    # 動画詳細ページにアクセス
    visit video_path(video_it)
  end

  it 'コメントの表示・非表示を切り替えられる' do
    # 初期状態の確認
    expect(page).not_to have_css('#comments_area')
    expect(page).to have_button('コメントを表示する')

    # コメント表示
    click_button 'コメントを表示する'
    expect(page).to have_css('#comments_area')
    expect(page).to have_button('コメントを非表示にする')

    # コメント非表示
    click_button 'コメントを非表示にする'
    expect(page).not_to have_css('#comments_area')
    expect(page).to have_button('コメントを表示する')
  end
end
