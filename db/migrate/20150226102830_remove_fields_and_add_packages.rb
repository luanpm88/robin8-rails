class RemoveFieldsAndAddPackages < ActiveRecord::Migration
  def migrate(direction)
    super
    Package.create(slug: "basic-monthly", is_active: true, price: 99.00,
                   interval: 30, name: "Basic Monthly", description: "basic monthly subscription", sku_id:2257477) if direction == :up

    Package.create(slug: "basic-yearly", is_active: true, price: 999.00,
                   interval: 365, name: "Basic Yearly", description: "basic yearly subscription", sku_id: 2257479) if direction == :up

    Package.create(slug: "pro-monthly", is_active: true, price: 199.00,
                   interval: 30, name: "Pro Monthly", description: "pro monthly subscription", sku_id: 2257481) if direction == :up

    Package.create(slug: "pro-yearly", is_active: true, price: 1999.00,
                   interval: 365, name: "Pro Yearly", description: "pro yearly subscription", sku_id:401395) if direction == :up

    Package.create(slug: "premium-monthly", is_active: true, price: 500.00,
                   interval: 30, name: "Premium Monthly", description: "premium monthly subscription", sku_id: 2257485) if direction == :up

    Package.create(slug: "premium-yearly", is_active: true, price: 4999.00,
                   interval: 365, name: "Premium Yearly", description: "premium yearly subscription", sku_id: 2257487) if direction == :up


    Package.delete_all if direction == :down
  end

  def up
    remove_column :payments, :encrypted_card_number
    remove_column :payments, :expiration_month
    remove_column :payments, :expiration_year
    remove_column :payments, :order_id
    remove_column :payments, :encrypted_security_code
    remove_column :payments, :charged_amount
    rename_column :payments,:total_amount, :amount
    add_column :payments,:bluesnap_charge_id,:integer

    remove_column :subscriptions, :auto_renew
    rename_column :subscriptions,:shopper_id, :bluesnap_shopper_id
    add_column :subscriptions, :bluesnap_subscription_id,:integer

    add_column :subscriptions,:suspended_at,:datetime

  end

  def down
    add_column :payments, :encrypted_card_number,:string
    add_column :payments, :expiration_month,:integer
    add_column :payments, :expiration_year,:integer
    add_column :payments, :order_id,:integer
    add_column :payments, :encrypted_security_code,:string
    add_column :payments, :charged_amount,:float
    rename_column :payments,:amount,:total_amount
    remove_column :payments,:bluesnap_charge_id,:integer

    add_column :subscriptions, :auto_renew,:boolean,:default=>true
    rename_column :subscriptions,:bluesnap_shopper_id,:shopper_id
    remove_column :subscriptions, :bluesnap_subscription_id,:integer

  end
end
