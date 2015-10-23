class PaymentSerializer < ActiveModel::Serializer
  attributes :id, :user_product_id, :product_id, :card_last_four_digits, :card_type, :coupon, :amount, :status, :last_charge_result,
             :created_at, :updated_at, :bluesnap_charge_id, :tax, :formatted_created_at, :another_format_created_at, :currency

  def formatted_created_at
    object.created_at.strftime("%d/%m/%Y %H:%M")
  end

  def another_format_created_at
    object.created_at.strftime("%m/%d/%Y %H:%M")
  end

end
