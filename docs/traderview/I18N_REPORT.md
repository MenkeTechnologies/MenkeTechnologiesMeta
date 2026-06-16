# i18n Coverage Report — 2026-06-05

## Headline

| Metric | Count |
|---|---|
| Statically-resolvable i18n keys in JS/HTML source |    33577 |
| Keys defined in `app_i18n_en.json` | 34335 |
| **Missing keys** (used but not defined) | **    4342** |
| Coverage |  |

## Concentration by namespace (count · prefix)

```
2558 view.scanners
 108 view.reports
  35 view.tutorial
  30 chart.series
  23 view.triple_screen
  23 view.signal_decomposition
  21 view.note_templates
  20 view.trades
  19 view.demark_pivots
  18 view.trade_compare
  18 view.risk_gate
  18 view.portfolio_allocator
  18 view.cup_and_handle
  18 view.black_litterman
  18 view.bartlett
  17 view.trade_detail
  17 view.deflated_sharpe
  16 view.var_calculator
  15 view.implementation_shortfall
  15 view.dashboards
  15 view.abc_pattern
  14 view.rr_butterfly
  14 view.iv_rank
  14 view.goal_tracker
  14 view.clusters_correlation
  14 view.breadth_thrust
  14 view.absorption
  13 view.trade_plan_checklist
  13 view.marginal_var
  13 view.iv_solver
  13 view.iv_backtest
  12 view.tax_lots
  12 view.stop_loss_best_of
  12 view.pair_trade
  12 view.open_type
  12 view.oi_change
  12 view.dashboard
  12 view.brier_score
  12 common.parse
  11 view.microprice
```

## Largest single hot-spot: `view.scanners.preset.*` (2,558 keys = 59% of all missing)

Root cause: `frontend/js/views/scanners.js` defines **1,285 scanner preset IDs**, each looking up TWO i18n keys (`.label` and `.desc`). The i18n catalog only has a handful of these defined — the rest fall back to rendering the raw key as text.

## All missing keys by namespace

### `view.scanners.*` — 2558 missing
```
view.scanners.preset.absorption_down_squeeze.desc
view.scanners.preset.absorption_down_squeeze.label
view.scanners.preset.absorption_up_squeeze.desc
view.scanners.preset.absorption_up_squeeze.label
view.scanners.preset.accelerating_down_trend.desc
view.scanners.preset.accelerating_down_trend.label
view.scanners.preset.accelerating_up_trend.desc
view.scanners.preset.accelerating_up_trend.label
view.scanners.preset.all_directions_aligned_hot_vol_down.desc
view.scanners.preset.all_directions_aligned_hot_vol_down.label
view.scanners.preset.all_directions_aligned_hot_vol_up.desc
view.scanners.preset.all_directions_aligned_hot_vol_up.label
view.scanners.preset.all_green_tight_day.desc
view.scanners.preset.all_green_tight_day.label
view.scanners.preset.all_red_tight_day.desc
view.scanners.preset.all_red_tight_day.label
view.scanners.preset.anchor_drift_squeeze.desc
view.scanners.preset.anchor_drift_squeeze.label
view.scanners.preset.apathy_at_year_high.desc
view.scanners.preset.apathy_at_year_high.label
view.scanners.preset.apathy_at_year_low.desc
view.scanners.preset.apathy_at_year_low.label
view.scanners.preset.asymmetric_extreme_bias.desc
view.scanners.preset.asymmetric_extreme_bias.label
view.scanners.preset.asymmetric_range_near_high_far_low_close_at_hod_hot_vol.desc
  ... (2533 more)
```

### `view.reports.*` — 108 missing
```
view.reports.adv.cum_pnl
view.reports.adv.scatter
view.reports.cmp.by_dow
view.reports.cmp.by_hold
view.reports.cmp.by_hour
view.reports.cmp.by_price
view.reports.cmp.long_net
view.reports.cmp.long_trades
view.reports.cmp.long_win_pct
view.reports.cmp.loss_avg_hold
view.reports.cmp.loss_avg_qty
view.reports.cmp.short_net
view.reports.cmp.short_trades
view.reports.cmp.short_win_pct
view.reports.cmp.win_avg_hold
view.reports.cmp.win_avg_qty
view.reports.col.asset
view.reports.col.dow
view.reports.col.hold
view.reports.col.hour
view.reports.col.month
view.reports.col.price
view.reports.col.side
view.reports.col.symbol
view.reports.dd.max
  ... (83 more)
```

### `view.tutorial.*` — 35 missing
```
view.tutorial.data.catalysts
view.tutorial.data.crypto
view.tutorial.data.halts
view.tutorial.data.live_ticks
view.tutorial.data.quotes
view.tutorial.data.sentiment
view.tutorial.data.short_interest
view.tutorial.data.webull
view.tutorial.journal.ai
view.tutorial.journal.journal
view.tutorial.journal.reviews
view.tutorial.research.dark_pool
view.tutorial.rg.aggressive
view.tutorial.rg.beginner
view.tutorial.rg.compliance
view.tutorial.rg.dry_run
view.tutorial.rg.intermediate
view.tutorial.rg.paper
view.tutorial.rg.tune
view.tutorial.rg.webhook
view.tutorial.risk_gate.intro
view.tutorial.strategy.backtest
view.tutorial.trading.paper
view.tutorial.trading.sizing
view.tutorial.trading.webull
  ... (10 more)
```

### `chart.series.*` — 30 missing
```
chart.series.asset
chart.series.atr
chart.series.bar
chart.series.bar_num
chart.series.close
chart.series.count
chart.series.current
chart.series.days
chart.series.down
chart.series.equity
chart.series.fill
chart.series.high
chart.series.imbalance
chart.series.line
chart.series.low
chart.series.mid
chart.series.mtm_now
chart.series.pivot
chart.series.pl_at_expiry
chart.series.rank
chart.series.return
chart.series.sample_num
chart.series.series
chart.series.sigma
chart.series.spot
  ... (5 more)
```

### `view.triple_screen.*` — 23 missing
```
view.triple_screen.intermediate.no_tide
view.triple_screen.intermediate.overbought_hit
view.triple_screen.intermediate.overbought_no
view.triple_screen.intermediate.oversold_hit
view.triple_screen.intermediate.oversold_no
view.triple_screen.ripple.down_hit
view.triple_screen.ripple.down_no
view.triple_screen.ripple.no_tide
view.triple_screen.ripple.up_hit
view.triple_screen.ripple.up_no
view.triple_screen.screen.intermediate
view.triple_screen.screen.long_tide
view.triple_screen.screen.short_ripple
view.triple_screen.tide.down
view.triple_screen.tide.neutral
view.triple_screen.tide.up
view.triple_screen.validate.breakout_down
view.triple_screen.validate.breakout_up
view.triple_screen.validate.daily_osc
view.triple_screen.validate.overbought
view.triple_screen.validate.oversold
view.triple_screen.validate.threshold_order
view.triple_screen.validate.weekly_trend
```

### `view.signal_decomposition.*` — 23 missing
```
view.signal_decomposition.comp.approximation
view.signal_decomposition.comp.detail
view.signal_decomposition.comp.imf
view.signal_decomposition.comp.noise
view.signal_decomposition.comp.residual
view.signal_decomposition.comp.trend
view.signal_decomposition.error.null
view.signal_decomposition.field.levels
view.signal_decomposition.field.max_imfs
view.signal_decomposition.field.max_sift_iter
view.signal_decomposition.field.window
view.signal_decomposition.method.emd.label
view.signal_decomposition.method.ssa.label
view.signal_decomposition.method.wavelet.label
view.signal_decomposition.validate.levels
view.signal_decomposition.validate.max_imfs
view.signal_decomposition.validate.max_sift_iter
view.signal_decomposition.validate.non_finite
view.signal_decomposition.validate.series_min
view.signal_decomposition.validate.ssa
view.signal_decomposition.validate.unknown_method
view.signal_decomposition.validate.wavelet
view.signal_decomposition.validate.window
```

### `view.note_templates.*` — 21 missing
```
view.note_templates.btn.delete
view.note_templates.btn.edit
view.note_templates.btn.reset
view.note_templates.btn.save
view.note_templates.col.default
view.note_templates.col.name
view.note_templates.col.updated
view.note_templates.empty
view.note_templates.field.body
view.note_templates.field.default
view.note_templates.field.name
view.note_templates.field.scope
view.note_templates.h1
view.note_templates.h2.new_or_edit
view.note_templates.hint
view.note_templates.scope.journal
view.note_templates.scope.trade
view.note_templates.section.journal
view.note_templates.section.trade
view.note_templates.toast.deleted
view.note_templates.toast.saved
```

### `view.trades.*` — 20 missing
```
view.trades.alert.bulk_done
view.trades.alert.closed_expired
view.trades.alert.error
view.trades.alert.no_tags
view.trades.alert.select_first
view.trades.export.csv
view.trades.foot.average
view.trades.foot.total
view.trades.label.n_selected
view.trades.pagination.next
view.trades.pagination.page_of
view.trades.pagination.prev
view.trades.pnl.gross
view.trades.pnl.net
view.trades.prompt.risk
view.trades.prompt.stop
view.trades.prompt.target
view.trades.view.charts_large
view.trades.view.charts_small
view.trades.view.table
```

