# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2026 Zerocracy
# SPDX-License-Identifier: MIT

require_relative '../../lib/fbe/award'
require_relative '../../lib/fbe/bylaws'
require_relative '../test__helper'

class TestBylawCaps < Fbe::Test
  def test_charges_the_second_size_penalty_above_the_reward_floor
    assert_equal(8, contribution(love: 4).bill({ hoc: 850, comments: 5, reviews: 1 }).points)
  end

  def test_awards_a_size_bonus_just_above_its_minimum
    assert_equal(21, contribution.bill({ hoc: 101, comments: 5, reviews: 1 }).points)
  end

  def test_publishes_the_second_size_penalty
    text = contribution.bylaw.markdown
    assert_includes(text, 'When a code contribution is made, the author receives a bonus')
    assert_includes(text, 'deduct **16** points if more than **800**')
  end

  def test_caps_a_resolved_bug_reward_at_higher_generosity
    assert_equal(16, resolved(love: 3).bill({ hours: 1, self: 0 }).points)
  end

  def test_charges_the_self_report_fee_above_the_reward_floor
    assert_equal(8, resolved(anger: 1).bill({ hours: 1, self: 1 }).points)
  end

  def test_caps_the_delay_charge_in_the_bill
    assert_includes(resolved.bill({ hours: 3000, self: 0 }).greeting, '-20 for 125 days of delay')
  end

  def test_publishes_the_self_report_fee
    text = resolved.bylaw.markdown
    assert_includes(text, 'When a bug is resolved, the person who was assigned to it receives a bonus')
    assert_includes(text, 'deduct **16** points if they resolved the bug earlier reported by themselves')
  end

  def test_publishes_the_delay_charge_cap
    text = resolved.bylaw.markdown
    assert_includes(text, 'deduct **1**')
    assert_includes(text, 'no more than **20** points')
  end

  private

  def contribution(**levels)
    Fbe::Award.new(Fbe.bylaws(**levels).fetch('code-contribution-was-rewarded'))
  end

  def resolved(**levels)
    Fbe::Award.new(Fbe.bylaws(**levels).fetch('resolved-bug-was-rewarded'))
  end
end
