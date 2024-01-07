# spec/features/video_comments_spec.rb
require 'rails_helper'

RSpec.feature "VideoComments", type: :feature, js: true do
  let!(:video_it) { create(:video_it) } # 事前にVideoを作成しておく

  scenario "User can toggle comments" do
    visit video_path(video_it)

    expect(page).not_to have_css("#comments_area") # 初めてページを訪れたときはコメントエリアが表示されていないことを確認

    click_button "コメントを表示する" # ボタンをクリック

    expect(page).to have_css("#comments_area") # コメントエリアが表示されていることを確認
    expect(page).to have_button("コメントを非表示にする") # ボタンのテキストが変わっていることを確認

    click_button "コメントを非表示にする" # ボタンを再度クリック

    expect(page).not_to have_css("#comments_area") # コメントエリアが再び非表示になっていることを確認
    expect(page).to have_button("コメントを表示する") # ボタンのテキストが元に戻っていることを確認
  end
end