class Organizations::PaymentsController < ApplicationController
  before_action :ensure_admin_or_owner_of_set_organization
  layout 'payments'

  def new
    @organization = Organization.find(params[:id])
  end

  def create
    organization = Organization.find(params[:id])
    price_id = params[:priceId]
    if organization.plan.nil?
      session = create_session(price_id, organization)
      redirect_to session.url, allow_other_host: true
    else
      edit_session(price_id, organization)
      redirect_to organization_folders_path(organization)
    end
  end

  private

  # 初回プラン選択
  def create_session(price_id, organization)
    Stripe::Checkout::Session.create({
      # テスト用URL
      success_url: "#{request.protocol}#{request.host_with_port}/organizations/#{organization.id}/folders",
      cancel_url: "#{request.protocol}#{request.host_with_port}/organizations/#{organization.id}/payment/new",
      customer: organization.customer_id,
      client_reference_id: organization.id,
      mode: 'subscription',
      line_items: [{
        quantity: 1,
        price: price_id
      }]
    })
  end

  # プラン変更
  def edit_session(price_id, organization)
    subscription = Stripe::Subscription.retrieve(organization.subscription_id)
    Stripe::Subscription.update(
      subscription.id,
      {
        cancel_at_period_end: false,
        proration_behavior: 'create_prorations',
        items: [{
            id: subscription.items.data[0].id,
            price: price_id
        }]
      }
    )
  end

  # システム管理者　set_organizationのオーナー　のみ許可
  def ensure_admin_or_owner_of_set_organization
    if !current_system_admin? && (current_user&.role != 'owner' || !user_of_set_organization?)
      flash[:danger] = '権限がありません。'
      redirect_back(fallback_location: root_url)
    end
  end
end
