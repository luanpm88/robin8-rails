module MarketingDashboard::InvoiceHistoriesHelper

  def need_price_sheet(i)
    i.price_sheet == true ? "是" : "否"
  end
end
