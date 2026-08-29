# frozen_string_literal: true

class AddStripeFieldsToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :stripe_customer_id, :string
    add_column :accounts, :stripe_subscription_id, :string
    add_column :accounts, :stripe_price_id, :string
    add_column :accounts, :subscription_status, :string, default: "trialing", null: false
    add_column :accounts, :subscription_plan, :string
    add_column :accounts, :subscription_current_period_end, :datetime
    add_column :accounts, :subscription_cancel_at_period_end, :boolean, default: false, null: false

    add_index :accounts, :stripe_customer_id
    add_index :accounts, :stripe_subscription_id
    add_index :accounts, :subscription_status
  end
end
