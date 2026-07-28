# frozen_string_literal: true

class RecommendationJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    recommendations = Kern::Engine::Pipeline.run(operator: user, current_time: Time.current)
    primary = recommendations.find(&:primary?)

    html = ApplicationController.render(
      partial: primary ? "dashboard/recommendation_card" : "dashboard/empty_state",
      locals: primary ? { recommendation: primary } : {}
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      user,
      "recommendations",
      target: "primary_recommendation",
      html: "<turbo-frame id=\"primary_recommendation\">#{html}</turbo-frame>"
    )
  end
end