### `view.demark_pivots.*` — 19 missing
```
view.demark_pivots.bias.above_r1.hint
view.demark_pivots.bias.above_r1.label
view.demark_pivots.bias.below_s1.hint
view.demark_pivots.bias.below_s1.label
view.demark_pivots.bias.pivot_r1.hint
view.demark_pivots.bias.pivot_r1.label
view.demark_pivots.bias.s1_pivot.hint
view.demark_pivots.bias.s1_pivot.label
view.demark_pivots.formula_prefix
view.demark_pivots.validate.close_in_range
view.demark_pivots.validate.field_positive
view.demark_pivots.validate.high_ge_low
view.demark_pivots.validate.open_in_range
view.demark_pivots.xbase.bearish.hint
view.demark_pivots.xbase.bearish.label
view.demark_pivots.xbase.bullish.hint
view.demark_pivots.xbase.bullish.label
view.demark_pivots.xbase.neutral.hint
view.demark_pivots.xbase.neutral.label
```

### `view.trade_compare.*` — 18 missing
```
view.trade_compare.hint.intro
view.trade_compare.row.bar_interval
view.trade_compare.row.closed
view.trade_compare.row.entry
view.trade_compare.row.exit
view.trade_compare.row.fees
view.trade_compare.row.gross_pnl
view.trade_compare.row.hold_h
view.trade_compare.row.mae
view.trade_compare.row.mfe
view.trade_compare.row.net_pnl
view.trade_compare.row.opened
view.trade_compare.row.qty
view.trade_compare.row.r_multiple
view.trade_compare.row.risk_d
view.trade_compare.row.stop
view.trade_compare.row.target
view.trade_compare.too_few
```

### `view.risk_gate.*` — 18 missing
```
view.risk_gate.empty.no_config
view.risk_gate.empty.no_fires_30d
view.risk_gate.empty.no_fires_ever
view.risk_gate.empty.rules
view.risk_gate.error
view.risk_gate.hint.kill_switch
view.risk_gate.rule.blocked_symbols
view.risk_gate.rule.cool_down_after_loss_minutes
view.risk_gate.rule.kill_switch
view.risk_gate.rule.max_consecutive_losses_today
view.risk_gate.rule.max_loss_per_day_pct
view.risk_gate.rule.max_loss_per_trade_pct
view.risk_gate.rule.max_open_positions
view.risk_gate.rule.max_position_size_pct
view.risk_gate.rule.min_position_size_dollars
view.risk_gate.rule.regular_trading_hours_only
view.risk_gate.rule.require_plan_before_trade
view.risk_gate.rule.require_stop_loss
```

### `view.portfolio_allocator.*` — 18 missing
```
view.portfolio_allocator.h4.min_variance_weights
view.portfolio_allocator.h4.risk_contrib
view.portfolio_allocator.h4.tangency_weights
view.portfolio_allocator.h4.weights
view.portfolio_allocator.kv.converged
view.portfolio_allocator.kv.diversification_ratio
view.portfolio_allocator.kv.iterations
view.portfolio_allocator.kv.mv_portfolio_vol
view.portfolio_allocator.kv.portfolio_vol
view.portfolio_allocator.kv.tangency_excess_return
view.portfolio_allocator.kv.tangency_sharpe
view.portfolio_allocator.kv.tangency_vol
view.portfolio_allocator.kv.wtd_avg_single_asset_vol
view.portfolio_allocator.parse.non_numeric
view.portfolio_allocator.validate.assets_min
view.portfolio_allocator.validate.diagonal
view.portfolio_allocator.validate.not_symmetric
view.portfolio_allocator.validate.row_cols
```

### `view.cup_and_handle.*` — 18 missing
```
view.cup_and_handle.card.handle_low_d
view.cup_and_handle.card.left_rim_d
view.cup_and_handle.card.pivot_d
view.cup_and_handle.card.right_rim_d
view.cup_and_handle.card.trough_d
view.cup_and_handle.depth.deep
view.cup_and_handle.depth.shallow
view.cup_and_handle.depth.textbook
view.cup_and_handle.validate.bars_array
view.cup_and_handle.validate.bars_min
view.cup_and_handle.validate.cup_max
view.cup_and_handle.validate.cup_min
view.cup_and_handle.validate.handle_depth
view.cup_and_handle.validate.handle_max
view.cup_and_handle.validate.handle_min
view.cup_and_handle.validate.max_depth
view.cup_and_handle.validate.min_depth
view.cup_and_handle.validate.rim_tol
```

### `view.black_litterman.*` — 18 missing
```
view.black_litterman.parse.covariance_finite
view.black_litterman.parse.equilibrium_finite
view.black_litterman.parse.expected_sections
view.black_litterman.parse.tau_not_finite
view.black_litterman.validate.conf_dims
view.black_litterman.validate.conf_finite
view.black_litterman.validate.conf_row
view.black_litterman.validate.cov_dims
view.black_litterman.validate.cov_finite
view.black_litterman.validate.cov_row
view.black_litterman.validate.eq_array
view.black_litterman.validate.eq_finite
view.black_litterman.validate.inputs_missing
view.black_litterman.validate.loadings_dims
view.black_litterman.validate.loadings_finite
view.black_litterman.validate.loadings_row
view.black_litterman.validate.tau
view.black_litterman.validate.view_finite
```

### `view.bartlett.*` — 18 missing
```
view.bartlett.chart.series.grand_mean
view.bartlett.chart.series.group_idx
view.bartlett.chart.series.mean
view.bartlett.chart.series.pooled
view.bartlett.chart.series.variance
view.bartlett.demo.calm
view.bartlett.demo.high
view.bartlett.demo.large
view.bartlett.demo.loose
view.bartlett.demo.low
view.bartlett.demo.med
view.bartlett.demo.small
view.bartlett.demo.tight
view.bartlett.demo.wild
view.bartlett.empty_chart
view.bartlett.empty_mean_chart
view.bartlett.h2.mean_chart
view.bartlett.h2.variance_chart
```

### `view.trade_detail.*` — 17 missing
```
view.trade_detail.ai_error
view.trade_detail.alert.add_failed
view.trade_detail.alert.save_failed
view.trade_detail.btn.tape_replay
view.trade_detail.h2.review
view.trade_detail.mistakes.label
view.trade_detail.mistakes.placeholder
view.trade_detail.placeholder.journal
view.trade_detail.related.empty
view.trade_detail.related.h2
view.trade_detail.review_saved
view.trade_detail.review.entry_per_plan
view.trade_detail.review.exit_per_plan
view.trade_detail.review.mood
view.trade_detail.save_review
view.trade_detail.setup.label
view.trade_detail.setup.placeholder
```

### `view.deflated_sharpe.*` — 17 missing
```
view.deflated_sharpe.bar.deflated
view.deflated_sharpe.bar.observed
view.deflated_sharpe.error.null
view.deflated_sharpe.error.sweep
view.deflated_sharpe.series.n_trials_log
view.deflated_sharpe.series.you_are_here
view.deflated_sharpe.tier.high
view.deflated_sharpe.tier.moderate
view.deflated_sharpe.tier.overfit
view.deflated_sharpe.tier.very_high
view.deflated_sharpe.tier.weak
view.deflated_sharpe.validate.kurtosis
view.deflated_sharpe.validate.mertens_denom
view.deflated_sharpe.validate.n_observations
view.deflated_sharpe.validate.n_trials
view.deflated_sharpe.validate.observed_sharpe
view.deflated_sharpe.validate.skewness
```

### `view.var_calculator.*` — 16 missing
```
view.var_calculator.empty.no_variation
view.var_calculator.group.cornish_fisher
view.var_calculator.group.filtered
view.var_calculator.group.historical
view.var_calculator.row.current_sigma
view.var_calculator.row.excess_kurt
view.var_calculator.row.expected_shortfall
view.var_calculator.row.monotonic
view.var_calculator.row.sample_size
view.var_calculator.row.skew
view.var_calculator.row.var
view.var_calculator.row.var_cf
view.var_calculator.row.var_gauss
view.var_calculator.validate.constant
view.var_calculator.validate.need_20
view.var_calculator.validate.non_finite
```

### `view.implementation_shortfall.*` — 15 missing
```
view.implementation_shortfall.card.impact_d
view.implementation_shortfall.card.opportunity_d
view.implementation_shortfall.card.spread_d
view.implementation_shortfall.card.timing_d
view.implementation_shortfall.card.total_d
view.implementation_shortfall.error.null
view.implementation_shortfall.validate.arrival_mid
view.implementation_shortfall.validate.decision_mid
view.implementation_shortfall.validate.direction
view.implementation_shortfall.validate.filled_le_intended
view.implementation_shortfall.validate.filled_qty
view.implementation_shortfall.validate.final_mid
view.implementation_shortfall.validate.half_spread
view.implementation_shortfall.validate.intended_qty
view.implementation_shortfall.validate.vwap_fill
```

### `view.dashboards.*` — 15 missing
```
view.dashboards.alert.import_failed
view.dashboards.empty.active
view.dashboards.empty.no_views_match
view.dashboards.empty.tiles
view.dashboards.label.add_tile
view.dashboards.sidebar.bookmarks
view.dashboards.sidebar.favorites
view.dashboards.sidebar.favorites_empty
view.dashboards.sidebar.head
view.dashboards.tip.bm_add
view.dashboards.tip.drag
view.dashboards.tip.fav_add
view.dashboards.tip.move_down
view.dashboards.tip.move_up
view.dashboards.tip.remove_tile
```

