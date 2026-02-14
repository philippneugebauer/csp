require "test_helper"

class CustomerDocumentsControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile

  setup do
    @customer = customers(:one)
    @manager = customer_success_managers(:one)
    sign_in_as(@manager)
  end

  test "creates note activity with documents and optional comment" do
    document = fixture_file_upload("activity_doc.txt", "text/plain")

    assert_difference("NoteActivity.count", 1) do
      post customer_customer_documents_url(@customer), params: {
        customer_document: {
          comment: "Quarterly report",
          documents: [ document ]
        }
      }
    end

    note = NoteActivity.order(:id).last
    assert_redirected_to customer_url(@customer)
    assert_equal "Quarterly report", note.body
    assert note.documents.attached?
  end

  test "requires at least one document" do
    assert_no_difference("NoteActivity.count") do
      post customer_customer_documents_url(@customer), params: {
        customer_document: { comment: "No file" }
      }
    end

    assert_redirected_to customer_url(@customer)
  end
end
