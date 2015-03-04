class RemoveFieldsAndAddPackages < ActiveRecord::Migration
  def migrate(direction)
    super
    Package.create(slug: "basic-monthly", is_active: true, price: 19.00,
                   interval: 30, name: "Basic Monthly", description: "basic monthly subscription", sku_id:3262130) if direction == :up
    Package.create(slug: "basic-annual", is_active: true, price: 180.00,
                   interval: 365, name: "Basic Annual", description: "basic annual subscription", sku_id: 3262134) if direction == :up
    Package.create(slug: "business-monthly", is_active: true, price: 179.00,
                   interval: 30, name: "Business Monthly", description: "business monthly subscription", sku_id: 3262138) if direction == :up
    Package.create(slug: "business-annual", is_active: true, price: 1800.00,
                   interval: 365, name: "Business Annual", description: "business annual subscription", sku_id:3262152) if direction == :up
    Package.create(slug: "enterprise-monthly", is_active: true, price: 399.00,
                   interval: 30, name: "Enterprise Monthly", description: "enterprise monthly subscription", sku_id: 3262154) if direction == :up
    Package.create(slug: "enterprise-annual", is_active: true, price: 4200.00,
                   interval: 365, name: "Enterprise Annual", description: "enterprise annual subscription", sku_id: 3262156) if direction == :up
    Package.create(slug: "pro-monthly", is_active: true, price: 299.00,
                   interval: 30, name: "Pro Monthly", description: "pro monthly subscription", sku_id:3262158) if direction == :up
    Package.create(slug: "pro-annual", is_active: true, price: 3000.00,
                   interval: 365, name: "Pro Annual", description: "pro annual subscription", sku_id:3262160) if direction == :up
    Package.create(slug: "premium-monthly", is_active: true, price: 499.00,
                   interval: 30, name: "Premium Monthly", description: "premium monthly subscription", sku_id: 3262162) if direction == :up
    Package.create(slug: "premium-annual", is_active: true, price: 4980.00,
                   interval: 365, name: "Premium Annual", description: "premium annual subscription", sku_id: 3262170) if direction == :up
    Package.create(slug: "ultra-monthly", is_active: true, price: 1200.00,
                   interval: 30, name: "Ultra Monthly", description: "ultra monthly subscription", sku_id: 3262172) if direction == :up
    Package.create(slug: "ultra-annual", is_active: true, price: 12000.00,
                   interval: 365, name: "Ultra Annual", description: "ultra annual subscription", sku_id: 3262174) if direction == :up

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