### `view.abc_pattern.*` — 15 missing
```
view.abc_pattern.parse.expected_3_tokens
view.abc_pattern.parse.index_non_neg
view.abc_pattern.parse.kind_high_or_low
view.abc_pattern.parse.price_not_finite
view.abc_pattern.validate.max_b
view.abc_pattern.validate.min_b
view.abc_pattern.validate.min_c
view.abc_pattern.validate.min_gt_max
view.abc_pattern.validate.swing_index
view.abc_pattern.validate.swing_kind
view.abc_pattern.validate.swing_object
view.abc_pattern.validate.swing_price
view.abc_pattern.validate.swings_array
view.abc_pattern.validate.swings_max
view.abc_pattern.validate.swings_min
```

### `view.rr_butterfly.*` — 14 missing
```
view.rr_butterfly.error.null
view.rr_butterfly.row.bf_formula
view.rr_butterfly.row.interp
view.rr_butterfly.row.rr_over_atm
view.rr_butterfly.row.sigma_diff
view.rr_butterfly.row.source
view.rr_butterfly.validate.atm
view.rr_butterfly.validate.bf
view.rr_butterfly.validate.call_negative
view.rr_butterfly.validate.field_finite
view.rr_butterfly.validate.field_positive
view.rr_butterfly.validate.put_negative
view.rr_butterfly.validate.rr
view.rr_butterfly.validate.unknown_mode
```

### `view.iv_rank.*` — 14 missing
```
view.iv_rank.bar.iv_percentile
view.iv_rank.bar.iv_rank
view.iv_rank.env.high.hint
view.iv_rank.env.high.label
view.iv_rank.env.low.hint
view.iv_rank.env.low.label
view.iv_rank.env.normal.hint
view.iv_rank.env.normal.label
view.iv_rank.note.agree
view.iv_rank.note.diverge
view.iv_rank.note.mild
view.iv_rank.validate.current_iv
view.iv_rank.validate.history_finite
view.iv_rank.validate.history_min
```

### `view.goal_tracker.*` — 14 missing
```
view.goal_tracker.bar.dd_vs_limit
view.goal_tracker.bar.period_elapsed
view.goal_tracker.bar.return_vs_target
view.goal_tracker.empty.equity
view.goal_tracker.error.parse
view.goal_tracker.validate.equity_positive
view.goal_tracker.validate.max_dd_pct
view.goal_tracker.validate.need_equity
view.goal_tracker.validate.period_end
view.goal_tracker.validate.period_end_after
view.goal_tracker.validate.period_start
view.goal_tracker.validate.period_start_equity
view.goal_tracker.validate.target_pct_return
view.goal_tracker.validate.today
```

### `view.clusters_correlation.*` — 14 missing
```
view.clusters_correlation.conc.concentrated.hint
view.clusters_correlation.conc.concentrated.label
view.clusters_correlation.conc.diverse.hint
view.clusters_correlation.conc.diverse.label
view.clusters_correlation.conc.moderate.hint
view.clusters_correlation.conc.moderate.label
view.clusters_correlation.conc.tilted.hint
view.clusters_correlation.conc.tilted.label
view.clusters_correlation.empty.clusters
view.clusters_correlation.parse.corr_range
view.clusters_correlation.parse.notional_finite
view.clusters_correlation.validate.corr_array
view.clusters_correlation.validate.need_position
view.clusters_correlation.validate.threshold
```

### `view.breadth_thrust.*` — 14 missing
```
view.breadth_thrust.parse.advancing_non_neg
view.breadth_thrust.parse.declining_non_neg
view.breadth_thrust.parse.expected_2_tokens
view.breadth_thrust.validate.advancing
view.breadth_thrust.validate.breadth_array
view.breadth_thrust.validate.declining
view.breadth_thrust.validate.ema_period_int
view.breadth_thrust.validate.ema_period_min
view.breadth_thrust.validate.high_threshold
view.breadth_thrust.validate.low_lt_high
view.breadth_thrust.validate.low_threshold
view.breadth_thrust.validate.row_object
view.breadth_thrust.validate.window_int
view.breadth_thrust.validate.window_min
```

### `view.absorption.*` — 14 missing
```
view.absorption.parse.close_outside_low_high
view.absorption.parse.expected_4_tokens
view.absorption.parse.token_not_finite
view.absorption.parse.volume_must_be_positive
view.absorption.validate.bar_field_finite
view.absorption.validate.bar_object
view.absorption.validate.bars_array
view.absorption.validate.bars_min
view.absorption.validate.close_outside
view.absorption.validate.high_lt_low
view.absorption.validate.period_range
view.absorption.validate.threshold
view.absorption.validate.vol_multiplier
view.absorption.validate.volume
```

### `view.trade_plan_checklist.*` — 13 missing
```
view.trade_plan_checklist.empty.gates
view.trade_plan_checklist.label.thesis
view.trade_plan_checklist.placeholder.thesis
view.trade_plan_checklist.validate.account_equity
view.trade_plan_checklist.validate.entry_price
view.trade_plan_checklist.validate.is_long
view.trade_plan_checklist.validate.max_risk_pct
view.trade_plan_checklist.validate.min_r
view.trade_plan_checklist.validate.min_thesis_words
view.trade_plan_checklist.validate.risk_dollars
view.trade_plan_checklist.validate.stop_price
view.trade_plan_checklist.validate.target_price
view.trade_plan_checklist.validate.thesis
```

### `view.marginal_var.*` — 13 missing
```
view.marginal_var.parse.expected_2_sections
view.marginal_var.parse.non_finite_cell
view.marginal_var.parse.weight_row_tokens
view.marginal_var.validate.cov_array
view.marginal_var.validate.cov_dims
view.marginal_var.validate.cov_finite
view.marginal_var.validate.cov_row
view.marginal_var.validate.labels
view.marginal_var.validate.portfolio_required
view.marginal_var.validate.weight_finite
view.marginal_var.validate.weights_array
view.marginal_var.validate.weights_empty
view.marginal_var.validate.z_alpha
```

### `view.iv_solver.*` — 13 missing
```
view.iv_solver.empty.bad_sigma
view.iv_solver.row.abs_sigma
view.iv_solver.row.market_is
view.iv_solver.row.market_price
view.iv_solver.row.residual
view.iv_solver.validate.div_yield
view.iv_solver.validate.kind
view.iv_solver.validate.market_price
view.iv_solver.validate.no_arb_band
view.iv_solver.validate.risk_free
view.iv_solver.validate.spot
view.iv_solver.validate.strike
view.iv_solver.validate.time
```

### `view.iv_backtest.*` — 13 missing
```
view.iv_backtest.card.long_pnl_per_1
view.iv_backtest.card.short_pnl_per_1
view.iv_backtest.edge_fmt
view.iv_backtest.rec.long.hint
view.iv_backtest.rec.long.label
view.iv_backtest.rec.neutral.hint
view.iv_backtest.rec.neutral.label
view.iv_backtest.rec.short.hint
view.iv_backtest.rec.short.label
view.iv_backtest.validate.implied_bps
view.iv_backtest.validate.implied_positive
view.iv_backtest.validate.realized_finite
view.iv_backtest.validate.realized_min
```

### `view.tax_lots.*` — 12 missing
```
view.tax_lots.chart.cum_gain_loss
view.tax_lots.chart.event_idx
view.tax_lots.chart.gain_loss
view.tax_lots.chart.zero
view.tax_lots.empty_chart
view.tax_lots.empty_cum_chart
view.tax_lots.h2.cum_chart
view.tax_lots.h2.open_lots
view.tax_lots.h2.realized
view.tax_lots.h2.realized_chart
view.tax_lots.hint.cum_chart
view.tax_lots.hint.intro
```

### `view.stop_loss_best_of.*` — 12 missing
```
view.stop_loss_best_of.card.best_avg_per_trade_d
view.stop_loss_best_of.card.best_total_d
view.stop_loss_best_of.empty.results
view.stop_loss_best_of.hint.format
view.stop_loss_best_of.summary.fixed_dollar
view.stop_loss_best_of.summary.fixed_pct
view.stop_loss_best_of.validate.atr
view.stop_loss_best_of.validate.candidates_empty
view.stop_loss_best_of.validate.method
view.stop_loss_best_of.validate.side_long
view.stop_loss_best_of.validate.trades_empty
view.stop_loss_best_of.validate.value
```

### `view.pair_trade.*` — 12 missing
```
view.pair_trade.error.null
view.pair_trade.row.mean_sigma
view.pair_trade.validate.entry_z
view.pair_trade.validate.exit_lt_entry
view.pair_trade.validate.exit_z
view.pair_trade.validate.length_mismatch
view.pair_trade.validate.stop_gt_entry
view.pair_trade.validate.stop_z
view.pair_trade.validate.x_min
view.pair_trade.validate.x_non_finite
view.pair_trade.validate.y_min
view.pair_trade.validate.y_non_finite
```

### `view.open_type.*` — 12 missing
```
view.open_type.series.open
view.open_type.series.or_close
view.open_type.series.or_high
view.open_type.series.or_low
view.open_type.series.prior_high
view.open_type.series.prior_low
view.open_type.validate.field_positive
view.open_type.validate.or_close_range
view.open_type.validate.or_high_ge_low
view.open_type.validate.pd_high_ge_low
view.open_type.validate.pd_vah_ge_val
view.open_type.validate.va_in_range
```

