class DashboardController < ApplicationController
  def show
    recommendations = Kern::Engine::Pipeline.run(
      operator: Current.user,
      current_time: Time.current
    )

    @primary = recommendations.find(&:primary?)
    @secondary = recommendations.select(&:secondary?)
    @current_block = current_block
    @inbox_count = Current.user.commitments.inbox.count
  end

  private

  def current_block
    today = Date.current
    time_of_day = Time.current.strftime("%H:%M:%S")

    Current.user.calendar_blocks
      .where(date: today)
      .order(:start_time)
      .find do |block|
        block.start_time.strftime("%H:%M:%S") <= time_of_day &&
          time_of_day < block.end_time.strftime("%H:%M:%S")
      end
  end
end
