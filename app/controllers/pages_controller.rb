class PagesController < ApplicationController
  def show
    render html: "hello", layout: true
  end
end