### `view.oi_change.*` — 12 missing
```
view.oi_change.empty.alerts
view.oi_change.flow.building
view.oi_change.flow.flat
view.oi_change.flow.unwind
view.oi_change.hint.format
view.oi_change.tier.mild
view.oi_change.tier.notable
view.oi_change.tier.strong
view.oi_change.tier.surge
view.oi_change.validate.min_oi
view.oi_change.validate.pct_threshold
view.oi_change.validate.snapshots_empty
```

### `view.dashboard.*` — 12 missing
```
view.dashboard.period.
view.dashboard.stat.avg_hold
view.dashboard.stat.avg_r
view.dashboard.stat.expectancy
view.dashboard.stat.fees
view.dashboard.stat.largest_loss
view.dashboard.stat.largest_win
view.dashboard.stat.max_consec_losses
view.dashboard.stat.max_consec_wins
view.dashboard.stat.profit_factor
view.dashboard.stat.trades
view.dashboard.stat.win_rate
```

### `view.brier_score.*` — 12 missing
```
view.brier_score.parse.expected_2_tokens
view.brier_score.parse.outcome_0_or_1
view.brier_score.parse.prob_in_range
view.brier_score.validate.length_mismatch
view.brier_score.validate.n_bins_int
view.brier_score.validate.n_bins_min
view.brier_score.validate.outcome_binary
view.brier_score.validate.outcomes_array
view.brier_score.validate.prob_finite
view.brier_score.validate.prob_range
view.brier_score.validate.probs_array
view.brier_score.validate.probs_empty
```

### `common.parse.*` — 12 missing
```
common.parse.benchmark_weight
common.parse.expected_high_low_volume
common.parse.expected_price_size
common.parse.high_lt_low
common.parse.input_must_be_string
common.parse.non_finite_token
common.parse.portfolio_weight
common.parse.price_must_be_positive
common.parse.qty_must_be_positive
common.parse.size_must_be_non_negative
common.parse.volume_must_be_non_negative
common.parse.weight_not_finite
```

### `view.microprice.*` — 11 missing
```
view.microprice.empty.need_bid_ask
view.microprice.error.null
view.microprice.row.interp
view.microprice.row.source
view.microprice.row.spread
view.microprice.validate.ask
view.microprice.validate.ask_size
view.microprice.validate.bid
view.microprice.validate.bid_size
view.microprice.validate.crossed
view.microprice.validate.need_size
```

### `view.liquidity.*` — 11 missing
```
view.liquidity.empty.buckets
view.liquidity.empty.rows
view.liquidity.hint.format
view.liquidity.tier.illiquid
view.liquidity.tier.invisible
view.liquidity.tier.large
view.liquidity.tier.normal
view.liquidity.tier.whale
view.liquidity.validate.adv_empty
view.liquidity.validate.no_overlap
view.liquidity.validate.trades_empty
```

### `view.kalman_beta.*` — 11 missing
```
view.kalman_beta.empty.no_beta
view.kalman_beta.row.first_latest
view.kalman_beta.validate.asset_finite
view.kalman_beta.validate.asset_min
view.kalman_beta.validate.bench_finite
view.kalman_beta.validate.bench_min
view.kalman_beta.validate.beta0
view.kalman_beta.validate.length_mismatch
view.kalman_beta.validate.p0
view.kalman_beta.validate.q
view.kalman_beta.validate.r
```

### `view.greeks_profile.*` — 11 missing
```
view.greeks_profile.error.null
view.greeks_profile.validate.div_yield
view.greeks_profile.validate.grid_high
view.greeks_profile.validate.grid_low
view.greeks_profile.validate.grid_order
view.greeks_profile.validate.kind
view.greeks_profile.validate.n_points
view.greeks_profile.validate.risk_free
view.greeks_profile.validate.sigma
view.greeks_profile.validate.strike
view.greeks_profile.validate.time
```

### `view.brinson.*` — 11 missing
```
view.brinson.parse.expected_5_tokens
view.brinson.parse.returns_finite
view.brinson.placeholder.inputs
view.brinson.validate.bench_return
view.brinson.validate.bench_weight
view.brinson.validate.inputs_array
view.brinson.validate.inputs_empty
view.brinson.validate.port_return
view.brinson.validate.port_weight
view.brinson.validate.row_object
view.brinson.validate.sector
```

### `view.accounts_overview.*` — 11 missing
```
view.accounts_overview.chart.acct_idx
view.accounts_overview.chart.baseline_50
view.accounts_overview.chart.pnl
view.accounts_overview.chart.win_rate
view.accounts_overview.chart.zero
view.accounts_overview.empty_chart
view.accounts_overview.empty_wr_chart
view.accounts_overview.h2.pnl_chart
view.accounts_overview.h2.winrate_chart
view.accounts_overview.hint.intro
view.accounts_overview.hint.updated
```

### `view.yield_curve_pca.*` — 10 missing
```
view.yield_curve_pca.factor.curvature
view.yield_curve_pca.factor.level
view.yield_curve_pca.factor.slope
view.yield_curve_pca.row.cumulative
view.yield_curve_pca.row.eigenvalue
view.yield_curve_pca.validate.curves_min
view.yield_curve_pca.validate.row_cols
view.yield_curve_pca.validate.row_finite
view.yield_curve_pca.validate.tenors_min
view.yield_curve_pca.validate.top_k
```

### `view.vasicek.*` — 10 missing
```
view.vasicek.row.long_run_sigma
view.vasicek.row.long_run_target
view.vasicek.validate.a
view.vasicek.validate.b
view.vasicek.validate.dt
view.vasicek.validate.paths
view.vasicek.validate.r0
view.vasicek.validate.seed
view.vasicek.validate.sigma
view.vasicek.validate.steps
```

### `view.time_in_force.*` — 10 missing
```
view.time_in_force.btn.gtc_cancel_old
view.time_in_force.parity.diverged
view.time_in_force.validate.filled_le_original
view.time_in_force.validate.filled_qty
view.time_in_force.validate.good_until
view.time_in_force.validate.now
view.time_in_force.validate.original_qty
view.time_in_force.validate.placed_at
view.time_in_force.validate.session_open
view.time_in_force.validate.tif
```

### `view.kelly.*` — 10 missing
```
view.kelly.empty.data
view.kelly.error.api_dynamic
view.kelly.error.api_static
view.kelly.validate.need_pnl
view.kelly.validate.payoff_finite
view.kelly.validate.payoff_positive
view.kelly.validate.win_rate_finite
view.kelly.validate.win_rate_range
view.kelly.validate.window_exceeds
view.kelly.validate.window_positive
```

### `view.hotkeys.*` — 10 missing
```
view.hotkeys.action.add_journal_quick
view.hotkeys.action.go_dashboard
view.hotkeys.action.go_journal
view.hotkeys.action.go_paper
view.hotkeys.action.go_research
view.hotkeys.action.go_scanners
view.hotkeys.action.go_trades
view.hotkeys.action.go_watchlists
view.hotkeys.action.paper_buy_100
view.hotkeys.action.paper_sell_all
```

### `view.footprint.*` — 10 missing
```
view.footprint.empty.bars
view.footprint.empty.cells
view.footprint.foot.delta
view.footprint.foot.poc
view.footprint.foot.vol
view.footprint.hint.grid
view.footprint.hint.ticks
view.footprint.th.bar_n
view.footprint.validate.tick_size
view.footprint.validate.ticks_empty
```

### `view.execution_scheduler.*` — 10 missing
```
view.execution_scheduler.kv.done_at_bar
view.execution_scheduler.kv.filled
view.execution_scheduler.kv.last_fill_bar
view.execution_scheduler.kv.peak_participation
view.execution_scheduler.kv.shortfall
view.execution_scheduler.validate.curve_empty
view.execution_scheduler.validate.curve_invalid
view.execution_scheduler.validate.curve_zero
view.execution_scheduler.validate.participation
view.execution_scheduler.validate.total_order
```

### `view.effective_spread.*` — 10 missing
```
view.effective_spread.parse.direction_buy_sell
view.effective_spread.parse.expected_5_tokens
view.effective_spread.validate.cur_mid_finite
view.effective_spread.validate.del_mid_finite
view.effective_spread.validate.direction
view.effective_spread.validate.obs_array
view.effective_spread.validate.obs_empty
view.effective_spread.validate.obs_object
view.effective_spread.validate.spread_finite
view.effective_spread.validate.trade_finite
```

### `view.csi.*` — 10 missing
```
view.csi.validate.bar_missing
view.csi.validate.bars_array
view.csi.validate.bars_min
view.csi.validate.close_outside
view.csi.validate.high_lt_low
view.csi.validate.ohlc_finite
view.csi.validate.ohlc_numbers
view.csi.validate.open_outside
view.csi.validate.period_int
view.csi.validate.period_range
```

### `view.cks.*` — 10 missing
```
view.cks.validate.bar_missing
view.cks.validate.bars_array
view.cks.validate.bars_min
view.cks.validate.close_outside
view.cks.validate.high_lt_low
view.cks.validate.hlc_finite
view.cks.validate.hlc_numbers
view.cks.validate.p_range
view.cks.validate.q_range
view.cks.validate.x_positive
```

