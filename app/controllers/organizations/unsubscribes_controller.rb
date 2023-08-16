class Organizations::UnsubscribesController < OrganizationsController
  before_action :ensure_logged_in
  before_action :ensure_admin_or_owner_of_set_organization
  before_action :set_organization
  layout 'organizations_auth'

  def show; end

  def update
    if Organization.bulk_update(params[:id])
      begin
        # Stripeのサブスクリプションをキャンセル
        Stripe::Subscription.cancel(@organization.subscription_id)
        # Stripe上の顧客情報を削除
        Stripe::Customer.delete(@organization.customer_id)
      rescue => e
        # Stripeとの通信でエラーが発生した場合のエラーハンドリング
        flash[:error] = 'Stripeのサブスクリプション解約でエラーが発生しました'
      end

      if current_system_admin
        flash[:notice] = '退会処理が完了しました。'
        redirect_to organizations_url
      else
        reset_session
        flash[:notice] = '退会処理が完了しました。'
        redirect_to root_url
      end
    else
      render :show
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end
end
