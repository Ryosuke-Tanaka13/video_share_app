class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    webhook_secret = 'whsec_fbe2782c23506ffe71631ea6df862a52fac7f8518564a10d94fe2a864284cbb8'
    payload = request.body.read
    if !webhook_secret.empty?
      # Retrieve the event by verifying the signature using the raw body and secret if webhook signing is configured.
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      event = nil
  
      begin
        event = Stripe::Webhook.construct_event(
          payload, sig_header, webhook_secret
        )
      rescue JSON::ParserError => e
        # Invalid payload
        status 400
        return
      rescue Stripe::SignatureVerificationError => e
        # Invalid signature
        puts '⚠️  Webhook signature verification failed.'
        status 400
        return
      end
    else
      data = JSON.parse(payload, symbolize_names: true)
      event = Stripe::Event.construct_from(data)
    end
    # Get the type of webhook event sent
    event_type = event['type']
    data = event['data']
    data_object = data['object']
  
    case event.type
    # 初回支払い成功時のイベント
    when 'checkout.session.completed'
      session = event.data.object # sessionの取得
      organization = Organization.find(session.client_reference_id)
      
      ApplicationRecord.transaction do
        organization.customer_id = session.customer
        organization.plan = session.amount_total
        organization.payment_success = true
        organization.subscription_id = session.subscription
        organization.save!
      end
      redirect_to session.success_url

    # 継続課金成功時のイベント
    when 'invoice.paid'
      session = event.data.object
      organization = Organization.find_by(customer_id: session.customer)
      ApplicationRecord.transaction do
        organization.payment_success = true
        organization.save!
      end

    # サブスクリプション情報更新成功時のイベント
    when 'customer.subscription.updated'
      session = event.data.object
      organization = Organization.find_by(customer_id: session.customer)
      
      ApplicationRecord.transaction do
        organization.plan = session.plan.amount
        organization.payment_success = true
        organization.save!
      end
    
    # 決済失敗時、退会時のイベント
    when 'customer.subscription.deleted'
      session = event.data.object
      organization = Organization.find_by(customer_id: session.customer)
      ApplicationRecord.transaction do
        organization.plan = nil
        organization.payment_success = false
        organization.subscription_id = nil
        organization.save!
      end

    # 顧客情報削除時のイベント
    when 'customer.deleted'
      session = event.data.object
      organization = Organization.find_by(customer_id: session.id)
      ApplicationRecord.transaction do
        organization.customer_id = nil
        organization.save!
      end

    else
      puts "Unhandled event type: \#{event.type}"
    end
  
    status 200
  end
end