### `view.chaikin_osc.*` — 10 missing
```
view.chaikin_osc.validate.bar_missing
view.chaikin_osc.validate.bars_array
view.chaikin_osc.validate.bars_empty
view.chaikin_osc.validate.bars_min
view.chaikin_osc.validate.fast_lt_slow
view.chaikin_osc.validate.fast_range
view.chaikin_osc.validate.high_lt_low
view.chaikin_osc.validate.hlcv_numbers
view.chaikin_osc.validate.slow_range
view.chaikin_osc.validate.volume_negative
```

### `view.beta.*` — 10 missing
```
view.beta.parse.expected_asset_benchmark
view.beta.series.asset_pct
view.beta.series.bench_pct
view.beta.series.fit
view.beta.validate.asset_array
view.beta.validate.asset_finite
view.beta.validate.bench_array
view.beta.validate.bench_finite
view.beta.validate.length_mismatch
view.beta.validate.min_pairs
```

### `view.amihud.*` — 10 missing
```
view.amihud.parse.dollar_volume_finite
view.amihud.parse.expected_2_tokens
view.amihud.parse.return_finite_or_pct
view.amihud.validate.dollar_volume_type
view.amihud.validate.dollar_volumes_array
view.amihud.validate.length_mismatch
view.amihud.validate.period_int
view.amihud.validate.period_min
view.amihud.validate.return_type
view.amihud.validate.returns_array
```

### `view.american_option.*` — 10 missing
```
view.american_option.row.lsmc_ge_intrinsic
view.american_option.row.pct_of_american
view.american_option.validate.dividend
view.american_option.validate.field_positive
view.american_option.validate.kind
view.american_option.validate.paths
view.american_option.validate.rate
view.american_option.validate.seed
view.american_option.validate.sigma
view.american_option.validate.steps
```

### `view.almgren_chriss.*` — 10 missing
```
view.almgren_chriss.card.expected_impact
view.almgren_chriss.error.null
view.almgren_chriss.error.sweep
view.almgren_chriss.validate.eta
view.almgren_chriss.validate.gamma
view.almgren_chriss.validate.horizon
view.almgren_chriss.validate.lambda
view.almgren_chriss.validate.n_intervals
view.almgren_chriss.validate.sigma
view.almgren_chriss.validate.total_shares
```

### `view.ad_osc.*` — 10 missing
```
view.ad_osc.validate.bar_missing
view.ad_osc.validate.bars_array
view.ad_osc.validate.bars_min
view.ad_osc.validate.close_outside
view.ad_osc.validate.high_lt_low
view.ad_osc.validate.hlcv_finite
view.ad_osc.validate.hlcv_numbers
view.ad_osc.validate.period_int
view.ad_osc.validate.period_range
view.ad_osc.validate.volume_negative
```

### `view.tax_loss_harvest.*` — 9 missing
```
view.tax_loss_harvest.parse.avg_cost_positive
view.tax_loss_harvest.parse.current_price_non_neg
view.tax_loss_harvest.parse.executed_at_iso
view.tax_loss_harvest.parse.tokens_finite
view.tax_loss_harvest.validate.buys_array
view.tax_loss_harvest.validate.losers_array
view.tax_loss_harvest.validate.mtm_elected
view.tax_loss_harvest.validate.realized_ytd
view.tax_loss_harvest.validate.today
```

### `view.stress_test.*` — 9 missing
```
view.stress_test.empty.cells
view.stress_test.hint.legs
view.stress_test.validate.div_yield
view.stress_test.validate.iv_shocks_empty
view.stress_test.validate.legs_empty
view.stress_test.validate.price_shocks_empty
view.stress_test.validate.rate
view.stress_test.validate.shocks_finite
view.stress_test.validate.time_decay
```

### `view.series_smoother.*` — 9 missing
```
view.series_smoother.note.endpoint_null
view.series_smoother.note.theil_sen
view.series_smoother.validate.kalman_q
view.series_smoother.validate.kalman_r
view.series_smoother.validate.lowess_frac
view.series_smoother.validate.lowess_robust
view.series_smoother.validate.poly_degree
view.series_smoother.validate.series_finite
view.series_smoother.validate.series_min
```

### `view.second_order_greeks.*` — 9 missing
```
view.second_order_greeks.validate.div_yield
view.second_order_greeks.validate.grid_high
view.second_order_greeks.validate.grid_low
view.second_order_greeks.validate.kind
view.second_order_greeks.validate.n_points
view.second_order_greeks.validate.risk_free
view.second_order_greeks.validate.sigma
view.second_order_greeks.validate.strike
view.second_order_greeks.validate.tte
```

### `view.pyramid.*` — 9 missing
```
view.pyramid.empty.states
view.pyramid.hint.format
view.pyramid.validate.initial_entry
view.pyramid.validate.initial_qty
view.pyramid.validate.kind
view.pyramid.validate.need_tranche
view.pyramid.validate.side
view.pyramid.validate.tranche_qty
view.pyramid.validate.trigger_price
```

### `view.option_payoff.*` — 9 missing
```
view.option_payoff.error.api
view.option_payoff.error.null
view.option_payoff.validate.bad_kind
view.option_payoff.validate.leg_invalid
view.option_payoff.validate.leg_tagged
view.option_payoff.validate.need_leg
view.option_payoff.validate.premium
view.option_payoff.validate.qty
view.option_payoff.validate.strike
```

### `view.monte_carlo.*` — 9 missing
```
view.monte_carlo.error.null
view.monte_carlo.extra.down_jumps
view.monte_carlo.extra.jump_count_total
view.monte_carlo.extra.path_samples
view.monte_carlo.extra.up_jumps
view.monte_carlo.model.fbm
view.monte_carlo.model.gbm
view.monte_carlo.model.kou_jump
view.monte_carlo.model.merton_jump
```

### `view.momentum_crash.*` — 9 missing
```
view.momentum_crash.validate.crash_lookback
view.momentum_crash.validate.crash_threshold
view.momentum_crash.validate.max_leverage
view.momentum_crash.validate.periods_year
view.momentum_crash.validate.return_finite
view.momentum_crash.validate.returns_array
view.momentum_crash.validate.returns_min
view.momentum_crash.validate.target_vol
view.momentum_crash.validate.vol_lookback
```

### `view.kyles_lambda.*` — 9 missing
```
view.kyles_lambda.parse.expected_2_tokens
view.kyles_lambda.parse.price_change_finite
view.kyles_lambda.parse.signed_volume_finite
view.kyles_lambda.validate.length_mismatch
view.kyles_lambda.validate.pc_array
view.kyles_lambda.validate.sv_array
view.kyles_lambda.validate.window_finite
view.kyles_lambda.validate.window_int
view.kyles_lambda.validate.window_min
```

### `view.equivolume.*` — 9 missing
```
view.equivolume.validate.bar_object
view.equivolume.validate.bars_array
view.equivolume.validate.high_finite
view.equivolume.validate.high_ge_low
view.equivolume.validate.low_finite
view.equivolume.validate.vol_finite
view.equivolume.validate.vol_negative
view.equivolume.validate.width_finite
view.equivolume.validate.width_positive
```

### `view.discipline.*` — 9 missing
```
view.discipline.hint.intro
view.discipline.rule.direction_match
view.discipline.rule.qty_within
view.discipline.rule.stop_honored
view.discipline.rule.stop_set
view.discipline.score.passing
view.discipline.window.all_time
view.discipline.window.monthly
view.discipline.window.weekly
```

### `view.chandelier.*` — 9 missing
```
view.chandelier.validate.bar_missing
view.chandelier.validate.bars_array
view.chandelier.validate.bars_min
view.chandelier.validate.close_outside
view.chandelier.validate.high_lt_low
view.chandelier.validate.hlc_finite
view.chandelier.validate.hlc_numbers
view.chandelier.validate.multiplier
view.chandelier.validate.period_range
```

### `view.bollinger_squeeze.*` — 9 missing
```
view.bollinger_squeeze.validate.bb_period_int
view.bollinger_squeeze.validate.bb_period_min
view.bollinger_squeeze.validate.closes_array
view.bollinger_squeeze.validate.closes_finite
view.bollinger_squeeze.validate.closes_min
view.bollinger_squeeze.validate.lookback_int
view.bollinger_squeeze.validate.lookback_min
view.bollinger_squeeze.validate.n_stdev
view.bollinger_squeeze.validate.slack
```

### `view.atr_channel.*` — 9 missing
```
view.atr_channel.validate.bar_finite
view.atr_channel.validate.bars_array
view.atr_channel.validate.bars_min
view.atr_channel.validate.close_outside
view.atr_channel.validate.high_lt_low
view.atr_channel.validate.multiplier
view.atr_channel.validate.period_int
view.atr_channel.validate.period_range
view.atr_channel.validate.use_ema
```

### `view.asi.*` — 9 missing
```
view.asi.validate.bar_missing
view.asi.validate.bars_array
view.asi.validate.bars_empty
view.asi.validate.close_outside
view.asi.validate.high_lt_low
view.asi.validate.limit_move
view.asi.validate.ohlc_finite
view.asi.validate.ohlc_numbers
view.asi.validate.open_outside
```

### `view.volume_bar.*` — 8 missing
```
view.volume_bar.validate.price_finite
view.volume_bar.validate.price_positive
view.volume_bar.validate.print_object
view.volume_bar.validate.prints_array
view.volume_bar.validate.size_finite
view.volume_bar.validate.size_negative
view.volume_bar.validate.vpb_finite
view.volume_bar.validate.vpb_positive
```

