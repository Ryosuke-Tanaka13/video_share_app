class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    event = construct_event_from_webhook
    return unless event

    handle_event(event)
    status 200
  end

  private

  def construct_event_from_webhook
    webhook_secret = 'whsec_afb7b774cceb0f48ddc5391960d2a16879da2d3c91dacd359a32c70bccc88688'
    payload = request.body.read

    return Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true)) if webhook_secret.empty?

    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
  rescue JSON::ParserError, Stripe::SignatureVerificationError => e
    puts "⚠️  Webhook handling error: #{e.message}"
    status 400
    nil
  end

  def handle_event(event)
    case event.type
    when 'checkout.session.completed'
      handle_checkout_session_completed(event)
    when 'invoice.paid'
      handle_invoice_paid(event)
    when 'customer.subscription.updated'
      handle_subscription_updated(event)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event)
    when 'customer.deleted'
      handle_customer_deleted(event)
    else
      puts "Unhandled event type: #{event.type}"
    end
  end

  # 初回支払い成功時のイベント
  def handle_checkout_session_completed(event)
    session = event.data.object
    organization = Organization.find(session.client_reference_id)
    update_organization(organization, customer_id: session.customer, plan: session.amount_total, payment_success: true,
      subscription_id: session.subscription)
    redirect_to session.success_url
  end

  # 継続課金成功時のイベント
  def handle_invoice_paid(event)
    session = event.data.object
    organization = Organization.find_by(customer_id: session.customer)
    update_organization(organization, payment_success: true)
  end

  # サブスクリプション情報更新成功時のイベント
  def handle_subscription_updated(event)
    session = event.data.object
    organization = Organization.find_by(customer_id: session.customer)
    update_organization(organization, plan: session.plan.amount, payment_success: true)
  end

  # 決済失敗時、退会時のイベント
  def handle_subscription_deleted(event)
    session = event.data.object
    organization = Organization.find_by(customer_id: session.customer)
    update_organization(organization, plan: -1, payment_success: false, subscription_id: nil)
  end

  # 顧客情報削除時のイベント
  def handle_customer_deleted(event)
    session = event.data.object
    organization = Organization.find_by(customer_id: session.id)
    update_organization(organization, customer_id: nil)
  end

  # 組織情報アップデートメソッド
  def update_organization(organization, attributes)
    ApplicationRecord.transaction do
      organization.update!(attributes)
    end
  end
end
