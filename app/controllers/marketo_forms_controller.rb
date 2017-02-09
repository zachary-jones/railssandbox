# controller to manage marketo form posts
class MarketoFormsController < ApplicationController
  def upsert
    render json: ApplicationHelper::MarketoRepository.new.upsert_marketo_lead(params)
  end
  def read
    render json: ApplicationHelper::MarketoRepository.new.get_marketo_lead(params)
  end  
end