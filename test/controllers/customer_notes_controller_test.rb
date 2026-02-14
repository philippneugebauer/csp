require "test_helper"

class CustomerNotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:one)
    @manager = customer_success_managers(:one)
    sign_in_as(@manager)
  end

  test "creates note activity" do
    assert_difference("NoteActivity.count", 1) do
      post customer_customer_notes_url(@customer), params: {
        customer_note: {
          body: "Kickoff recap"
        }
      }
    end

    note = NoteActivity.order(:id).last
    assert_redirected_to customer_url(@customer)
    assert_equal @manager, note.customer_success_manager
    assert_equal "Kickoff recap", note.body
    assert_not note.documents.attached?
  end
end
