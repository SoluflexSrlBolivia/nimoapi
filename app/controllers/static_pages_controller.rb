class StaticPagesController < ApplicationController

  def home
    if logged_in?

    end
  end

  def help
  end

  def about
  end

  def contact
  end

  def not_found
    
  end
  def terms_and_conditions

    render :layout => false
  end
end