### `view.tick_bar.*` — 8 missing
```
view.tick_bar.validate.price_finite
view.tick_bar.validate.price_positive
view.tick_bar.validate.print_object
view.tick_bar.validate.prints_array
view.tick_bar.validate.size_finite
view.tick_bar.validate.size_negative
view.tick_bar.validate.tpb_int
view.tick_bar.validate.tpb_min
```

### `view.setups_by_setup.*` — 8 missing
```
view.setups_by_setup.badge.negative
view.setups_by_setup.badge.positive
view.setups_by_setup.badge.scratch
view.setups_by_setup.empty.trades
view.setups_by_setup.h2.trades
view.setups_by_setup.h2.trades_suffix
view.setups_by_setup.parse.net_pnl_finite
view.setups_by_setup.parse.risk_amount_positive
```

### `view.risk_reward.*` — 8 missing
```
view.risk_reward.scale_out.target
view.risk_reward.validate.entry
view.risk_reward.validate.field_finite
view.risk_reward.validate.multiplier
view.risk_reward.validate.risk_budget
view.risk_reward.validate.side
view.risk_reward.validate.stop
view.risk_reward.validate.target
```

### `view.range_bar.*` — 8 missing
```
view.range_bar.validate.price_finite
view.range_bar.validate.price_positive
view.range_bar.validate.print_object
view.range_bar.validate.prints_array
view.range_bar.validate.size_finite
view.range_bar.validate.size_negative
view.range_bar.validate.target_finite
view.range_bar.validate.target_positive
```

### `view.order_staleness.*` — 8 missing
```
view.order_staleness.empty.orders
view.order_staleness.hint.format
view.order_staleness.validate.forgotten_hours
view.order_staleness.validate.now_invalid
view.order_staleness.validate.now_string
view.order_staleness.validate.orders_empty
view.order_staleness.validate.stale_hours
view.order_staleness.validate.warn_hours
```

### `view.optimal_f.*` — 8 missing
```
view.optimal_f.empty.need_losing_trade
view.optimal_f.sub.conservative_default
view.optimal_f.sub.twr_at_optimal
view.optimal_f.sub.ultra_conservative
view.optimal_f.sub.wins_losses
view.optimal_f.validate.need_5_pnls
view.optimal_f.validate.need_loser
view.optimal_f.validate.non_finite
```

### `view.journal.*` — 8 missing
```
view.journal.btn.refresh
view.journal.day_summary.closed
view.journal.day_summary.opened
view.journal.day_summary.qty
view.journal.day_summary.wls
view.journal.empty.no_trades
view.journal.h2.trades_for_day
view.journal.placeholder.body
```

### `view.index.*` — 8 missing
```
view.index.btn.accounts
view.index.btn.calendar
view.index.btn.goals
view.index.btn.new_trade
view.index.btn.note_templates
view.index.btn.reviews
view.index.btn.risk_gate
view.index.btn.tags
```

### `view.imbalance_bar.*` — 8 missing
```
view.imbalance_bar.validate.price_finite
view.imbalance_bar.validate.price_positive
view.imbalance_bar.validate.print_object
view.imbalance_bar.validate.prints_array
view.imbalance_bar.validate.size_finite
view.imbalance_bar.validate.size_negative
view.imbalance_bar.validate.threshold_finite
view.imbalance_bar.validate.threshold_positive
```

### `view.dollar_bar.*` — 8 missing
```
view.dollar_bar.validate.dpb_finite
view.dollar_bar.validate.dpb_positive
view.dollar_bar.validate.price_finite
view.dollar_bar.validate.price_positive
view.dollar_bar.validate.print_object
view.dollar_bar.validate.prints_array
view.dollar_bar.validate.size_finite
view.dollar_bar.validate.size_negative
```

### `view.cvi.*` — 8 missing
```
view.cvi.validate.bar_missing
view.cvi.validate.bars_array
view.cvi.validate.bars_min
view.cvi.validate.ema_range
view.cvi.validate.high_lt_low
view.cvi.validate.hl_finite
view.cvi.validate.hl_numbers
view.cvi.validate.roc_range
```

### `view.choppiness.*` — 8 missing
```
view.choppiness.regime.choppy.label
view.choppiness.regime.mixed.label
view.choppiness.regime.trending.label
view.choppiness.switch.bar
view.choppiness.switch.none
view.choppiness.validate.bars_lt_period
view.choppiness.validate.need_bar
view.choppiness.validate.period_min
```

### `view.cdmi.*` — 8 missing
```
view.cdmi.validate.close_finite
view.cdmi.validate.closes_array
view.cdmi.validate.closes_min
view.cdmi.validate.std_period_range
view.cdmi.validate.td_const_range
view.cdmi.validate.td_max_ge_const
view.cdmi.validate.td_max_ge_min
view.cdmi.validate.td_min
```

### `view.camarilla.*` — 8 missing
```
view.camarilla.parse.expected_hlc
view.camarilla.validate.close_outside
view.camarilla.validate.current_finite
view.camarilla.validate.high_lt_low
view.camarilla.validate.hlc_finite
view.camarilla.validate.hlc_numbers
view.camarilla.validate.ohlc_positive
view.camarilla.validate.session_missing
```

### `view.boards.*` — 8 missing
```
view.boards.hint.no_news
view.boards.prompt.limit
view.boards.prompt.name
view.boards.prompt.note_text
view.boards.prompt.symbol
view.boards.tile.composite
view.boards.tile.fear_greed
view.boards.tile.vix
```

### `view.block_bootstrap.*` — 8 missing
```
view.block_bootstrap.validate.block_size
view.block_bootstrap.validate.data_array
view.block_bootstrap.validate.data_finite
view.block_bootstrap.validate.data_min
view.block_bootstrap.validate.resamples_int
view.block_bootstrap.validate.resamples_range
view.block_bootstrap.validate.seed
view.block_bootstrap.validate.statistic
```

### `view.beta_shrink.*` — 8 missing
```
view.beta_shrink.validate.asset_missing
view.beta_shrink.validate.assets_array
view.beta_shrink.validate.assets_empty
view.beta_shrink.validate.market_array
view.beta_shrink.validate.market_finite
view.beta_shrink.validate.market_min
view.beta_shrink.validate.returns_array
view.beta_shrink.validate.symbol_missing
```

### `view.atr_trail_stop.*` — 8 missing
```
view.atr_trail_stop.validate.bar_finite
view.atr_trail_stop.validate.bars_array
view.atr_trail_stop.validate.bars_min
view.atr_trail_stop.validate.close_outside
view.atr_trail_stop.validate.high_lt_low
view.atr_trail_stop.validate.multiplier
view.atr_trail_stop.validate.period_int
view.atr_trail_stop.validate.period_range
```

### `view.aroon.*` — 8 missing
```
view.aroon.parse.expected_high_low
view.aroon.validate.bar_high_finite
view.aroon.validate.bar_high_low
view.aroon.validate.bar_low_finite
view.aroon.validate.bar_object
view.aroon.validate.bars_array
view.aroon.validate.period_int
view.aroon.validate.period_min
```

### `view.alphatrend.*` — 8 missing
```
view.alphatrend.validate.bar_finite
view.alphatrend.validate.bars_array
view.alphatrend.validate.bars_min
view.alphatrend.validate.close_outside
view.alphatrend.validate.high_lt_low
view.alphatrend.validate.multiplier
view.alphatrend.validate.period_int
view.alphatrend.validate.period_range
```

### `view.weighted_midprice.*` — 7 missing
```
view.weighted_midprice.parse.expected_4_tokens
view.weighted_midprice.series.dev
view.weighted_midprice.series.imbalance
view.weighted_midprice.validate.field_finite
view.weighted_midprice.validate.quote_object
view.weighted_midprice.validate.quotes_array
view.weighted_midprice.validate.quotes_empty
```

### `view.volume_at_price.*` — 7 missing
```
view.volume_at_price.validate.bar_finite
view.volume_at_price.validate.bar_object
view.volume_at_price.validate.bars_array
view.volume_at_price.validate.high_ge_low
view.volume_at_price.validate.num_bins
view.volume_at_price.validate.va_pct
view.volume_at_price.validate.vol_negative
```

### `view.vol_smile.*` — 7 missing
```
view.vol_smile.parse.expected_strike_iv
view.vol_smile.parse.input_not_string
view.vol_smile.validate.expiry
view.vol_smile.validate.iv
view.vol_smile.validate.rows_min
view.vol_smile.validate.spot
view.vol_smile.validate.strike
```

### `view.s1231.*` — 7 missing
```
view.s1231.lb.excess_LTCG
view.s1231.prop.NOT_capital
view.s1231.prop.NOT_government
view.s1231.prop.NOT_inventory
view.s1231.prop.NOT_supplies
view.s1231.spec.s_corp_BIG
view.s1231.tbl.remaining_LTCG
```

### `view.round_levels.*` — 7 missing
```
view.round_levels.validate.atr
view.round_levels.validate.config_required
view.round_levels.validate.min_weight
view.round_levels.validate.price_finite
view.round_levels.validate.price_positive
view.round_levels.validate.window_finite
view.round_levels.validate.window_positive
```

### `view.risk_parity_solver.*` — 7 missing
```
view.risk_parity_solver.parse.non_finite_cell
view.risk_parity_solver.validate.assets_min
view.risk_parity_solver.validate.cov_array
view.risk_parity_solver.validate.cov_finite
view.risk_parity_solver.validate.cov_square
view.risk_parity_solver.validate.max_iter
view.risk_parity_solver.validate.tolerance
```

