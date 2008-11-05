class SvgtestController < ApplicationController
  helper :widget
  
  def index
    render :content_type => 'application/xhtml+xml'
  end

  def test
  end

  def partial
  end

  def giza
  end

  def tust
  end

  def test2
  end

  def test3
  end

  def hide
  end
  
  def blink
    render :content_type => 'application/xhtml+xml'
  end
  
  def includesvg
    @motors = IntTag.find(:all)
    respond_to do |format|
      format.html { render :content_type => 'application/xhtml+xml' }
      format.js
    end
	end
  
  def includesvgupdate
    @motors = IntTag.find(:all)
  end

end
