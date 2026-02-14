class SyncCustomerEmailsJob < ApplicationJob
  queue_as :default

  def perform(customer_id)
    customer = Customer.includes(:customer_success_manager).find(customer_id)
    Gmail::CustomerEmailSyncService.new(customer).sync!
  end
end
