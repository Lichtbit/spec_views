# frozen_string_literal: true

class ArticlesController < ApplicationController
  def download
    params[:id] = 'one' unless params[:id].in?(%w[one two])

    send_data(
      File.read(Rails.root.join("public/pdf_#{params[:id]}.pdf")),
      filename: "pdf_#{params[:id]}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
    )
  end
end
