class Users::UnsubscribesController < UsersController
  before_action :ensure_logged_in
  before_action :not_exist
  before_action :ensure_admin_or_owner_in_same_organization_as_set_user_or_correct_user
  before_action :set_user
  layout 'users_auth'

  def show; end

  def update
    @user.update(is_valid: false)
    if current_user == @user
      reset_session
      flash[:notice] = '退会処理が完了しました。'
      redirect_to root_path
    elsif current_user&.role == 'owner'
      flash[:notice] = "#{@user.name}のユーザー情報を削除しました"
      redirect_to users_path(organization_id: current_user.organization_id)
    else # システム管理者の場合退会者の詳細へ遷移
      flash[:notice] = "#{@user.name}のユーザー情報を削除しました"
      redirect_to user_path(params[:id])
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  # set_userと同組織投稿者　投稿者本人　のみ許可
  def ensure_user_in_same_organization_as_set_user_or_correct_viewer
    unless user_in_same_organization_as_set_user? || current_viewer?
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end
end