### `view.range_expansion.*` — 7 missing
```
view.range_expansion.empty.events
view.range_expansion.validate.atr_length
view.range_expansion.validate.bars_min
view.range_expansion.validate.compression_lt_expansion
view.range_expansion.validate.lookback
view.range_expansion.validate.min_expansion
view.range_expansion.validate.prior_atr_max
```

### `view.murrey_math.*` — 7 missing
```
view.murrey_math.empty.levels
view.murrey_math.pos.above_octave
view.murrey_math.pos.below_octave
view.murrey_math.pos.lower_half
view.murrey_math.pos.upper_half
view.murrey_math.validate.bars_empty
view.murrey_math.validate.lookback
```

### `view.hurst.*` — 7 missing
```
view.hurst.empty.not_enough_points
view.hurst.row.distance_from_half
view.hurst.validate.chunk_exceeds
view.hurst.validate.chunk_int
view.hurst.validate.need_chunks
view.hurst.validate.need_returns
view.hurst.validate.non_finite
```

### `view.fx_option.*` — 7 missing
```
view.fx_option.series.backend
view.fx_option.series.gk_local
view.fx_option.series.spot
view.fx_option.validate.field_finite
view.fx_option.validate.field_positive
view.fx_option.validate.kind
view.fx_option.validate.sigma
```

### `view.expenses.*` — 7 missing
```
view.expenses.alert.invalid_kind
view.expenses.bucket.
view.expenses.cat.
view.expenses.col.category
view.expenses.col.merchant
view.expenses.receipt.engine.
view.expenses.summary.uncategorized
```

### `view.daily_loss_limit.*` — 7 missing
```
view.daily_loss_limit.bar.of_binding_limit
view.daily_loss_limit.validate.equity
view.daily_loss_limit.validate.max_dollars
view.daily_loss_limit.validate.max_pct
view.daily_loss_limit.validate.threshold_order
view.daily_loss_limit.validate.threshold_range
view.daily_loss_limit.validate.today_pnl
```

### `view.cusum.*` — 7 missing
```
view.cusum.empty.events
view.cusum.validate.ref_mean
view.cusum.validate.ref_stdev
view.cusum.validate.series_finite
view.cusum.validate.series_min
view.cusum.validate.slack
view.cusum.validate.threshold
```

### `view.buying_power.*` — 7 missing
```
view.buying_power.validate.account_type
view.buying_power.validate.equity_finite
view.buying_power.validate.equity_positive
view.buying_power.validate.is_day_trade
view.buying_power.validate.is_pdt
view.buying_power.validate.share_price_finite
view.buying_power.validate.share_price_positive
```

### `view.bg.*` — 7 missing
```
view.bg.validate.lag_range
view.bg.validate.length_mismatch
view.bg.validate.min_pairs
view.bg.validate.x_array
view.bg.validate.x_finite
view.bg.validate.y_array
view.bg.validate.y_finite
```

### `view.balance_of_power.*` — 7 missing
```
view.balance_of_power.parse.expected_ohlc
view.balance_of_power.validate.bar_field_finite
view.balance_of_power.validate.bar_high_low
view.balance_of_power.validate.bar_object
view.balance_of_power.validate.bars_array
view.balance_of_power.validate.smoothing_int
view.balance_of_power.validate.smoothing_min
```

### `view.anchored_momentum.*` — 7 missing
```
view.anchored_momentum.validate.anchor_int
view.anchored_momentum.validate.anchor_lt_len
view.anchored_momentum.validate.anchor_min
view.anchored_momentum.validate.close_number
view.anchored_momentum.validate.closes_array
view.anchored_momentum.validate.smooth_int
view.anchored_momentum.validate.smooth_min
```

### `view.alma.*` — 7 missing
```
view.alma.validate.close_finite
view.alma.validate.closes_array
view.alma.validate.closes_min
view.alma.validate.offset
view.alma.validate.period_int
view.alma.validate.period_range
view.alma.validate.sigma
```

### `view.active_share.*` — 7 missing
```
view.active_share.parse.expected_3_tokens
view.active_share.validate.weight_benchmark
view.active_share.validate.weight_object
view.active_share.validate.weight_portfolio
view.active_share.validate.weight_symbol
view.active_share.validate.weights_array
view.active_share.validate.weights_non_empty
```

### `view.tax_workshop.*` — 6 missing
```
view.tax_workshop.empty.scan
view.tax_workshop.empty.subs
view.tax_workshop.empty.trips
view.tax_workshop.error
view.tax_workshop.error.no_trips
view.tax_workshop.hint.scanning
```

### `view.per_symbol_slippage.*` — 6 missing
```
view.per_symbol_slippage.empty.symbols
view.per_symbol_slippage.grade.excellent
view.per_symbol_slippage.grade.good
view.per_symbol_slippage.grade.neutral
view.per_symbol_slippage.grade.poor
view.per_symbol_slippage.grade.terrible
```

### `view.order_flow.*` — 6 missing
```
view.order_flow.series.cum_buy
view.order_flow.series.cum_sell
view.order_flow.series.net
view.order_flow.side.buy
view.order_flow.side.sell
view.order_flow.side.uncertain
```

### `view.order_book_imbalance.*` — 6 missing
```
view.order_book_imbalance.empty.levels
view.order_book_imbalance.validate.ask_empty
view.order_book_imbalance.validate.ask_finite
view.order_book_imbalance.validate.bid_empty
view.order_book_imbalance.validate.bid_finite
view.order_book_imbalance.validate.levels
```

### `view.margin_call.*` — 6 missing
```
view.margin_call.validate.debt_finite
view.margin_call.validate.debt_negative
view.margin_call.validate.lmv_finite
view.margin_call.validate.lmv_negative
view.margin_call.validate.maint_finite
view.margin_call.validate.maint_range
```

### `view.kagi_chart.*` — 6 missing
```
view.kagi_chart.validate.closes_array
view.kagi_chart.validate.closes_finite
view.kagi_chart.validate.closes_positive
view.kagi_chart.validate.kind
view.kagi_chart.validate.reversal_finite
view.kagi_chart.validate.reversal_positive
```

### `view.ha_reversal.*` — 6 missing
```
view.ha_reversal.empty.events
view.ha_reversal.validate.bars_min
view.ha_reversal.validate.min_body_ratio
view.ha_reversal.validate.strong_streak
view.ha_reversal.validate.weak_le_strong
view.ha_reversal.validate.weak_streak
```

### `view.exports.*` — 6 missing
```
view.exports.row.open_lots
view.exports.row.open_lots_desc
view.exports.row.realized
view.exports.row.realized_desc
view.exports.row.tax_package
view.exports.row.tax_package_desc
```

### `view.equity_forecast.*` — 6 missing
```
view.equity_forecast.chart.starting
view.equity_forecast.hint.intro
view.equity_forecast.legend.band_50
view.equity_forecast.legend.band_90
view.equity_forecast.legend.mean
view.equity_forecast.legend.median
```

### `view.drawdown_throttle.*` — 6 missing
```
view.drawdown_throttle.validate.equity_positive
view.drawdown_throttle.validate.need_equity
view.drawdown_throttle.validate.need_tier
view.drawdown_throttle.validate.tier_min_dd
view.drawdown_throttle.validate.tier_multiplier
view.drawdown_throttle.validate.tiers_sorted
```

### `view.cholesky.*` — 6 missing
```
view.cholesky.parse.matrix_square
view.cholesky.validate.cell_finite
view.cholesky.validate.matrix_array
view.cholesky.validate.row_array
view.cholesky.validate.row_length
view.cholesky.validate.size_range
```

### `view.chandelier_stop.*` — 6 missing
```
view.chandelier_stop.validate.atr_length
view.chandelier_stop.validate.atr_multiplier
view.chandelier_stop.validate.bars_lt_lookback
view.chandelier_stop.validate.lookback
view.chandelier_stop.validate.need_bar
view.chandelier_stop.validate.side
```

### `view.bp.*` — 6 missing
```
view.bp.validate.length_mismatch
view.bp.validate.min_pairs
view.bp.validate.x_array
view.bp.validate.x_finite
view.bp.validate.y_array
view.bp.validate.y_finite
```

### `view.bootstrap_pnl.*` — 6 missing
```
view.bootstrap_pnl.validate.pnls_array
view.bootstrap_pnl.validate.pnls_finite
view.bootstrap_pnl.validate.resamples_int
view.bootstrap_pnl.validate.resamples_min
view.bootstrap_pnl.validate.seed
view.bootstrap_pnl.validate.trades_min
```

### `view.acf.*` — 6 missing
```
view.acf.validate.max_lag_int
view.acf.validate.max_lag_lt_len
view.acf.validate.max_lag_min
view.acf.validate.series_array
view.acf.validate.series_finite
view.acf.validate.series_min
```

### `view.s318.*` — 5 missing
```
view.s318.fam.NOT_grandparents
view.s318.fam.NOT_in_laws
view.s318.fam.NOT_siblings
view.s318.fam.NOT_step
view.s318.reat.entity_to_entity_OK
```

### `view.regime_detector.*` — 5 missing
```
view.regime_detector.row.high_vol_bars
view.regime_detector.row.log_likelihood
view.regime_detector.validate.flat
view.regime_detector.validate.need_30
view.regime_detector.validate.non_finite
```

