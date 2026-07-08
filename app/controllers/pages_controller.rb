class PagesController < ApplicationController
  def landing
    render Views::Pages::Landing.new(products: Product.order(:id))
  end
end
