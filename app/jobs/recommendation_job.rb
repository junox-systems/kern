# frozen_string_literal: true

class RecommendationJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    operator = Operator.find_by(id: user_id)
    return unless operator

    recommendations = Kern::Engine::Pipeline.run(operator: operator, current_time: Time.current)
    primary = recommendations.find(&:primary?)

    html = ApplicationController.render(
      partial: primary ? "dashboard/recommendation_card" : "dashboard/empty_state",
      locals: primary ? { recommendation: primary } : {}
    )

    Turbo::StreamsChannel.broadcast_replace_to(
      operator,
      "recommendations",
      target: "primary_recommendation",
      html: "<turbo-frame id=\"primary_recommendation\">#{html}</turbo-frame>"
    )
  end
end