### `view.news_event.*` — 5 missing
```
view.news_event.empty.actions
view.news_event.hint.event_format
view.news_event.hint.position_format
view.news_event.validate.events_array
view.news_event.validate.positions_empty
```

### `view.margin_runway.*` — 5 missing
```
view.margin_runway.validate.equity_finite
view.margin_runway.validate.maint_finite
view.margin_runway.validate.maint_range
view.margin_runway.validate.position_finite
view.margin_runway.validate.position_negative
```

### `view.futures_roll.*` — 5 missing
```
view.futures_roll.parse.contracts_non_zero
view.futures_roll.parse.expiration_iso
view.futures_roll.validate.positions_array
view.futures_roll.validate.roll_window
view.futures_roll.validate.today_iso
```

### `view.forward_vol.*` — 5 missing
```
view.forward_vol.parse.expected_tenor_iv
view.forward_vol.validate.ivs_non_negative
view.forward_vol.validate.rows_min
view.forward_vol.validate.tenors_increasing
view.forward_vol.validate.tenors_positive
```

### `view.dtw.*` — 5 missing
```
view.dtw.validate.a_min
view.dtw.validate.a_non_finite
view.dtw.validate.b_min
view.dtw.validate.b_non_finite
view.dtw.validate.band_radius
```

### `view.dividend_calendar.*` — 5 missing
```
view.dividend_calendar.card.in_horizon
view.dividend_calendar.empty.no_upcoming
view.dividend_calendar.error.watchlist_load
view.dividend_calendar.hint.fetching
view.dividend_calendar.horizon.all_upcoming
```

### `view.cti.*` — 5 missing
```
view.cti.validate.close_finite
view.cti.validate.closes_array
view.cti.validate.closes_min
view.cti.validate.period_int
view.cti.validate.period_range
```

### `view.borrow_rate.*` — 5 missing
```
view.borrow_rate.validate.period_range
view.borrow_rate.validate.rate_finite
view.borrow_rate.validate.rate_negative
view.borrow_rate.validate.rates_array
view.borrow_rate.validate.rates_min
```

### `view.atr_cone.*` — 5 missing
```
view.atr_cone.validate.atr_finite
view.atr_cone.validate.atr_non_negative
view.atr_cone.validate.entry_finite
view.atr_cone.validate.entry_positive
view.atr_cone.validate.horizon
```

### `view.arch_lm.*` — 5 missing
```
view.arch_lm.validate.lags_int
view.arch_lm.validate.lags_range
view.arch_lm.validate.return_finite
view.arch_lm.validate.returns_array
view.arch_lm.validate.returns_min
```

### `view.adl.*` — 5 missing
```
view.adl.validate.bar_missing
view.adl.validate.bars_array
view.adl.validate.bars_empty
view.adl.validate.high_lt_low
view.adl.validate.hlcv_numbers
```

### `view.adf_test.*` — 5 missing
```
view.adf_test.validate.lags_int
view.adf_test.validate.lags_negative
view.adf_test.validate.series_array
view.adf_test.validate.series_finite
view.adf_test.validate.series_min
```

### `common.ago.*` — 5 missing
```
common.ago.bars_paren
common.ago.d
common.ago.h
common.ago.m
common.ago.s
```

### `view.vpin.*` — 4 missing
```
view.vpin.hint.chart
view.vpin.hint.toxic
view.vpin.series.bucket_num
view.vpin.series.toxic_threshold
```

### `view.vol_surface.*` — 4 missing
```
view.vol_surface.empty
view.vol_surface.hint.fetching
view.vol_surface.hint.intro
view.vol_surface.range
```

### `view.three_line_break.*` — 4 missing
```
view.three_line_break.validate.close_finite
view.three_line_break.validate.closes_array
view.three_line_break.validate.num_lines_int
view.three_line_break.validate.num_lines_min
```

### `view.three_bar_reversal.*` — 4 missing
```
view.three_bar_reversal.empty.events
view.three_bar_reversal.series.bearish
view.three_bar_reversal.series.bullish
view.three_bar_reversal.validate.need_bars
```

### `view.roll_spread.*` — 4 missing
```
view.roll_spread.validate.price_type
view.roll_spread.validate.prices_array
view.roll_spread.validate.window_int
view.roll_spread.validate.window_min
```

### `view.matrix_profile.*` — 4 missing
```
view.matrix_profile.validate.m
view.matrix_profile.validate.series_empty
view.matrix_profile.validate.series_finite
view.matrix_profile.validate.series_min
```

### `view.market_profile.*` — 4 missing
```
view.market_profile.empty.levels
view.market_profile.hint.format
view.market_profile.validate.brackets_empty
view.market_profile.validate.tick_size
```

### `view.heatmap_dow_hour.*` — 4 missing
```
view.heatmap_dow_hour.cell.title
view.heatmap_dow_hour.parse.date_iso
view.heatmap_dow_hour.parse.hour_range
view.heatmap_dow_hour.parse.net_pnl_finite
```

### `view.fill_quality.*` — 4 missing
```
view.fill_quality.hint.intro
view.fill_quality.panel.by_hour
view.fill_quality.panel.by_size
view.fill_quality.panel.by_symbol
```

### `view.demarker.*` — 4 missing
```
view.demarker.empty.crossings
view.demarker.validate.bars_empty
view.demarker.validate.bars_min
view.demarker.validate.period_min
```

### `view.cov_denoiser.*` — 4 missing
```
view.cov_denoiser.error.null
view.cov_denoiser.hint.vs_original
view.cov_denoiser.validate.num_obs
view.cov_denoiser.validate.t_ge_n
```

### `view.charts.*` — 4 missing
```
view.charts.label.color
view.charts.label.indicators
view.charts.label.tool
view.charts.prompt.text
```

### `view.carry_score.*` — 4 missing
```
view.carry_score.validate.funding_rate
view.carry_score.validate.long_rate
view.carry_score.validate.vol_finite
view.carry_score.validate.vol_positive
```

### `view.bocpd.*` — 4 missing
```
view.bocpd.card.change_points_above_threshold
view.bocpd.validate.hazard
view.bocpd.validate.need_30
view.bocpd.validate.non_finite
```

### `view.webhooks.*` — 3 missing
```
view.webhooks.alert.test_fired
view.webhooks.hint.intro
view.webhooks.placeholder.secret
```

### `view.wash_sale.*` — 3 missing
```
view.wash_sale.parse.numeric_tokens_finite
view.wash_sale.validate.closings_array
view.wash_sale.validate.openings_array
```

### `view.trade_reviews.*` — 3 missing
```
view.trade_reviews.h2.needs_review
view.trade_reviews.h2.recent_reviews
view.trade_reviews.h2.review
```

### `view.squeeze_alerts.*` — 3 missing
```
view.squeeze_alerts.empty.events
view.squeeze_alerts.hint.adv
view.squeeze_alerts.hint.ticks
```

### `view.sector_rotation.*` — 3 missing
```
view.sector_rotation.h2.heatmap
view.sector_rotation.hint.computed
view.sector_rotation.hint.intro
```

### `view.s481.*` — 3 missing
```
view.s481.ex.s263A_safe_harbor
view.s481.rel.s263A
view.s481.rel.s263A_simplified
```

### `view.s421.*` — 3 missing
```
view.s421.iso.excess_NSO
view.s421.iso.qualifying_LTCG
view.s421.rep.1099B
```

### `view.rebalance.*` — 3 missing
```
view.rebalance.error.form_gone
view.rebalance.error.targets_array
view.rebalance.error.targets_json
```

### `view.premarket.*` — 3 missing
```
view.premarket.hint.none_today
view.premarket.hint.updated
view.premarket.tile.atr20
```

### `view.disclosures.*` — 3 missing
```
view.disclosures.kind.house_stock
view.disclosures.kind.insider_form4
view.disclosures.kind.senate_stock
```

### `view.currency_exposure.*` — 3 missing
```
view.currency_exposure.parse.currency_alpha
view.currency_exposure.parse.notional_finite
view.currency_exposure.parse.rate_positive
```

### `view.compare.*` — 3 missing
```
view.compare.hint.fetched
view.compare.hint.too_few
view.compare.svg.x_axis
```

### `view.cohort_tilt.*` — 3 missing
```
view.cohort_tilt.empty.symbols
view.cohort_tilt.parse.net_contracts_int
view.cohort_tilt.validate.positions_empty
```

### `view.bipower_variation.*` — 3 missing
```
view.bipower_variation.validate.returns_array
view.bipower_variation.validate.returns_finite
view.bipower_variation.validate.returns_min
```

### `view.api_tokens.*` — 3 missing
```
view.api_tokens.hint.intro
view.api_tokens.stored_as
view.api_tokens.warn.save_now
```

### `view.alligator.*` — 3 missing
```
view.alligator.empty.mouth
view.alligator.empty.points
view.alligator.validate.need_bars
```

### `view.ad_normality.*` — 3 missing
```
view.ad_normality.validate.sample_array
view.ad_normality.validate.sample_finite
view.ad_normality.validate.sample_min
```

### `common.validate.*` — 3 missing
```
common.validate.field_must_be_finite
common.validate.field_must_be_non_neg
common.validate.must_be_array
```

### `common.error.*` — 3 missing
```
common.error.api
common.error.backend
common.error.parse_errors
```

