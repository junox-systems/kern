class InboxController < ApplicationController
  def show
    @commitments = Current.operator.commitments.inbox.order(created_at: :desc)
    @current = @commitments.first
  end
end
