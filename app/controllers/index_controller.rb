class IndexController < ApplicationController
  before_action :wx_auth!, only: [:test]

  def index
    if params[:discount].present?
      @bargains = Bargain.where("discount >= '#{1 - params[:discount].to_f / 10 }'").order("created_at desc").includes(:product).paginate(page: params[:page], per_page: 50, total_entries: 500)
    else
      @bargains = Bargain.order("created_at desc").includes(:product).paginate(page: params[:page], per_page: 50, total_entries: 500)
    end
    render layout: false
  end

  def test

  end
end
