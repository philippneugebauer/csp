class CustomerNotesController < ApplicationController
  before_action :set_customer

  # POST /customers/:customer_id/customer_notes
  def create
    @customer_note = @customer.customer_notes.new(
      customer_note_params.merge(customer_success_manager: current_customer_success_manager)
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
