class CustomerDocumentsController < ApplicationController
  before_action :set_customer

  # POST /customers/:customer_id/customer_documents
  def create
    documents = Array(customer_document_params[:documents]).compact_blank
    if documents.empty?
      redirect_to @customer, alert: "Please choose at least one document."
      return
    end

    comment = customer_document_params[:comment].to_s.strip
    default_body = "Document upload: #{documents.map(&:original_filename).join(', ')}"

    activity = NoteActivity.new(
      customer: @customer,
      customer_success_manager: current_customer_success_manager,
      body: comment.presence || default_body,
      occurred_at: Time.current
    )
    activity.documents.attach(documents)

    if activity.save
      redirect_to @customer, notice: "Document activity was successfully added."
    else
      redirect_to @customer, alert: activity.errors.full_messages.to_sentence
    end
  end

  private
    def set_customer
      @customer = Customer.find(params.expect(:customer_id))
    end

    def customer_document_params
      params.expect(customer_document: [ :comment, { documents: [] } ])
    end
end
