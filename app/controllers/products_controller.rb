class ProductsController < Frontend::CommonController
  layout 'searcher_and_side_bar'
  before_action :set_product

  def show
  end

  def get_template_variables(template)
    super

    @variables['product'] = @product
  end

  def add_to_shopping_cart
    sc = ShoppingCart.retrieve(current_customer, session[:shopping_cart])
    sc.add_product(@product)

    if customer_signed_in?
      sc.customer = current_customer
      sc.save
    else
      session[:shopping_cart] = sc.to_json(include: :shopping_carts_products)
    end

    redirect_to :customers_shopping_carts
  end

  def delete_from_shopping_cart
    if customer_signed_in?
      sc = current_customer.shopping_cart

      unless sc.blank?
        sc.remove_product(@product)
        current_customer.shopping_cart = sc
        current_customer.save

        # TODO save Shopping Cart in cache
      end
    end

    redirect_to :customers_shopping_carts
  end

  protected

  def set_breadcrumbs
  end

  def set_product
    @product = nil
    @category = nil

    # TODO find product by category id
    # if params[:category_slug].blank?
    #   @category = Category.find_by(slug: params[:category_slug])
    # end

    if !params[:slug].blank? || !params[:id].blank?
      attributes = { enabled: true }
      attributes[:slug] = params[:slug] unless params[:slug].blank?
      attributes[:id] = params[:id] unless params[:id].blank?

      @product = Product.find_by(attributes)
      @category = @product.categories.first unless @product.categories.empty?
    end
  end
end
