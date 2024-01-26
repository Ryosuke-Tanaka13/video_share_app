require 'rails_helper'

rspec.xdescribe 'ビデオコメント', type: :feature, js: true do
  let!(:video_it) { create(:video_it) }

  it 'コメントの表示・非表示を切り替えられる' do
    visit video_path(video_it)

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