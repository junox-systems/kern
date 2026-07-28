# frozen_string_literal: true

require "test_helper"

class Kern::Engine::RankerTest < ActiveSupport::TestCase
  test "highest scored commitment is ranked primary" do
    candidates = [
      { commitment: "c1", score: 0.3, signals: {} },
      { commitment: "c2", score: 0.9, signals: {} },
      { commitment: "c3", score: 0.5, signals: {} }
    ]

    ranked = Kern::Engine::Ranker.new(candidates).apply

    assert_equal "c2", ranked.first[:commitment]
    assert_equal :primary, ranked.first[:rank]
  end

  test "next three are ranked secondary" do
    candidates = (1..6).map do |i|
      { commitment: "c#{i}", score: i * 0.1, signals: {} }
    end

    ranked = Kern::Engine::Ranker.new(candidates).apply

    assert_equal :primary, ranked[0][:rank]
    assert_equal :secondary, ranked[1][:rank]
    assert_equal :secondary, ranked[2][:rank]
    assert_equal :secondary, ranked[3][:rank]
    assert_equal :hidden, ranked[4][:rank]
    assert_equal :hidden, ranked[5][:rank]
  end

  test "single candidate is ranked primary" do
    candidates = [ { commitment: "c1", score: 0.5, signals: {} } ]

    ranked = Kern::Engine::Ranker.new(candidates).apply

    assert_equal :primary, ranked.first[:rank]
  end

  test "empty input returns empty output" do
    ranked = Kern::Engine::Ranker.new([]).apply
    assert_empty ranked
  end
end
