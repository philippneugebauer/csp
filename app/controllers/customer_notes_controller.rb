class CustomerNotesController < ApplicationController
  before_action :set_customer

  # POST /customers/:customer_id/customer_notes
  def create
    @customer_note = NoteActivity.new(
      customer: @customer,
      customer_success_manager: current_customer_success_manager,
      body: customer_note_params[:body],
      occurred_at: customer_note_params[:noted_at]
    )

    if @customer_note.save
      redirect_to @customer, notice: "Customer note was successfully added."
    else
      redirect_to @customer, alert: @customer_note.errors.full_messages.to_sentence
    end
  end

  private
    def set_customer
      @customer = Customer.find(params.expect(:customer_id))
    end

    def customer_note_params
      params.expect(customer_note: [ :body, :noted_at ])
    end
end
