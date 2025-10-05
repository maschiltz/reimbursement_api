class ApplicationController < ActionController::Base

  def home
    if request.post?
      @contents = 'parse here'
    end
  end

end
