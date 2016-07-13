class CommonsController < ApplicationController

  def read_hot_item
    @hot_item = HotItem.find params[:id]
    render :text => '你找的榜单没有找到' if @hot_item.nil?
    @hot_item.redis_read_count.increment
    redirect_to @hot_item.origin_url
  end
end
