# frozen_string_literal: true

class ArticlesController < ApplicationController
  def download
    params[:id] = 'one' unless params[:id].in?(%w[one two])

    send_data(
      Rails.public_path.join("pdf_#{params[:id]}.pdf").binread,
      filename: "pdf_#{params[:id]}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
    )
  end
end
