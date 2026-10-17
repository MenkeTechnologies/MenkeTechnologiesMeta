# GUI Script Actions — Global Catalog

Every scriptable **GUI-Script action** (automation-bus verb) exposed by every MenkeTechnologies
GUI app — the exact surface `App::open("<app>")->verbs()` returns over the
[GUI Automation Bus](GUI_AUTOMATION_BUS.md): the LIVE runtime surface (appShell verbs +
per-app `opts.commands` + dynamically-registered verbs), read from each running app.

**6677 actions** across **17 apps**. Read from each app's live bus
surface by `bin/gen-gui-actions-live` — do not hand-edit. Requires every app open when generated.

| App | Verbs | Surface |
| --- |:--:| --- |
| [`traderview`](#traderview) | 1753 | TradingView-style charting/trading terminal — view tiles + shortcut actions |
| [`zphoto`](#zphoto) | 706 | Photoshop + Illustrator-style raster & vector editor — layers, filters, paths, actions |
| [`zmax-gui`](#zmax-gui) | 632 |  |
| [`zpdf`](#zpdf) | 370 | Acrobat/Preview-style PDF engine — render, edit, annotate, forms, OCR, redact |
| [`zcontainer`](#zcontainer) | 350 | Docker Desktop + Lens-style container / Kubernetes manager |
| [`zemail`](#zemail) | 313 | Thunderbird-style mail client — accounts, folders, messages, PGP/S-MIME, search |
| [`zcite`](#zcite) | 309 | Zotero-style reference manager — library, collections, citations, PDF, sync |
| [`zreq`](#zreq) | 288 | Postman-style API client — requests, collections, auth, codegen, gRPC/WebSocket |
| [`audio-haxor`](#audio-haxor) | 287 | Audio analyzer / DAW-project generator — spectrum, DSP, .als generation |
| [`ztunnel`](#ztunnel) | 260 | Tunnelblick-style VPN client — OpenVPN / WireGuard config + control |
| [`zstation`](#zstation) | 251 | Station-style multi-app workspace — boards, tiles, panes |
| [`zwire`](#zwire) | 247 | Chromium-superset browser — tabs, windows, tab-groups, downloads, reading list, power |
| [`ztranslator`](#ztranslator) | 242 | BOME-style MIDI/keyboard translator — presets, translators, rules, HID |
| [`zftp`](#zftp) | 224 | Cyberduck-style transfer client — FTP/SFTP/WebDAV/S3/cloud, transfers, sync |
| [`zgo`](#zgo) | 164 | Alfred-style launcher — script-filter workflows and system commands |
| [`zthrottle`](#zthrottle) | 149 | System monitor / process & network throttling |
| [`zoffice`](#zoffice) | 132 | LibreOffice-style office engine — writer/calc/impress over ODF/OOXML |

---

## traderview

TradingView-style charting/trading terminal — view tiles + shortcut actions  
**1753 verbs** · live bus surface · call as `App::open("traderview")->call("<verb>", %args)`

**`(top-level)`** (1736)

```
action:abc_pattern_run
action:absorption_run
action:accounts_focus_name
action:accounts_overview_refresh
action:acf_run
action:active_share_run
action:activity_heatmap
action:ad_normality_run
action:ad_oscillator_run
action:add_bookmark
action:adf_test_run
action:adl_run
action:ai_save
action:alert_rules_focus_new
action:alligator_demo
action:alligator_run
action:alma_run
action:almgren_chriss_frontier
action:almgren_chriss_run
action:alphatrend_run
action:american_option_price
action:amihud_run
action:anchored_momentum_run
action:arch_lm_run
action:aroon_run
action:asi_run
action:atr_channel_run
action:atr_cone_run
action:atr_trailing_stop_run
action:backtest_presets_focus_name
action:backtest_run
action:balance_of_power_run
action:bartlett_run
action:bb_osc_run
action:bb_pb_run
action:bbd_run
action:bbw_run
action:bbwp_run
action:beta_run
action:beta_shrink_run
action:bg_test_run
action:bid_ask_vol_run
action:bipower_variation_run
action:black_litterman_run
action:block_bootstrap_run
action:boards_focus_name
action:bocpd_detect
action:bollinger_squeeze_run
action:bond_duration_build
action:bond_duration_run
action:bootstrap_pnl_run
action:borrow_rate_run
action:bp_test_run
action:breadth_refresh
action:breadth_thrust_run
action:buying_power_run
action:carry_score_run
action:chandelier_stop_demo
action:chandelier_stop_run
action:charts_refresh
action:choppiness_run
action:clear_recents
action:clusters_correlation_run
action:clusters_trade_features_run
action:cohort_tilt_run
action:command_palette
action:commission_optimizer_run
action:community_focus_title
action:copy_symbol
action:copy_view_id
action:copy_view_url
action:cost_basis_opt
action:cost_basis_run
action:cov_denoiser_run
action:csv_wizard_upload
action:cup_and_handle_demo
action:cup_and_handle_detect
action:currency_exposure_run
action:cusum_autofit
action:cusum_detect
action:cycle_locale
action:cypher_pattern_demo
action:cypher_pattern_run
action:daily_loss_limit_run
action:darkpool_rank
action:dashboard_refresh
action:dashboards_focus_new
action:dashboards_toggle_edit
action:deflated_sharpe_compute
action:deflated_sharpe_sweep
action:demark_pivots_run
action:demarker_demo
action:demarker_run
action:developer_focus_name
action:developer_generate
action:discipline_refresh
action:dividend_calendar_run
action:drawdown_throttle_run
action:dtw_warp
action:earnings_cal_poll
action:earnings_cal_refresh
action:economy_load
action:edit_copy
action:edit_cut
action:edit_paste
action:edit_redo
action:edit_select_all
action:edit_undo
action:effective_spread_run
action:escape
action:execution_scheduler_run
action:export_view
action:focus_search
action:footprint_demo
action:footprint_run
action:forecast_run
action:forward_vol_run
action:futures_roll_run
action:fx_option_price
action:go_home
action:goal_tracker_run
action:goals_focus_name
action:greeks_profile_compute
action:ha_reversal_demo
action:ha_reversal_run
action:hawkes_run
action:heatmap_dow_hour_run
action:help
action:herfindahl_run
action:hotkeys_capture
action:hotkeys_focus_name
action:hurst_estimate
action:implementation_shortfall_run
action:import_pick_file
action:import_upload
action:intraday_heatmap_build
action:intraday_heatmap_demo
action:iv_backtest_demo
action:iv_backtest_run
action:iv_rank_compute
action:iv_rank_demo
action:iv_solver_solve
action:journal_focus_body
action:journal_refresh
action:journal_save
action:kagi_run
action:kalman_beta_run
action:kelly_compute_dynamic
action:kelly_compute_static
action:kyles_lambda_run
action:liquidity_analyze
action:liquidity_demo
action:live_refresh
action:live_scanner_connect
action:live_scanner_toggle_voice
action:margin_call_run
action:margin_runway_run
action:marginal_var_run
action:market_impact_analyze
action:market_impact_demo
action:market_profile_demo
action:market_profile_run
action:mc_trades_run
action:microprice_compute
action:momentum_crash_run
action:monte_carlo_run
action:mood_refresh
action:murrey_math_demo
action:murrey_math_run
action:nav_accounts
action:nav_after_hours
action:nav_back
action:nav_budget
action:nav_calendar
action:nav_catalysts
action:nav_categorize
action:nav_charts
action:nav_dashboard
action:nav_dashboards
action:nav_expenses
action:nav_file_taxes
action:nav_goals
action:nav_halts
action:nav_journal
action:nav_live
action:nav_note_templates
action:nav_purchases
action:nav_receipts
action:nav_reports
action:nav_reviews
action:nav_risk_gate
action:nav_scanner
action:nav_search
action:nav_tags
action:nav_trades
action:nav_watchlists
action:nav_webull
action:new_trade_add
action:obi_compute
action:open_charts_for_symbol
action:open_earnings_for_symbol
action:open_new_tab
action:open_news_for_symbol
action:open_options_for_symbol
action:open_research_for_symbol
action:open_scheduler
action:open_settings
action:open_type_run
action:optimal_f_compute
action:option_payoff_recalc
action:order_flow_classify
action:order_flow_demo
action:order_staleness_demo
action:order_staleness_evaluate
action:pair_trade_analyze
action:paper_submit
action:pattern_discovery_run
action:per_symbol_slippage_demo
action:per_symbol_slippage_run
action:portfolio_allocator_run
action:pyramid_run
action:range_bar_run
action:range_expansion_demo
action:range_expansion_run
action:rebalance_compute
action:rebalance_focus_targets
action:regime_detector_run
action:regime_equity_run
action:reload
action:replay_refresh
action:research_action
action:risk_on_off_run
action:risk_parity_run
action:risk_parity_solver_run
action:risk_reward_run
action:risk_save
action:roll_spread_run
action:round_levels_run
action:rr_butterfly_run
action:screener_run
action:second_order_greeks_run
action:series_smoother_run
action:setups_by_setup_run
action:show_cheatsheet
action:signal_decomposition_run
action:spread_tracker_demo
action:spread_tracker_run
action:start_tour
action:stop_loss_backtest_run
action:strategy_alerts_evaluate_now
action:strategy_alerts_focus_name
action:stress_test_demo
action:stress_test_run
action:tax_loss_harvest_run
action:three_bar_reversal_demo
action:three_bar_reversal_run
action:three_line_break_run
action:tick_bar_run
action:time_in_force_run
action:time_in_force_snap_now
action:toggle_crt
action:toggle_favorite
action:toggle_neon
action:toggle_theme
action:top_signals_refresh
action:trade_plan_checklist_run
action:trades_new
action:trades_refresh
action:triple_screen_run
action:var_calculator_compute
action:var_estimator_run
action:vasicek_simulate
action:vix_term_structure_run
action:vol_smile_fit
action:vol_stop_close_run
action:volume_at_price_run
action:volume_bar_run
action:vpin_compute
action:vpin_demo
action:vwap_slippage_analyze
action:vwap_slippage_demo
action:wash_sale_run
action:watchlists_focus_add
action:watchlists_refresh
action:webull_refresh
action:weighted_midprice_run
action:yield_curve_pca_run
action:yield_curve_run
view:529-roth
view:abc-inventory-analysis
view:abc-pattern
view:able-account
view:about
view:absorption
view:absorption-ratio
view:accountable-plan
view:accounting-rate-of-return
view:accounts
view:accounts-overview
view:accrual-ratio
view:accrued-interest
view:acf
view:acquirers-multiple
view:active-share
view:activity-based-costing
view:ad-normality
view:ad-oscillator
view:additional-medicare-tax
view:adf-test
view:adjusted-sharpe-ratio
view:adl
view:after-hours
view:after-repair-value
view:after-tax-cash-flow
view:after-tax-return
view:age-allocation
view:ai
view:alert-rules
view:alerts
view:algo
view:alligator
view:allowance-doubtful
view:alma
view:almgren-chriss
view:alphatrend
view:altman-z-double-prime
view:altman-z-score
view:american-option
view:amihud
view:amt-calc
view:anchored-momentum
view:annuity-pv-fv
view:appraisal-ratio
view:apr-apy
view:arch-lm
view:arms-index-trin
view:aroon
view:arpu
view:asi
view:asset-coverage-ratio
view:asset-disposal
view:atr-channel
view:atr-cone
view:atr-position-size
view:atr-stop
view:atr-trailing-stop
view:augusta-rule
view:auto-loan
view:average-correlation
view:average-daily-range
view:average-order-value
view:backdoor-roth
view:backlog-coverage
view:backtest
view:backtest-presets
view:backup-withholding
view:balance-of-power
view:balloon-payment
view:band-of-investment
view:bank-reconciliation
view:barista-fire
view:bartlett-variance
view:batting-average
view:bb-squeeze
view:beneish-m-score
view:beta
view:beta-shrinkage
view:bid-ask-volume-ratio
view:bill-calendar
view:bill-of-sale
view:billable-utilization
view:bipower-variation
view:biz-categorizer
view:black-litterman
view:blended-debt
view:block-bootstrap
view:board-resolution
view:boards
view:bocpd
view:bollinger-band-distance
view:bollinger-band-width
view:bollinger-bandwidth-percentile
view:bollinger-oscillators
view:bollinger-percent-b
view:bond-amortization
view:bond-convexity
view:bond-dirty-price
view:bond-duration
view:bond-equivalent-yield
view:bond-ladder
view:bond-market
view:bond-pricing
view:bond-roll-down
view:bond-tent
view:bond-yield-curve
view:bonus-grossup
view:book-to-bill
view:book-value
view:book-value-per-share
view:bootstrap-pnl
view:borrow-rate-indicator
view:box-spread
view:breadth
view:breadth-divergence
view:breadth-thrust
view:break-even
view:break-even-ratio
view:break-even-roas
view:break-premium
view:breakeven-after-costs
view:breakeven-occupancy
view:breakeven-rent
view:breakeven-win-rate
view:breusch-godfrey
view:breusch-pagan
view:brier-score
view:brinson
view:broker-compare
view:brokers
view:brrrr
view:budget
view:budget-variance
view:buffett-indicator
view:bundle-discount
view:burke-ratio
view:burn-multiple
view:burn-rate
view:business-compare
view:businesses
view:butterfly-spread
view:buyback-yield
view:buying-power
view:cac-payback-months
view:calendar
view:calendar-spread
view:callable-oas
view:cam-reconciliation
view:camarilla-pivots
view:candle-strength-index
view:cap-rate-spread
view:cap-table
view:capacity-utilization
view:cape-indicator
view:cape-valuation
view:capex-per-unit
view:capex-to-sales
view:capital-gains-tax
view:capital-intensity
view:capital-loss-carryover
view:capitalization-ratio
view:capm
view:capture-ratio
view:car-affordability
view:car-tco
view:carhart-4
view:carry-score
view:carry-trade-return
view:cash-adjusted-pe
view:cash-break-even
view:cash-conversion-cycle
view:cash-conversion-efficiency
view:cash-conversion-ratio
view:cash-discount-apr
view:cash-flow-adequacy
view:cash-flow-coverage
view:cash-flow-forecast
view:cash-flow-margin
view:cash-flow-per-door
view:cash-flow-statement
view:cash-flow-to-capex
view:cash-on-cash-return
view:cash-out-refinance
view:cash-return-on-assets
view:catalyst-correlations
view:catalysts
view:categorize
view:cd-ladder
view:cd-penalty
view:cdar
view:cease-desist
view:centered-smoothed-momentum
view:cfroi
view:chaikin-oscillator
view:chande-dynamic-momentum
view:chande-kroll-stop
view:chande-momentum-oscillator
view:chande-trend-index
view:chande-volatility-index
view:chandelier-exit
view:chandelier-stop
view:charitable-planner
view:charts
view:cholesky
view:choppiness
view:chowder-number
view:churn-rate
view:clean-energy-25d
view:closing-cost-estimate
view:closing-statement
view:clusters-correlation
view:clusters-trade-features
view:coast-fire
view:cohort-tilt
view:collar
view:college-529
view:commercial-lease
view:commission-agreement
view:commission-optimizer
view:commodities
view:common-sense-ratio
view:community
view:compare
view:compound-interest
view:conditional-sharpe
view:confluence
view:confluence-autotrade
view:congressional-trading
view:conservation-easement
view:consumer-surplus
view:contractor-1099
view:contractor-agreement
view:contribution-margin
view:contribution-per-constraint
view:conversion-cost
view:convertible-note
view:cornish-fisher-var
view:correlation
view:cost-average-down
view:cost-basis
view:cost-of-debt-aftertax
view:cost-of-goods-manufactured
view:cost-of-hire
view:cost-of-preferred
view:cost-seg
view:cov-denoiser
view:coverdell-esa
view:covered-call
view:cpi-rent-adjustment
view:cppi-floor
view:crack-spread
view:crat
view:crate-browser
view:credit-card-payoff
view:credit-spread
view:credit-utilization
view:cross-broker-wash
view:cross-price-elasticity
view:cross-rate
view:crossover-rate
view:crut
view:crypto
view:crypto-liquidation
view:crypto-markets
view:crypto-staking
view:csv-wizard
view:cup-and-handle
view:currency-exposure
view:current-yield
view:custom-indicators
view:customer-concentration
view:cusum
view:cypher-pattern
view:d-ratio
view:daf
view:daily-loss-limit
view:darkpool
view:dashboard
view:dashboards
view:days-cash-on-hand
view:days-payable-outstanding
view:days-sales-outstanding
view:days-working-capital
view:dca-simulator
view:dcf
view:dcfsa
view:de-minimis-safe-harbor
view:debt-avalanche
view:debt-paydown-yield
view:debt-snowball
view:debt-to-assets
view:debt-to-capital
view:debt-to-ebitda
view:debt-to-equity
view:debt-to-income
view:debt-yield
view:decline-curve-arps
view:decumulation-mc
view:default-probability
view:defensive-interval-ratio
view:defined-benefit
view:deflated-sharpe
view:degree-financial-leverage
view:degree-operating-leverage
view:degree-total-leverage
view:demand-for-payment
view:demark-pivots
view:demarker
view:deposit-interest
view:deposit-to-rent
view:depreciation
view:depreciation-recapture
view:depreciation-schedule
view:developer
view:development-spread
view:disability-insurance-needs
view:disabled-access
view:discipline
view:disclosures
view:discretionary-income
view:diversification-ratio
view:dividend-aristocrats
view:dividend-calendar
view:dividend-capture
view:dividend-coverage
view:dividend-coverage-reit
view:dividend-discount-model
view:dividend-growth-rate
view:dividend-payback-period
view:dividend-payout-ratio
view:dividend-per-share
view:dividend-tracker
view:dividend-yield
view:dollar-bar
view:dollar-break-even
view:doubling-time-exact
view:down-payment-savings-time
view:downside-deviation
view:drawdown-cutoff
view:drawdown-recovery-time
view:drawdown-throttle
view:drawing-alerts
view:drip-simulator
view:dscr
view:dtw
view:dupont-roe
view:duration-gap
view:early-payment-discount
view:earnest-money-receipt
view:earnings-cal
view:earnings-call-live
view:earnings-growth-rate
view:earnings-iv
view:earnings-per-share
view:earnings-power-value
view:earnings-quality
view:earnings-revisions
view:earnings-surprise
view:earnings-yield
view:earnings-yield-spread
view:earnout
view:ebitda-coverage
view:ebitda-margin
view:economic-calendar
view:economic-production-quantity
view:economic-vacancy
view:economic-value-added
view:economy
view:education-credits
view:effective-duration
view:effective-gross-income
view:effective-gross-rent
view:effective-number-bets
view:effective-rent
view:effective-rental-rate
view:effective-spread
view:effective-tax-rate
view:efficiency-ratio-bank
view:efficient-frontier
view:emergency-fund
view:employee-writeup
view:endowment-spending
view:enterprise-value
view:envelope-budget
view:equipment-rental
view:equity-buildup
view:equity-multiple
view:equity-multiplier
view:equivalent-annual-cost
view:equivolume
view:esg
view:espp-calc
view:estate-tax
view:estimate
view:estimates-dashboard
view:etf-overlap
view:etf-profile
view:ev-credit
view:ev-ebitda
view:ev-to-ebit
view:ev-to-fcf
view:ev-to-gross-profit
view:ev-to-sales
view:ev-vs-ice
view:excess-social-security
view:execution-scheduler
view:expected-net-worth
view:expected-value-bet
view:expense-calendar
view:expense-dashboard
view:expense-drag
view:expense-recovery-ratio
view:expense-reimbursement
view:expenses
view:exports
view:fafsa-efc
view:fat-fire
view:favorites
view:fbar-8938
view:fcf-conversion
view:fcf-margin
view:fcf-per-share
view:fcf-yield
view:fcff-fcfe
view:fda-calendar
view:fear-greed
view:fed-model
view:fi-number
view:fica-tip-credit
view:fifty-percent-rule
view:fifty-thirty-twenty
view:file-browser
view:file-taxes
view:filings-browser
view:fill-quality
view:fill-rate
view:film-181
view:final-paycheck
view:financial-independence-ratio
view:financial-ratios
view:finnhub-aggregate
view:finnhub-pattern
view:finnhub-search
view:finnhub-sr
view:fire-calculator
view:first-year-withdrawal
view:fix-and-flip
view:fixed-asset-coverage
view:fixed-asset-turnover
view:fixed-charge-coverage
view:fixed-income
view:fixed-ratio-sizing
view:flexible-budget
view:flip-holding-cost
view:food-cost-percentage
view:footprint
view:forecast
view:foreign-tax-credit
view:forex
view:forex-988
view:forex-rates
view:forward-pe
view:forward-rate
view:forward-vol
view:free-cash-flow
view:freelance-rate
view:funds-from-operations
view:futures-roll
view:futures-tick-value
view:fx-option
view:gain-to-pain
view:gamma-pin-zone
view:gamma-squeeze
view:garman-klass-volatility
view:geometric-return
view:gift-card-breakage
view:gift-tax
view:gini-coefficient
view:glide-path
view:global-dscr
view:gmroi
view:goal-funding
view:goal-tracker
view:goals
view:gold-silver-ratio
view:golden-stars
view:goodwill-impairment
view:goodwill-ratio
view:graham-number
view:grat
view:greeks-profile
view:grm
view:gross-burn
view:gross-income-multiplier
view:gross-margin-return-on-labor
view:gross-margin-stability
view:gross-profit-method
view:gross-profit-per-employee
view:gross-profitability
view:gross-rent-yield
view:gross-scheduled-income
view:gross-spread
view:grover-score
view:growing-perpetuity
view:guaranty
view:guyton-klinger
view:ha-reversal
view:halts
view:hamada-equation
view:hawkes
view:heatmap
view:heatmap-dow-hour
view:heloc
view:herfindahl
view:high-low-method
view:historic-rehab
view:historical-market-cap
view:historical-volatility
view:holding-period-return
view:holdover-rent
view:home-maintenance
view:home-office
view:home-sale-exclusion
view:hotkeys
view:house-hacking
view:household-employment-tax
view:hsa-max
view:hsa-triple-tax
view:htb-ranker
view:hull-moving-average
view:human-capital
view:hurst
view:hysa-compare
view:i-bond
view:ibond-calculator
view:ilit
view:imbalance-bar
view:implementation-shortfall
view:implied-growth-rate
view:import
view:income-1099
view:income-elasticity
view:income-statement
view:income-tax-estimator
view:incremental-roic
view:index-constituents
view:inflation-calculator
view:inherited-ira-rmd
view:insider-clusters
view:insider-finnhub
view:insider-sentiment
view:insider-stream
view:inspection-checklist
view:installment-method
view:installment-sale
view:institutional-13f
view:interest-coverage
view:interest-rate-parity
view:interest-tax-shield
view:intraday-heatmap
view:inventory-carrying-cost
view:inventory-costing
view:inventory-eoq
view:inventory-shrinkage
view:inventory-to-sales
view:inventory-to-working-capital
view:inventory-turnover
view:invested-capital-turnover
view:invoice-factoring
view:invoice-generator
view:ipo-calendar
view:ipo-lockups
view:irmaa
view:iron-butterfly
view:iron-condor
view:iso-exercise
view:iv-backtest
view:iv-cone
view:iv-rank
view:iv-solver
view:iv-surface
view:iv-term
view:jensen-alpha
view:job-costing
view:journal
view:k-ratio
view:kagi
view:kalman-beta
view:kanban-card-count
view:kappa-ratio
view:kelly
view:keltner-channel
view:keyboard-shortcuts
view:kiddie-tax
view:kyles-lambda
view:labor-cost-ratio
view:land-contract
view:land-residual-value
view:landlord-notice
view:late-fee
view:lead-paint-disclosure
view:lean-fire
view:learning-curve
view:lease-assignment
view:lease-buyout
view:lease-generator
view:lease-option
view:lease-payment
view:lease-renewal
view:lease-termination
view:lease-vs-buy-car
view:leasing-commission
view:leverage
view:life-insurance-needs
view:lifestyle-inflation
view:lihtc
view:like-kind-exchange
view:liquid-net-worth
view:liquidity
view:liquidity-ratios
view:live
view:live-dashboard
view:live-feed
view:live-scanner
view:llc-operating-agreement
view:loan-apr
view:loan-constant
view:loan-sizing-dscr
view:loan-to-cost
view:loan-to-deposit-ratio
view:loan-to-value
view:lobbying
view:log-viewer
view:loss-recovery
view:loss-to-lease
view:lower-of-cost-market
view:ltcg-harvesting
view:ltv-cac
view:lump-sum-vs-dca
view:m2-measure
view:machine-hour-rate
view:macrs-depreciation
view:magic-formula
view:mail
view:maintenance-capex-ratio
view:management-fee
view:margin-analysis
view:margin-call
view:margin-call-price-short
view:margin-interest
view:margin-of-safety
view:margin-runway
view:marginal-propensity-consume
view:marginal-risk-contribution
view:marginal-var
view:market-gamma
view:market-impact
view:market-profile
view:market-status
view:market-value-added
view:markup-chain
view:markup-margin
view:marriage-penalty
view:martin-ratio
view:max-contracts-margin
view:maximum-adverse-excursion
view:mc-trades
view:meal-deduction
view:mega-backdoor-roth
view:mentorship
view:merton-default
view:microprice
view:mileage-log
view:minimum-variance-weight
view:mirr
view:mlp-k1
view:modified-dietz-return
view:momentum-crash
view:money-flow-index
view:monte-carlo
view:mood
view:mortgage-affordability
view:mortgage-amortization
view:mortgage-interest-deduction
view:mortgage-payoff-vs-invest
view:mortgage-points
view:mortgage-recast
view:mortgage-refinance
view:mtm-election
view:multi-broker
view:multi-product-breakeven
view:multichart
view:murrey-math
view:mutual-fund
view:nda
view:net-cash-per-share
view:net-charge-off
view:net-debt-ebitda
view:net-debt-to-equity
view:net-debt-to-fcf
view:net-interest-margin
view:net-net-working-capital
view:net-profit-margin
view:net-promoter-score
view:net-revenue-retention
view:net-worth-to-income
view:net-worth-tracker
view:new-trade
view:news
view:news-event
view:news-sentiment
view:niit-calculator
view:noi-growth
view:noi-per-sqft
view:nol-tracker
view:nopat-margin
view:normalized-eps
view:note-templates
view:notice-of-entry
view:notional-exposure
view:npv-irr
view:nso-exercise
view:nua-strategy
view:offer-letter
view:office
view:oi-change
view:omega-ratio
view:one-percent-rule
view:open-type
view:operating-cash-flow-ratio
view:operating-cash-flow-to-debt
view:operating-cycle
view:operating-expense-per-unit
view:operating-expense-ratio
view:operating-margin
view:opex-escalation
view:optimal-f
view:option-breakeven
view:option-grant
view:option-intrinsic-extrinsic
view:option-payoff
view:options
view:order-book-imbalance
view:order-flow
view:order-staleness
view:overhead-absorption
view:overhead-rate
view:overtime-pay
view:owner-compensation-ratio
view:owner-earnings
view:owner-earnings-yield
view:pair-trade-calc
view:pairs
view:pairs-coint
view:paper
view:paper-rebalance
view:paper-tax-loss-harvest
view:parking-income
view:parkinson-volatility
view:partial-disposition
view:passive-loss
view:pattern-day-trader
view:pattern-discovery
view:pay-stub
view:payables-turnover
view:payback-period
view:paycheck-401k
view:payoff-ratio
view:payroll-burden-rate
view:payroll-tax-employer
view:pdf
view:pead
view:peg-ratio
view:pegy-ratio
view:pension-funded-status
view:pension-lump-vs-annuity
view:pension-survivor
view:per-symbol-slippage
view:percent-complete-revenue
view:percentage-rent
view:perfect-order-rate
view:performance-summary
view:permanent-portfolio
view:perp-funding
view:perpetual-inventory
view:personal-balance-sheet
view:personal-cash-flow
view:pet-addendum
view:physical-vacancy
view:piotroski-f-score
view:pip-value
view:piti-payment
view:plans
view:plowback-ratio
view:pmi-removal
view:portfolio-allocator
view:portfolio-beta
view:portfolio-expected-return
view:portfolio-exposure
view:portfolio-heat-total
view:portfolio-longevity
view:position-heat
view:position-size-percent-risk
view:preferred-return
view:preferred-stock
view:premarket
view:prepaid-expense-amortization
view:pretax-margin
view:pretax-roa
view:price-elasticity
view:price-markdown
view:price-per-door
view:price-per-square-foot
view:price-per-unit
view:price-target
view:price-target-blend
view:price-to-book
view:price-to-cash-flow
view:price-to-ebitda
view:price-to-ffo
view:price-to-nav
view:price-to-rent
view:price-to-sales
view:price-to-tangible-book
view:prime-cost
view:probability-of-profit
view:process-costing
view:profit-factor
view:profit-first
view:profit-on-cost
view:promissory-note
view:property-tax
view:property-value-from-noi
view:prorated-rent
view:prospect-ratio
view:pslf-tracker
view:pto-balance
view:pto-policy
view:purchase-agreement
view:purchase-order
view:purchases
view:purchasing-power-erosion
view:purchasing-power-parity
view:put-call-parity
view:pyramid
view:qbi-199a
view:qcd-tracker
view:qlac
view:qoz-tracker
view:qsbs-1202
view:quarterly-tax
view:r-dist
view:r-multiple
view:rachev-ratio
view:range-bar
view:range-expansion
view:rd-credit
view:rd-intensity
view:real-dividend-growth
view:real-estate
view:real-estate-cap-rate
view:real-raise
view:real-return
view:rebalance
view:rebalancing-bands
view:receipts
view:receivables-aging
view:receivables-turnover
view:recommendation-sectors
view:regime-detector
view:regime-equity
view:reinvestment-rate
view:renovation-rent-premium
view:rent-affordability
view:rent-escalation
view:rent-growth-cagr
view:rent-increase-notice
view:rent-per-bedroom
view:rent-per-sqft
view:rent-receipt
view:rent-roll
view:rent-to-income
view:rent-vs-buy
view:rent-vs-sell
view:rental-application
view:rental-arbitrage
view:rental-noi
view:rental-payback
view:rental-rules
view:rental-total-return
view:rental-yield-on-cost
view:reorder-point
view:repeat-purchase-rate
view:replacement-cost
view:replacement-ratio
view:replacement-reserve
view:replay
view:reporting-time-pay
view:reports
view:research
view:residency-daycount
view:residual-income-model
view:retail-inventory-method
view:retainage
view:retirement-max
view:return-moments
view:return-on-assets
view:return-on-capital-employed
view:return-on-tangible-equity
view:revenue-breakdown
view:revenue-per-employee
view:revenue-per-share
view:revenue-retention
view:revenue-run-rate
view:reverse-mortgage
view:reversion-value
view:reviews
view:revpash
view:rights-offering
view:risk
view:risk-gate
view:risk-on-off
view:risk-parity
view:risk-parity-solver
view:risk-reward
view:rmd-calculator
view:roic
view:roll-spread
view:roll-yield
view:rolling-correlation
view:romi
view:roommate-agreement
view:roommate-rent-split
view:roth-bracket-fill
view:roth-contribution
view:roth-conversion-ladder
view:roth-ladder
view:roth-vs-trad-401k
view:round-levels
view:royalty
view:rr-butterfly
view:rrg
view:rsu-grant
view:rsu-vest-tracker
view:rule-of-114
view:rule-of-115
view:rule-of-16
view:rule-of-20
view:rule-of-25
view:rule-of-40
view:rule-of-69-3
view:rule-of-70
view:rule-of-72
view:rule-of-72-inverse
view:rule-of-78
view:rvol-accel
view:saas-magic-number
view:saas-quick-ratio
view:safe
view:safety-stock
view:sales-per-square-foot
view:sales-tax
view:sales-volume-variance
view:salt-cap
view:savers-credit
view:savings-rate
view:savings-waterfall
view:scale-in-average
view:scanner-backtest
view:scanners
view:scorp-calc
view:screener
view:sde-valuation
view:se-health-deduction
view:search
view:seasonals
view:sec-1256
view:second-income
view:second-order-greeks
view:section-1014
view:section-1015
view:section-102
view:section-1031
view:section-1033
view:section-1035
view:section-1041
view:section-1042
view:section-105
view:section-1058
view:section-1059
view:section-106
view:section-1092
view:section-119
view:section-1202
view:section-121
view:section-1212
view:section-1231
view:section-1233
view:section-1234
view:section-1239
view:section-1244
view:section-1245
view:section-1245-1250
view:section-1248
view:section-125
view:section-1250
view:section-1259
view:section-127
view:section-1273
view:section-1276
view:section-129
view:section-1291
view:section-1295
view:section-1296
view:section-1296-pfic
view:section-1297
view:section-1298
view:section-132
view:section-134
view:section-1341
view:section-1361
view:section-1362
view:section-1366
view:section-1368
view:section-1374
view:section-1377
view:section-1400z
view:section-1402
view:section-1411
view:section-1445
view:section-1446f
view:section-152
view:section-162a1
view:section-162c
view:section-162f
view:section-162l
view:section-162m
view:section-163j
view:section-164
view:section-165
view:section-165c3
view:section-165d
view:section-165g
view:section-168
view:section-168g
view:section-168k
view:section-170
view:section-172
view:section-174
view:section-179
view:section-179d
view:section-195
view:section-197
view:section-199a
view:section-2010c
view:section-2032
view:section-2055
view:section-2056
view:section-21-cdcc
view:section-213
view:section-219
view:section-221
view:section-23
view:section-24
view:section-24-ctc
view:section-245a
view:section-248
view:section-250
view:section-2503
view:section-2518
view:section-25a
view:section-25c
view:section-25d
view:section-25e
view:section-263-tpr
view:section-263a
view:section-263c
view:section-269
view:section-269a
view:section-274
view:section-280c
view:section-280e
view:section-280f
view:section-280g
view:section-302
view:section-303
view:section-304
view:section-305
view:section-30c
view:section-30d
view:section-311
view:section-318
view:section-32
view:section-32-eic
view:section-332
view:section-336
view:section-338
view:section-351
view:section-351-721
view:section-355
view:section-357
view:section-362
view:section-367a
view:section-367d
view:section-368
view:section-36b
view:section-38
view:section-382
view:section-401a9
view:section-401k-hardship
view:section-408a
view:section-408d3
view:section-409a
view:section-41
view:section-412
view:section-414
view:section-414v
view:section-415
view:section-416
view:section-42
view:section-421
view:section-444
view:section-446
view:section-4501
view:section-451
view:section-457
view:section-45l
view:section-45q
view:section-45v
view:section-45w
view:section-45x
view:section-460
view:section-461
view:section-461l
view:section-467
view:section-469
view:section-47
view:section-471
view:section-472
view:section-475
view:section-475f
view:section-48
view:section-481
view:section-481a
view:section-482
view:section-483
view:section-48c
view:section-4940
view:section-4941
view:section-4942
view:section-4943
view:section-4944
view:section-4945
view:section-4958
view:section-4960
view:section-4972
view:section-4973
view:section-4974
view:section-4975
view:section-4980d
view:section-4980h
view:section-51
view:section-511
view:section-529
view:section-530
view:section-59a
view:section-6011
view:section-6015
view:section-6033
view:section-6038
view:section-6038a
view:section-6038b
view:section-6038d
view:section-6039
view:section-6041
view:section-6045
view:section-6045a
view:section-6045b
view:section-6048
view:section-6049
view:section-6050w
view:section-6051
view:section-6072
view:section-6111
view:section-6112
view:section-6159
view:section-6166
view:section-6213
view:section-6221
view:section-6321
view:section-6325
view:section-6330
view:section-6331
view:section-6404
view:section-6502
view:section-6601
view:section-6651
view:section-6654
view:section-6655
view:section-6662
view:section-6663
view:section-6664
view:section-6672
view:section-6694
view:section-6695
view:section-67
view:section-6700
view:section-6707a
view:section-6724
view:section-691
view:section-707
view:section-71-alimony
view:section-7122
view:section-72p
view:section-72t
view:section-731
view:section-7345
view:section-736
view:section-743
view:section-7430
view:section-7491
view:section-7508a
view:section-752
view:section-754
view:section-7701b
view:section-7701o
view:section-7702
view:section-7702a
view:section-7811
view:section-7872
view:section-7874
view:section-79
view:section-83
view:section-86
view:section-871
view:section-871a
view:section-871m
view:section-877a
view:section-882
view:section-884
view:section-894
view:section-897
view:section-901
view:section-901j
view:section-904
view:section-911
view:section-951
view:section-951a
view:section-956
view:section-962
view:section-988
view:section-989
view:sector-heatmap
view:sector-rotation
view:sector-rotation-strategy
view:sector-timing
view:sectors
view:security-deposit-itemization
view:sell-through-rate
view:seller-disclosure
view:seller-financing
view:seller-net-sheet
view:sentiment
view:sentiment-velocity
view:sep-ira
view:sequence-of-returns
view:sequencer
view:serenity-ratio
view:series-smoother
view:service-cost-allocation
view:settings
view:setups-by-setup
view:severance
view:sga-ratio
view:shareholder-yield
view:shares
view:sharpe-ratio
view:short-interest
view:signal-decomposition
view:simple-ira
view:sinking-fund
view:sizing
view:slat
view:social-security-age
view:solar-payback
view:solo-401k
view:sortino-ratio
view:sp500-predict
view:span-margin
view:spark-spread
view:spia
view:split-shift-premium
view:splits-history
view:spousal-ira
view:spread-tracker
view:springate-score
view:sqn
view:squeeze-alerts
view:squeeze-scanner
view:ss-pia
view:ss-taxation
view:standard-cost-variance
view:standard-pivots
view:standard-vs-itemized
view:state-tax
view:statement-of-account
view:stock-compensation
view:stock-split
view:stock-subscription
view:stock-to-flow
view:stop-loss-backtest
view:stop-loss-best-of
view:storage-revenue
view:str-loophole
view:str-revenue
view:straddle
view:strangle
view:strategy-alerts
view:strategy-tools
view:stress-test
view:stretch-ira
view:stryke-hooks
view:student-loan-interest-deduction
view:student-loan-payoff
view:sublease
view:subscriptions
view:supply-chain
view:sustainable-growth-rate
view:symbol-changes
view:symbol-math
view:table-turnover
view:tags
view:take-home-paycheck
view:take-rate
view:tangible-book-value
view:tangible-common-equity
view:tape
view:tape-replay
view:target-costing
view:target-profit-units
view:tax-aware-rebalance
view:tax-bracket-optimizer
view:tax-equivalent-yield
view:tax-loss-harvest
view:tax-lots
view:tax-workshop
view:tbill-yield
view:tenant-income-qualification
view:tenant-turnover
view:texas-ratio
view:three-bar-reversal
view:three-fund-portfolio
view:three-line-break
view:throughput-accounting
view:ti-allowance
view:tick-bar
view:time-in-force
view:time-value-money
view:time-weighted-return
view:timesheet
view:tips-bond
view:tips-breakeven
view:toast-history
view:top-news
view:top-signals
view:total-payout-ratio
view:total-shareholder-return
view:trade-compare
view:trade-efficiency
view:trade-expectancy
view:trade-plan-checklist
view:trade-timeline
view:trades
view:traditional-ira-deduction
view:trailing-stop-percent
view:travel-per-diem
view:treynor-ratio
view:trial-balance
view:triangular-arbitrage
view:triple-net-total
view:triple-screen
view:true-hourly-wage
view:tts-qualification
view:tts-scorer
view:turnover-cost-drag
view:tutorial
view:twap
view:two-asset-portfolio
view:two-percent-rule
view:two-stage-ddm
view:unlevered-beta
view:unusual-options
view:uoa-stream
view:upside-potential-ratio
view:uspto-patents
view:vacation-home-breakeven
view:valuation-multiples
view:valuation-tools
view:var-calculator
view:var-estimator
view:variable-overhead-variance
view:vasicek
view:velocity-of-money
view:vertical-spread
view:viral-coefficient
view:vix-implied-move
view:vix-term-structure
view:vol
view:vol-smile
view:vol-stop-close
view:vol-surface
view:volume-at-price
view:volume-bar
view:vpin
view:vrp
view:vwap-slippage
view:wacc
view:wage-converter
view:wage-garnishment
view:walk-forward
view:warrant
view:warranty-liability
view:wash-sale
view:wash-sale-tracker
view:watchlists
view:wealth-index
view:webhooks
view:webull
view:weighted-average-maturity
view:weighted-midprice
view:wholesale-spread
view:win-loss-ratio
view:win-streak-probability
view:work-in-progress
view:workers-comp-premium
view:working-capital
view:working-capital-turnover
view:years-to-fi
view:yield-curve
view:yield-curve-pca
view:yield-on-cost
view:yield-to-call
view:yield-to-maturity
view:yield-to-worst
view:zero-based-budget
view:zmijewski-score
view:ztranslator
```

**`app`** (17)

```
app.backtestOverfitPbo
app.copySessionSummary
app.edgeFragility
app.fileBrowser
app.hideTerminal
app.hooksEditor
app.killTerminal
app.quickAlertFinder
app.quickTradeFinder
app.sessionSnapshot
app.shapleyEdge
app.shapleyTape
app.symbolSwitcher
app.tagExplorer
app.terminal
app.toggleSequencer
app.watchlistQuickAdd
```

## zphoto

Photoshop + Illustrator-style raster & vector editor — layers, filters, paths, actions  
**706 verbs** · live bus surface · call as `App::open("zphoto")->call("<verb>", %args)`

**`(top-level)`** (1)

```
capabilities
```

**`action`** (8)

```
action.batch
action.delete
action.get
action.list
action.load
action.play
action.record
action.stop
```

**`appshell`** (118)

```
appshell.addLayer
appshell.addMaskFromSel
appshell.addMaskWhite
appshell.addSlice
appshell.addText
appshell.applyMask
appshell.armGuard
appshell.autoContrast
appshell.batchProcess
appshell.blackWhite
appshell.boxBlur
appshell.brightnessContrast
appshell.clearSlices
appshell.colorBalance
appshell.convertGray
appshell.convertIndexed
appshell.cropImage
appshell.cropToSel
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.curvesDlg
appshell.delActive
appshell.deleteImage
appshell.desaturate
appshell.disarmGuards
appshell.dropShadow
appshell.dupActive
appshell.edge
appshell.emboss
appshell.equalize
appshell.exportLayers
appshell.exportSlices
appshell.exposure
appshell.files
appshell.files.close
appshell.files.open
appshell.fillLayer
appshell.flatten
appshell.flipH
appshell.flipLayerH
appshell.flipLayerV
appshell.flipV
appshell.gamma
appshell.gaussianBlur
appshell.glow
appshell.gradientMap
appshell.gui-scripts
appshell.histogram
appshell.historyGrid
appshell.hooks
appshell.hueSaturation
appshell.invert
appshell.invertMask
appshell.layerFromVisible
appshell.levelsDlg
appshell.median
appshell.mergeVisible
appshell.motionBlur
appshell.neon.off
appshell.neon.on
appshell.newImage
appshell.noiseF
appshell.offsetLayer
appshell.openImage
appshell.openNodeGraph
appshell.optimizeProgram
appshell.palette
appshell.pixelate
appshell.posterize
appshell.redo
appshell.removeMask
appshell.resizeCanvas
appshell.ripple
appshell.rotate180
appshell.rotate270
appshell.rotate90
appshell.rotateLayer
appshell.saveAnimation
appshell.saveImage
appshell.saveJpeg
appshell.scaleImage
appshell.scaleLayer
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.selectAll
appshell.selectInvert
appshell.selectNone
appshell.sepia
appshell.settings
appshell.sharpen
appshell.shortcuts
appshell.slicesFromGuides
appshell.solarize
appshell.solveProgram
appshell.spread
appshell.temperature
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.threshold
appshell.tmux-keys
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
appshell.undo
appshell.valueInvert
appshell.vibrance
appshell.vignette
```

**`brush`** (4)

```
brush.define
brush.delete
brush.list
brush.stamp
```

**`channel`** (4)

```
channel.spot_add
channel.spot_fill
channel.spot_list
channel.spot_remove
```

**`comp`** (5)

```
comp.apply
comp.attribute
comp.capture
comp.delete
comp.list
```

**`edit`** (10)

```
edit.blame
edit.copy
edit.copy_merged
edit.cut
edit.fade
edit.history
edit.paste
edit.redo
edit.timeline
edit.undo
```

**`fill`** (15)

```
fill.bucket
fill.checkerboard
fill.clouds
fill.difference_clouds
fill.fibers
fill.gradient
fill.grid
fill.history
fill.maze
fill.pattern
fill.plasma
fill.reaction_diffusion
fill.sinus
fill.spiral
fill.tree
```

**`filter`** (138)

```
filter.accented_edges
filter.angled_strokes
filter.antialias
filter.average
filter.bas_relief
filter.bloom
filter.blur
filter.blur_more
filter.box_blur
filter.cartoon
filter.chalk_charcoal
filter.charcoal
filter.chromatic_aberration
filter.chrome
filter.color_halftone
filter.colored_pencil
filter.conte_crayon
filter.convolve
filter.craquelure
filter.crosshatch
filter.crystallize
filter.cubism
filter.curve_bend
filter.cutout
filter.dark_strokes
filter.deinterlace
filter.despeckle
filter.difference_of_gaussians
filter.diffuse
filter.diffuse_glow
filter.dilate
filter.dry_brush
filter.dust_and_scratches
filter.edge
filter.emboss
filter.erode
filter.extrude
filter.facet
filter.field_blur
filter.film_grain
filter.flame
filter.fractal_explorer
filter.fractal_trace
filter.fragment
filter.fresco
filter.gaussian_blur
filter.glass
filter.glow
filter.glowing_edges
filter.gradient_flare
filter.grain
filter.graphic_pen
filter.guided
filter.halftone
filter.halftone_pattern
filter.high_pass
filter.hsb_hsl
filter.hurl
filter.ink_outlines
filter.iris_blur
filter.kaleidoscope
filter.kuwahara
filter.laplace
filter.lens_blur
filter.lens_correction
filter.lens_distortion
filter.lens_flare
filter.lighting_effects
filter.long_shadow
filter.maximum
filter.median
filter.mezzotint
filter.minimum
filter.mosaic_tiles
filter.motion_blur
filter.neon_glow
filter.nl_means
filter.noise
filter.note_paper
filter.ntsc_colors
filter.ocean_ripple
filter.offset
filter.oilify
filter.old_photo
filter.paint_daubs
filter.palette_knife
filter.patchwork
filter.path_blur
filter.photocopy
filter.picture_frame
filter.pixel_sort
filter.pixelate
filter.plaster
filter.plastic_wrap
filter.pointillize
filter.polar_coordinates
filter.poster_edges
filter.predator
filter.radial_blur
filter.reduce_noise
filter.reticulation
filter.ripple
filter.rough_pastels
filter.shape_blur
filter.sharpen
filter.sharpen_edges
filter.sharpen_more
filter.shear
filter.smart_blur
filter.smart_sharpen
filter.smart_sharpen_motion
filter.smudge_stick
filter.softglow
filter.spatter
filter.spherize
filter.sponge
filter.sprayed_strokes
filter.spread
filter.stained_glass
filter.stamp
filter.sumi_e
filter.supernova
filter.surface_blur
filter.texturizer
filter.tiles
filter.tilt_shift
filter.torn_edges
filter.trace_contour
filter.underpainting
filter.unsharp_mask
filter.vignette
filter.water_paper
filter.watercolor
filter.wave
filter.waves
filter.whirl_pinch
filter.wind
filter.zigzag
```

**`graph`** (13)

```
graph.analyze
graph.connect
graph.create
graph.delete
graph.disconnect
graph.eval
graph.get
graph.list
graph.load
graph.node_add
graph.node_remove
graph.output
graph.solve
```

**`guard`** (4)

```
guard.arm
guard.check
guard.disarm
guard.list
```

**`image`** (38)

```
image.auto_blend
image.color_table
image.contact_sheet
image.convert
image.count
image.crop
image.crop_to_content
image.crop_to_selection
image.delete
image.depth_merge
image.duplicate
image.export_layers
image.flatten
image.flip
image.get
image.histogram
image.list
image.measure
image.merge_channels
image.merge_hdr
image.merge_visible
image.new
image.open
image.palette
image.perspective_crop
image.photomerge
image.pick
image.quickmask
image.render
image.resize_canvas
image.reveal_all
image.rotate
image.rotate_arbitrary
image.save
image.save_animation
image.scale
image.split_channels
image.stack_mode
```

**`layer`** (65)

```
layer.add
layer.add_adjustment
layer.add_mask
layer.align
layer.apply_mask
layer.auto_align
layer.bevel_emboss
layer.blend_if
layer.color_overlay
layer.content_aware_carve
layer.content_aware_fill
layer.content_aware_move
layer.crop_to_content
layer.defringe
layer.distribute
layer.distribute_spacing
layer.drop_shadow
layer.duplicate
layer.fill
layer.fill_layer
layer.flip
layer.frequency_separation
layer.from_selection
layer.from_visible
layer.gradient_overlay
layer.group
layer.inner_glow
layer.inner_shadow
layer.invert_mask
layer.liquify
layer.list
layer.magic_eraser
layer.mask_density
layer.mask_feather
layer.merge_down
layer.merge_group
layer.move_to_group
layer.offset
layer.outer_glow
layer.paste_into
layer.pattern_overlay
layer.perspective
layer.puppet_warp
layer.remove
layer.remove_mask
layer.remove_matte
layer.reorder
layer.rotate
layer.satin
layer.scale
layer.set
layer.set_fill
layer.shear
layer.smart_convert
layer.smart_filter
layer.smart_rasterize
layer.smart_replace
layer.smart_reset
layer.stroke
layer.stroke_selection
layer.ungroup
layer.vector_mask
layer.via_cut
layer.warp
layer.warp_text
```

**`note`** (4)

```
note.add
note.clear
note.delete
note.list
```

**`op`** (80)

```
op.apply_image
op.auto_color
op.auto_contrast
op.auto_dodge_burn
op.auto_levels
op.auto_tone_scene
op.auto_white_balance
op.banding_forecast
op.bitmap
op.black_white
op.blacks
op.bleach_bypass
op.brightness_contrast
op.bump_map
op.calculations
op.camera_raw
op.channel_mixer
op.channel_swap
op.chroma_clarity
op.clahe
op.clarity
op.clear
op.color_balance
op.color_balance_tonal
op.color_blind_sim
op.color_lookup
op.color_to_alpha
op.color_wheels
op.colorize
op.cross_process
op.curves
op.dehaze
op.desaturate
op.displace
op.dither
op.duotone
op.equalize
op.exposure
op.gamma
op.gradient_map
op.gradient_map_multi
op.gray_point
op.harmonize
op.hdr_toning
op.hue_curve
op.hue_saturation
op.hue_saturation_full
op.invert
op.isoluminant
op.jnd_audit
op.lab
op.lens_blur_depth
op.levels
op.lut
op.match_color
op.match_histogram
op.pattern_maker
op.photo_filter
op.posterize
op.rarity_vibrance
op.red_eye
op.replace_color
op.retinex
op.selective_color
op.semi_flatten
op.sepia
op.shadows_highlights
op.solarize
op.specular_separation
op.split_tone
op.temperature
op.texture
op.threshold
op.threshold_alpha
op.tonal_hue_shift
op.tone_equalizer
op.value_invert
op.velvia
op.vibrance
op.whites
```

**`paint`** (24)

```
paint.airbrush
paint.art_history
paint.background_eraser
paint.bloat
paint.blur
paint.burn
paint.clone
paint.color_replacement
paint.dodge
paint.heal
paint.history
paint.ink
paint.mixer
paint.pattern
paint.perspective_clone
paint.pucker
paint.push
paint.sharpen
paint.smudge
paint.sponge
paint.spot_heal
paint.stroke
paint.twirl
paint.warp
```

**`path`** (6)

```
path.add
path.delete
path.from_selection
path.list
path.stroke
path.to_selection
```

**`pattern`** (3)

```
pattern.define
pattern.delete
pattern.list
```

**`program`** (5)

```
program.analyze
program.apply
program.budget
program.optimize
program.solve
```

**`project`** (2)

```
project.load
project.save
```

**`sampler`** (5)

```
sampler.add
sampler.clear
sampler.delete
sampler.list
sampler.target
```

**`select`** (31)

```
select.all
select.border
select.color_range
select.contrast
select.ellipse
select.feather
select.focus_area
select.foreground
select.from_channel
select.grow
select.invert
select.load
select.magnetic
select.none
select.paint
select.polygon
select.quick
select.rect
select.reselect
select.rounded_rect
select.save
select.shrink
select.similar
select.single_column
select.single_row
select.skin_tones
select.smooth
select.texture
select.tonal_range
select.transform
select.wand
```

**`slice`** (6)

```
slice.add
slice.clear
slice.delete
slice.export
slice.from_guides
slice.list
```

**`text`** (3)

```
text.add
text.mask
text.on_path
```

**`vec`** (114)

```
vec.add_anchors
vec.align
vec.arc
vec.artboard.add
vec.average
vec.blend
vec.blob
vec.brush
vec.cleanup
vec.clip
vec.compound
vec.compound_release
vec.convert_anchor
vec.convert_to_shape
vec.crop
vec.crop_marks
vec.crystallize
vec.delete
vec.divide
vec.duplicate
vec.ellipse
vec.envelope_mesh
vec.erase
vec.expand
vec.extrude
vec.eyedropper
vec.fit
vec.flare
vec.free_distort
vec.get
vec.gradient_freeform
vec.gradient_mesh
vec.grid
vec.group
vec.guide.add
vec.hide
vec.image.place
vec.join
vec.knife
vec.layer.add
vec.line
vec.liquify_warp
vec.list
vec.live_paint_fill
vec.lock
vec.merge
vec.new
vec.object.add_fill
vec.object.blend
vec.object.blur
vec.object.delete
vec.object.drop_shadow
vec.object.feather
vec.object.glow
vec.object.move_anchor
vec.object.reorder
vec.object.style
vec.object.transform
vec.offset_path
vec.opacity_mask
vec.open
vec.outline
vec.outline_stroke
vec.path.add
vec.pathfinder
vec.polar_grid
vec.polygon
vec.pucker_bloat
vec.puppet
vec.recolor
vec.rect
vec.reflect
vec.region_at
vec.remove_anchors
vec.render
vec.repeat_grid
vec.repeat_mirror
vec.repeat_radial
vec.reshape
vec.reverse
vec.revolve
vec.rotate3d
vec.roughen
vec.round_corners
vec.save
vec.scallop
vec.scissors
vec.scribble
vec.select_same
vec.simplify
vec.smooth
vec.spiral
vec.split_grid
vec.star
vec.symbol.adjust
vec.symbol.define
vec.symbol.place
vec.symbol.spray
vec.text
vec.text_case
vec.text_set
vec.text_thread
vec.text_to_outlines
vec.text_wrap
vec.trace
vec.transform_again
vec.transform_each
vec.trim
vec.tweak
vec.twist
vec.ungroup
vec.warp
vec.wrinkle
vec.zigzag
```

## zmax-gui

**632 verbs** · live bus surface · call as `App::open("zmax-gui")->call("<verb>", %args)`

**`(top-level)`** (144)

```
align_columns
batch_rename
bookmark_add
bookmark_clear
bookmark_list
bookmark_remove
comment_toggle
convert_encoding
convert_file
copy_path
create_path
dedupe_file_lines
delete_file
delete_path
detect_encoding
diff_files
doc_blame
fb_watcher_set
file_stats
filter_file_lines
find_definition
find_files
focus_window
fs_chmod
fs_compare_dirs
fs_compress
fs_copy_path
fs_create_dir
fs_create_file
fs_diff
fs_disk_usage
fs_duplicate
fs_extract
fs_find_duplicates
fs_folder_size
fs_get_info
fs_git_status
fs_grep
fs_hash
fs_list_dir
fs_list_subdirs
fs_make_alias
fs_open_in_editor
fs_open_terminal
fs_read_file_base64
fs_read_file_bytes
fs_read_head
fs_read_head_bytes
fs_run_program
fs_secure_delete
fs_symlink_retarget
fs_touch
fs_write_file_base64
fs_xattrs
git_blame
git_branch
git_branches
git_checkout_branch
git_commit
git_commit_info
git_create_branch
git_diff_revs
git_discard
git_file_diff
git_graph
git_log_file
git_log_repo
git_show
git_show_commit
git_stage
git_stash_drop
git_stash_list
git_stash_pop
git_stash_save
git_stash_show
git_status
git_tag_create
git_tag_delete
git_tag_show
git_tags
git_unstage
home_dir
licence_sign_in
licence_sign_out
licence_status
list_dir
move_to_trash
project_stats
project_symbols
recent_add
recent_clear
recent_list
rename_file
rename_path
replace_documents
replace_project
run_bash
run_stryke_hook
scan_markers
search_documents
search_project
set_blur
shell_term_kill
shell_term_resize
shell_term_spawn
shell_term_write
snippet_add
snippet_clear
snippet_list
snippet_remove
sort_file_lines
stryke_bin_path
stryke_lsp_send
stryke_lsp_start
stryke_lsp_stop
sys_stats
take_pending_opens
term_session_kill
term_session_resize
term_session_spawn
term_session_write
terminal_kill
terminal_resize
terminal_spawn
terminal_write
toggle_fullscreen
txn_append
txn_close
txn_coverage
txn_discard
txn_journal
txn_list
txn_open
txn_pending
txn_restore
txn_seal
txn_snapshot
txn_unwind
zgui_reveal_scripts
zgui_write_scripts
zmax_exec_command
zoffice_commands
zoffice_invoke
zpdf_invoke
```

**`appshell`** (416)

```
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.files
appshell.files.close
appshell.files.open
appshell.gui-scripts
appshell.hooks
appshell.neon.off
appshell.neon.on
appshell.palette
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.settings
appshell.shortcuts
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.tmux-keys
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
appshell.zmax.abbrevBoth
appshell.zmax.abbrevClear
appshell.zmax.abbrevCmdline
appshell.zmax.abbrevDefine
appshell.zmax.abbrevExpandRegion
appshell.zmax.abbrevInsert
appshell.zmax.abbrevKillAll
appshell.zmax.abbrevList
appshell.zmax.abbrevReadFile
appshell.zmax.abbrevRemove
appshell.zmax.abbrevRemoveCmdline
appshell.zmax.abbrevRemoveInsert
appshell.zmax.abbrevWriteFile
appshell.zmax.alignAmpersand
appshell.zmax.alignArithmetic
appshell.zmax.alignColon
appshell.zmax.alignComma
appshell.zmax.alignCursors
appshell.zmax.alignDot
appshell.zmax.alignEquals
appshell.zmax.alignLbrace
appshell.zmax.alignLbracket
appshell.zmax.alignLeftChar
appshell.zmax.alignLparen
appshell.zmax.alignRbrace
appshell.zmax.alignRbracket
appshell.zmax.alignRegex
appshell.zmax.alignRightChar
appshell.zmax.alignRparen
appshell.zmax.alignSemicolon
appshell.zmax.arduinoBoardInfo
appshell.zmax.arduinoBoards
appshell.zmax.arduinoBurnBootloader
appshell.zmax.arduinoCompile
appshell.zmax.arduinoCompileExport
appshell.zmax.arduinoCoreInstall
appshell.zmax.arduinoCoreList
appshell.zmax.arduinoCoreSearch
appshell.zmax.arduinoDebug
appshell.zmax.arduinoLibExamples
appshell.zmax.arduinoLibList
appshell.zmax.arduinoLibSearch
appshell.zmax.arduinoMonitor
appshell.zmax.arduinoNewSketch
appshell.zmax.arduinoOutdated
appshell.zmax.arduinoPlotter
appshell.zmax.arduinoPorts
appshell.zmax.arduinoUpload
appshell.zmax.baseConvert
appshell.zmax.blurOff
appshell.zmax.blurOn
appshell.zmax.bookmarkJump
appshell.zmax.bookmarkLoad
appshell.zmax.bookmarkNext
appshell.zmax.bookmarkPrev
appshell.zmax.bookmarkToggle
appshell.zmax.bookmarkWrite
appshell.zmax.cheatSheet
appshell.zmax.clearHighlight
appshell.zmax.closeBuffer
appshell.zmax.closeSplit
appshell.zmax.codeAction
appshell.zmax.coerceDot
appshell.zmax.coerceKebab
appshell.zmax.coerceLowerCamel
appshell.zmax.coerceUnderscore
appshell.zmax.coerceUpCase
appshell.zmax.coerceUpperCamel
appshell.zmax.colorLiteral
appshell.zmax.commandCenter
appshell.zmax.commandDirectory
appshell.zmax.commentToggle
appshell.zmax.composeMail
appshell.zmax.copy
appshell.zmax.countMatches
appshell.zmax.cut
appshell.zmax.dateTimeInsert
appshell.zmax.dedent
appshell.zmax.emojiInsert
appshell.zmax.extractBetween
appshell.zmax.extractEmails
appshell.zmax.extractIps
appshell.zmax.extractNumbers
appshell.zmax.extractQuoted
appshell.zmax.extractUrls
appshell.zmax.find
appshell.zmax.findNext
appshell.zmax.findPrev
appshell.zmax.focusBookmarks
appshell.zmax.focusCiPanel
appshell.zmax.focusEditor
appshell.zmax.focusFileTree
appshell.zmax.focusGitPanel
appshell.zmax.focusJumplistPanel
appshell.zmax.focusMarksPanel
appshell.zmax.focusProblems
appshell.zmax.focusRecentPanel
appshell.zmax.focusRegistersPanel
appshell.zmax.focusRunConsole
appshell.zmax.focusStructure
appshell.zmax.focusTodoPanel
appshell.zmax.foldClose
appshell.zmax.foldCloseAll
appshell.zmax.foldCreate
appshell.zmax.foldDelete
appshell.zmax.foldDeleteAll
appshell.zmax.foldNext
appshell.zmax.foldOpen
appshell.zmax.foldOpenAll
appshell.zmax.foldPrev
appshell.zmax.foldToggle
appshell.zmax.format
appshell.zmax.fullscreen
appshell.zmax.generateCode
appshell.zmax.gitBlame
appshell.zmax.gitConflictOurs
appshell.zmax.gitConflictTheirs
appshell.zmax.gitDiff
appshell.zmax.gitMerge
appshell.zmax.gitNextConflict
appshell.zmax.gitNextHunk
appshell.zmax.gitPrevHunk
appshell.zmax.gitResetHunk
appshell.zmax.gitStage
appshell.zmax.gitStash
appshell.zmax.gitStashPop
appshell.zmax.gitStatus
appshell.zmax.gitUnstage
appshell.zmax.glyphInsert
appshell.zmax.gotoDef
appshell.zmax.gotoRefs
appshell.zmax.gotoTypeDef
appshell.zmax.harpoon1
appshell.zmax.harpoon2
appshell.zmax.harpoon3
appshell.zmax.harpoon4
appshell.zmax.harpoonAdd
appshell.zmax.harpoonJump
appshell.zmax.harpoonMenu
appshell.zmax.harpoonNext
appshell.zmax.harpoonPrev
appshell.zmax.harpoonRemove
appshell.zmax.hashLab
appshell.zmax.help
appshell.zmax.hideActiveToolWindow
appshell.zmax.hover
appshell.zmax.hsplit
appshell.zmax.implementMethods
appshell.zmax.insertTable
appshell.zmax.jsonFormat
appshell.zmax.jumpBack
appshell.zmax.jumpChar
appshell.zmax.jumpClear
appshell.zmax.jumpDirListing
appshell.zmax.jumpFile
appshell.zmax.jumpForward
appshell.zmax.jumpLastChange
appshell.zmax.jumpLastToolWindow
appshell.zmax.jumpLineEnd
appshell.zmax.jumpLineStart
appshell.zmax.jumpList
appshell.zmax.jumpUnmatchedParen
appshell.zmax.jumpWord
appshell.zmax.jumplistPicker
appshell.zmax.justifyCenter
appshell.zmax.justifyFull
appshell.zmax.justifyLeft
appshell.zmax.justifyNone
appshell.zmax.justifyRight
appshell.zmax.layoutPresets
appshell.zmax.loremList
appshell.zmax.loremParagraph
appshell.zmax.loremSentence
appshell.zmax.lspRestart
appshell.zmax.macroCounterAdd
appshell.zmax.macroCounterInsert
appshell.zmax.macroRecord
appshell.zmax.macroRepeatCommand
appshell.zmax.macroReplay
appshell.zmax.macroReplayLast
appshell.zmax.macroRingDelete
appshell.zmax.macroRingNext
appshell.zmax.macroRingPrev
appshell.zmax.macroRingSwap
appshell.zmax.macroRingView
appshell.zmax.macroStop
appshell.zmax.macroToRegister
appshell.zmax.markDelete
appshell.zmax.markDeleteAll
appshell.zmax.markGoto
appshell.zmax.markList
appshell.zmax.markSet
appshell.zmax.messageGotoBody
appshell.zmax.messageGotoTo
appshell.zmax.messageKill
appshell.zmax.messageSend
appshell.zmax.messageSendExit
appshell.zmax.messageSignature
appshell.zmax.narrowFunction
appshell.zmax.narrowFunctionIndirect
appshell.zmax.narrowPage
appshell.zmax.narrowPageIndirect
appshell.zmax.narrowRegion
appshell.zmax.narrowRegionIndirect
appshell.zmax.newBuffer
appshell.zmax.nextBuffer
appshell.zmax.nextDiag
appshell.zmax.numDecrement
appshell.zmax.numIncrement
appshell.zmax.open
appshell.zmax.openRecent
appshell.zmax.organizeImports
appshell.zmax.overrideMethods
appshell.zmax.panel.alignColumns
appshell.zmax.panel.batchPlan
appshell.zmax.panel.batchRename
appshell.zmax.panel.bookmarks
appshell.zmax.panel.commentToggle
appshell.zmax.panel.compareFiles
appshell.zmax.panel.dedupeLines
appshell.zmax.panel.diffRevisions
appshell.zmax.panel.docBlame
appshell.zmax.panel.fileBrowser
appshell.zmax.panel.fileCleanup
appshell.zmax.panel.fileEncoding
appshell.zmax.panel.filterLines
appshell.zmax.panel.findDefinition
appshell.zmax.panel.findInFiles
appshell.zmax.panel.gitBlame
appshell.zmax.panel.gitBranches
appshell.zmax.panel.gitChanges
appshell.zmax.panel.gitCommit
appshell.zmax.panel.gitGraph
appshell.zmax.panel.gitHistory
appshell.zmax.panel.gitLog
appshell.zmax.panel.gitStash
appshell.zmax.panel.gitTags
appshell.zmax.panel.gotoSymbol
appshell.zmax.panel.interruptedRuns
appshell.zmax.panel.markers
appshell.zmax.panel.projectBrowser
appshell.zmax.panel.projectStats
appshell.zmax.panel.quickOpen
appshell.zmax.panel.recentFiles
appshell.zmax.panel.searchDocuments
appshell.zmax.panel.searchReplace
appshell.zmax.panel.snippets
appshell.zmax.panel.sortLines
appshell.zmax.passwordNumerical
appshell.zmax.passwordParanoid
appshell.zmax.passwordPhonetic
appshell.zmax.passwordSimple
appshell.zmax.passwordStrong
appshell.zmax.paste
appshell.zmax.peekDefinition
appshell.zmax.pioBuild
appshell.zmax.pioCheck
appshell.zmax.pioClean
appshell.zmax.pioDebug
appshell.zmax.pioDevices
appshell.zmax.pioLibList
appshell.zmax.pioLibSearch
appshell.zmax.pioMonitor
appshell.zmax.pioTest
appshell.zmax.pioUpload
appshell.zmax.prevBuffer
appshell.zmax.prevDiag
appshell.zmax.quickOpen
appshell.zmax.quit
appshell.zmax.recentFiles
appshell.zmax.redo
appshell.zmax.reflow
appshell.zmax.regexLab
appshell.zmax.registerClear
appshell.zmax.registerClearAll
appshell.zmax.registerSet
appshell.zmax.registersShow
appshell.zmax.reindent
appshell.zmax.reload
appshell.zmax.renameSymbol
appshell.zmax.reshapeByExample
appshell.zmax.restartEditor
appshell.zmax.rmail
appshell.zmax.rotate
appshell.zmax.save
appshell.zmax.saveAs
appshell.zmax.searchReplace
appshell.zmax.sessionOverview
appshell.zmax.signatureHelp
appshell.zmax.simulRename
appshell.zmax.snippetLibrary
appshell.zmax.snippetsEdit
appshell.zmax.snippetsInsert
appshell.zmax.sortLines
appshell.zmax.sortLinesNumeric
appshell.zmax.sortLinesReverse
appshell.zmax.sortLinesUnique
appshell.zmax.sortParagraphs
appshell.zmax.sortRanges
appshell.zmax.spellAddBad
appshell.zmax.spellAddGood
appshell.zmax.spellDump
appshell.zmax.spellInfo
appshell.zmax.spellNextError
appshell.zmax.spellPrevError
appshell.zmax.spellRare
appshell.zmax.spellSuggest
appshell.zmax.spellUndo
appshell.zmax.spellUndoWord
appshell.zmax.spellWrong
appshell.zmax.structAbsorb
appshell.zmax.structBackwardParen
appshell.zmax.structBarfBackward
appshell.zmax.structBarfForward
appshell.zmax.structBeginning
appshell.zmax.structConvolute
appshell.zmax.structCopy
appshell.zmax.structDeleteSexp
appshell.zmax.structDeleteSexpBack
appshell.zmax.structDeleteSymbol
appshell.zmax.structDeleteSymbolBack
appshell.zmax.structEnd
appshell.zmax.structForwardParen
appshell.zmax.structInsertAfter
appshell.zmax.structInsertBefore
appshell.zmax.structJoin
appshell.zmax.structMatchParen
appshell.zmax.structNext
appshell.zmax.structPrev
appshell.zmax.structRaise
appshell.zmax.structSlurpBackward
appshell.zmax.structSlurpForward
appshell.zmax.structSplice
appshell.zmax.structSpliceKillBwd
appshell.zmax.structSpliceKillFwd
appshell.zmax.structSplit
appshell.zmax.structTranspose
appshell.zmax.structUp
appshell.zmax.structWrap
appshell.zmax.subvert
appshell.zmax.symbolPicker
appshell.zmax.tabClose
appshell.zmax.tabDo
appshell.zmax.tabFirst
appshell.zmax.tabLast
appshell.zmax.tabList
appshell.zmax.tabMoveEnd
appshell.zmax.tabMoveTo
appshell.zmax.tabNew
appshell.zmax.tabNewFile
appshell.zmax.tabNext
appshell.zmax.tabOnly
appshell.zmax.tabPrev
appshell.zmax.tmux
appshell.zmax.toggleBottomZoom
appshell.zmax.toggleDrawerMid
appshell.zmax.toggleIde
appshell.zmax.transformByExample
appshell.zmax.transformLower
appshell.zmax.transformUpper
appshell.zmax.tutor
appshell.zmax.undo
appshell.zmax.unicodeInsert
appshell.zmax.uuidV1
appshell.zmax.uuidV4
appshell.zmax.vsplit
appshell.zmax.widen
appshell.zmax.winEqualize
appshell.zmax.winExchange
appshell.zmax.winFocusDown
appshell.zmax.winFocusLeft
appshell.zmax.winFocusRight
appshell.zmax.winFocusUp
appshell.zmax.winMaximize
appshell.zmax.winMoveDown
appshell.zmax.winMoveLeft
appshell.zmax.winMoveRight
appshell.zmax.winMoveUp
appshell.zmax.winNarrower
appshell.zmax.winRotateBack
appshell.zmax.winShorter
appshell.zmax.winTaller
appshell.zmax.winUndoLayout
appshell.zmax.winWider
appshell.zmax.workspaceSymbols
```

**`zmax`** (72)

```
zmax.align.apply
zmax.align.preview
zmax.bookmark.add
zmax.cleanup.apply
zmax.cleanup.preview
zmax.comment.apply
zmax.comment.preview
zmax.doc.blame
zmax.doc.close
zmax.doc.open
zmax.doc.replace
zmax.editor.ex
zmax.editor.open
zmax.encoding.apply
zmax.encoding.preview
zmax.file.copy
zmax.file.create
zmax.file.delete
zmax.file.detectEncoding
zmax.file.list
zmax.file.rename
zmax.file.stats
zmax.git.blame
zmax.git.branch
zmax.git.branches
zmax.git.checkout
zmax.git.commit
zmax.git.commitInfo
zmax.git.compare
zmax.git.createBranch
zmax.git.diffRevs
zmax.git.discard
zmax.git.fileDiff
zmax.git.graph
zmax.git.log
zmax.git.logFile
zmax.git.show
zmax.git.stage
zmax.git.stashDrop
zmax.git.stashList
zmax.git.stashPop
zmax.git.stashSave
zmax.git.status
zmax.git.tagCreate
zmax.git.tagDelete
zmax.git.tagShow
zmax.git.tags
zmax.git.unstage
zmax.lines.dedupeApply
zmax.lines.dedupePreview
zmax.lines.filterApply
zmax.lines.filterPreview
zmax.project.findDefinition
zmax.project.findFiles
zmax.project.markers
zmax.project.root
zmax.project.search
zmax.project.searchDocuments
zmax.project.stats
zmax.project.symbols
zmax.rename.apply
zmax.rename.preview
zmax.replace.apply
zmax.replace.preview
zmax.snippet.add
zmax.sort.apply
zmax.sort.preview
zmax.txn.coverage
zmax.txn.interrupted
zmax.txn.record
zmax.txn.snapshots
zmax.txn.unwind
```

## zpdf

Acrobat/Preview-style PDF engine — render, edit, annotate, forms, OCR, redact  
**370 verbs** · live bus surface · call as `App::open("zpdf")->call("<verb>", %args)`

**`(top-level)`** (368)

```
accessibility_check
add_3d
add_background
add_barcode
add_bookmark
add_callout
add_data_matrix
add_geo_viewport
add_goto_link
add_grid_overlay
add_header_footer
add_image
add_ink
add_launch_link
add_line_numbers
add_link
add_markup
add_measure
add_movie
add_named_action_link
add_named_destination
add_note
add_page_numbers
add_printer_marks
add_qr_code
add_remote_goto_link
add_rich_media
add_screen
add_sound
add_stamp
add_submit_button
add_text
add_text_lines
add_text_with_font
add_thread
add_typed_signature
adjust_image
adjust_page
annotation_thread
apply_actions
apply_redactions
assemble_pages
attach_file
attachments
auto_create_form_fields
auto_crop_margins
auto_link_urls
auto_outline
auto_tag
bates_number
binarize
booklet_order
build_toc_page
canonical_bytes
certify
clear_metadata
clear_recents
clear_signature
color_separations
comment_summary_pages
compare
contact_sheet
content_fingerprint
convert_to_cmyk
copy_fidelity_audit
create_checkbox
create_choice_field
create_from_images
create_from_text
create_layer
create_ocmd
create_push_button
create_radio_group
create_signature_field
create_text_field
crop_page
decrypt
decrypt_pubkey
delete_annotation
delete_annotations_by_author
delete_annotations_by_type
delete_attachment
delete_bookmark
delete_field
delete_layer
delete_named_destination
delete_pages
delete_struct_element
deskew_page
detect_form_fields
detect_image_regions
detect_skew_angle
discard_search_index
discard_thumbnails
doc_js_names
document_id
docx_merge3
downsample_images
draw_bezier
draw_line
draw_path
draw_rect
duplicate_pages
edit_text
encrypt
encrypt_aes256
encrypt_aes256_with_permissions
encrypt_pubkey
encrypt_pubkey_multi
erase_ink_at
export_comments_csv
export_comments_fdf
export_comments_xfdf
export_docx
export_fdf
export_html
export_markdown
export_page_svg
export_png
export_pptx
export_xfa
export_xfdf
export_xlsx
extract_attachment
extract_fonts
extract_images
extract_page_temp
extract_tables
extract_text
extract_text_in_region
extract_to
field_widgets
find_hairlines
find_replace_text
fix_hairlines
flatten_annotations
flatten_form
flatten_layers
flatten_transparency
flip_page
form_fields
generate_thumbnails
geo_distance
geo_point
geo_viewports
has_acroform
has_permissions_dict
has_xfa
hidden_content_audit
highlight_search
image_alt_texts
import_comments_fdf
import_comments_xfdf
import_fdf
import_xfdf
ink_coverage
insert_blank_page
insert_pages
interleave
invert_colors
is_encrypted
is_signed
is_tagged
last_document
linearize
links
list_annotations
list_field_actions
list_fonts
list_inks
list_layers
list_output_intents
live_table
live_table_preview
live_table_set
make_portfolio
make_searchable
mark_visual_differences
merge_file
move_bookmark
move_field
move_page
move_struct_element
move_text
n_up
named_destinations
number_blame
object_stats
ocr_page
ocr_page_words
open_pdf
optimize
outline
overlay_page
page_boxes
page_dimensions
page_size
page_text_runs
page_view
page_visual_difference
pdf_info
permissions
preflight
print_to_pdf
read_threads
readability_stats
reading_order
recalculate_fields
recent_documents
recompress_streams
redact_pii
redact_regex
redact_search
redaction_leak_audit
reflow
regenerate_document_id
remove_blank_pages
remove_doc_js
rename_bookmark
rename_field
rename_layer
render_page
reorder_pages
repair
replace_image
replace_pages
reply_to_annotation
reset_form
resize_all_pages
resize_page
restyle_text
reverse_pages
review_comments
revision_extract
revision_history
rotate_all
rotate_page
run_javascript
sanitize
save_pdf
scan_pii
search
search_matches
set_all_annotation_flags
set_all_page_boxes
set_annotation_author
set_annotation_border
set_annotation_color
set_annotation_contents
set_annotation_flags
set_annotation_opacity
set_annotation_rect
set_annotation_status
set_annotation_subject
set_bookmark_action
set_bookmark_level
set_bookmark_style
set_bookmark_target
set_calculation_order
set_doc_js
set_document_action
set_document_language
set_field
set_field_alignment
set_field_appearance
set_field_calculation_js
set_field_colors
set_field_default_value
set_field_export_name
set_field_flags
set_field_format_js
set_field_keystroke_js
set_field_rich_value
set_field_tooltip
set_field_validate_js
set_image_alt_text
set_info_property
set_layer_locked
set_layer_usage
set_layer_visibility
set_metadata
set_open_action_page
set_outline
set_output_intent
set_page_action
set_page_box
set_page_duration
set_page_labels
set_page_layout
set_page_mode
set_page_transition
set_print_preset
set_reading_direction
set_struct_alt
set_struct_tag
set_tab_order
set_text_field_maxlen
set_text_field_options
set_trapped
set_user_unit
set_viewer_preference
set_xfa_datasets
set_xmp_metadata
sign
sign_image
sign_visible
signature_count
similarity_score
space_audit
split_by_bookmarks
split_by_count
split_by_ranges
split_by_size
split_by_text
split_odd_even
split_page_grid
split_scanned_images
stamp_image
structure_diff
structure_tags
structure_tree
stylize_page
suggest_filename
swap_pages
system_fonts
tag_pdf_ua
take_launch_file
to_grayscale
to_pdf_a
to_pdf_x
to_single_page
undo_annot
unembed_fonts
validate_fields
validate_pdf_a
validate_pdf_ua
vcs_bisect
vcs_blame
vcs_blame_lines
vcs_branch
vcs_branches
vcs_checkout
vcs_commit
vcs_diff
vcs_head
vcs_history_audit
vcs_log
vcs_merge
vcs_merge_resolve
vcs_page_objects
vcs_page_timeline
vcs_pull
vcs_relate
vcs_rewrites
vcs_scrub
vcs_switch
vcs_verify
verify_full
verify_redaction
verify_redaction_deep
verify_signatures
watermark_image
watermark_text
whiteout
word_diff
xfa_datasets
xfa_packets
xmp_metadata
```

**`zpdf`** (2)

```
zpdf.bisect.run
zpdf.txn.checkpoint
```

## zcontainer

Docker Desktop + Lens-style container / Kubernetes manager  
**350 verbs** · live bus surface · call as `App::open("zcontainer")->call("<verb>", %args)`

**`(top-level)`** (1)

```
capabilities
```

**`analyze`** (68)

```
analyze.affinity.match
analyze.bake.parse
analyze.buildcache.predict
analyze.bundle.scan
analyze.cgroup.parse
analyze.cluster.admit
analyze.cni.parse
analyze.compose.convert
analyze.compose.lint
analyze.compose.parse
analyze.compose.profiles.resolve
analyze.compose.startup.plan
analyze.compose.topology
analyze.cost.estimate
analyze.crd.parse
analyze.cron.parse
analyze.cve.aggregate
analyze.delete.cascade
analyze.deploy.pipeline
analyze.dockerfile.lint
analyze.dockerfile.optimize
analyze.dockerfile.parse
analyze.dockerignore.eval
analyze.drain.simulate
analyze.env.resolve
analyze.fieldselector.match
analyze.healthcheck.model
analyze.helm.template
analyze.hpa.recommend
analyze.image.layers
analyze.imageref.parse
analyze.imagetag.policy
analyze.incident.attribute
analyze.incident.cascade
analyze.ingress.routes
analyze.k8s.lint
analyze.k8s.parse
analyze.k8s.schema.validate
analyze.k8s.score
analyze.kubeconfig.parse
analyze.kustomize.render
analyze.lifecycle.timeline
analyze.limitrange.simulate
analyze.manifest.diff
analyze.manifest.restore
analyze.netpol.reachability
analyze.oci.chainid.compute
analyze.oci.image.parse
analyze.owner.graph
analyze.podsecurity.admission
analyze.portmap.parse
analyze.provenance.parse
analyze.qos.oomkill
analyze.qos.oomkill.live
analyze.quantity.parse
analyze.rbac.analyze
analyze.registry.auth.parse
analyze.resources.sum
analyze.sbom.summarize
analyze.schedule.binpack
analyze.seccomp.lint
analyze.secret.entropy
analyze.selector.match
analyze.storage.bind
analyze.sysctl.analyze
analyze.volume.parse
analyze.vpa.recommend
analyze.webhook.analyze
```

**`appshell`** (83)

```
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.dialog.bake-parse
appshell.dialog.buildcache-predict
appshell.dialog.can-i
appshell.dialog.compose-convert
appshell.dialog.compose-startup-plan
appshell.dialog.context-use
appshell.dialog.deploy-pipeline
appshell.dialog.dockerignore-test
appshell.dialog.engine-info
appshell.dialog.env
appshell.dialog.env-file-convert
appshell.dialog.image-ref
appshell.dialog.incident-attribute
appshell.dialog.incident-cascade
appshell.dialog.lifecycle-timeline
appshell.dialog.my-permissions
appshell.dialog.namespace-create
appshell.dialog.ports
appshell.dialog.qos-oomkill
appshell.dialog.quantity-convert
appshell.dialog.registry-auth
appshell.dialog.registry-browse
appshell.dialog.registry-repo
appshell.dialog.secret-encode
appshell.dialog.secret-reveal
appshell.dialog.subject-access
appshell.dialog.swarm-nodes
appshell.dialog.volume-clone
appshell.dialog.volume-files
appshell.dialog.workload-logs
appshell.engine.toggle
appshell.files
appshell.files.close
appshell.files.open
appshell.goto.api-resources
appshell.goto.board
appshell.goto.builds
appshell.goto.compose
appshell.goto.containers
appshell.goto.deathrow
appshell.goto.events
appshell.goto.hpas
appshell.goto.hub
appshell.goto.images
appshell.goto.kube
appshell.goto.launcher
appshell.goto.logs
appshell.goto.networks
appshell.goto.overview
appshell.goto.plugins
appshell.goto.policy
appshell.goto.rbac
appshell.goto.services
appshell.goto.storageclasses
appshell.goto.topology
appshell.goto.volumes
appshell.gui-scripts
appshell.hooks
appshell.neon.off
appshell.neon.on
appshell.palette
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.settings
appshell.shortcuts
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.toggle-theme
appshell.view.compose-tree
appshell.view.refresh
```

**`docker`** (117)

```
docker.builder.prune
docker.builds.inspect
docker.builds.list
docker.builds.logs
docker.builds.remove
docker.checkpoint.create
docker.checkpoint.remove
docker.checkpoints.list
docker.compose.down
docker.compose.list
docker.compose.logs
docker.compose.ps
docker.compose.restart
docker.compose.start
docker.compose.stop
docker.compose.up
docker.config.create
docker.config.inspect
docker.config.remove
docker.configs.list
docker.container.archive.get
docker.container.archive.put
docker.container.commit
docker.container.diff
docker.container.export
docker.container.files
docker.container.healthcheck
docker.container.inspect
docker.container.kill
docker.container.logs
docker.container.pause
docker.container.remove
docker.container.rename
docker.container.resize
docker.container.restart
docker.container.start
docker.container.stats
docker.container.stop
docker.container.top
docker.container.unpause
docker.container.update
docker.container.wait
docker.containers.list
docker.context.use
docker.contexts.list
docker.daemon.start
docker.daemon.status
docker.daemon.stop
docker.engine.pause
docker.engine.resume
docker.hub.repo
docker.hub.repos
docker.hub.search
docker.hub.tags
docker.image.distribution
docker.image.history
docker.image.inspect
docker.image.load
docker.image.prune
docker.image.remove
docker.image.run
docker.image.save
docker.image.scan
docker.image.tag
docker.images.list
docker.logs.buffer
docker.metrics.history
docker.network.connect
docker.network.create
docker.network.disconnect
docker.network.inspect
docker.network.prune
docker.network.remove
docker.networks.list
docker.node.update
docker.ping
docker.plugin.disable
docker.plugin.enable
docker.plugin.inspect
docker.plugin.remove
docker.plugins.list
docker.registry.catalog
docker.registry.login
docker.registry.logout
docker.registry.manifest
docker.registry.ping
docker.registry.tags
docker.scan.available
docker.secret.create
docker.secret.inspect
docker.secret.remove
docker.secrets.list
docker.service.inspect
docker.service.remove
docker.service.rollback
docker.service.scale
docker.service.update
docker.services.list
docker.stats
docker.swarm.inspect
docker.swarm.node.inspect
docker.swarm.nodes.list
docker.swarm.tasks.list
docker.system.df
docker.system.info
docker.system.prune
docker.topology
docker.volume.backup
docker.volume.clone
docker.volume.create
docker.volume.files
docker.volume.inspect
docker.volume.prune
docker.volume.remove
docker.volume.remove.preflight
docker.volume.restore
docker.volumes.list
```

**`k8s`** (72)

```
k8s.access.review
k8s.access.rules
k8s.api.resources
k8s.apply.yaml
k8s.config.list
k8s.configmaps.list
k8s.context.use
k8s.contexts.list
k8s.crds.list
k8s.cronjob.trigger
k8s.cronjobs.list
k8s.daemonsets.list
k8s.deployments.list
k8s.describe
k8s.events.list
k8s.generic.list
k8s.helm.history
k8s.helm.install
k8s.helm.releases.list
k8s.helm.repo.add
k8s.helm.repo.list
k8s.helm.repo.remove
k8s.helm.repo.update
k8s.helm.rollback
k8s.helm.search
k8s.helm.uninstall
k8s.helm.upgrade
k8s.helm.values
k8s.hpa.patch
k8s.hpas.list
k8s.ingresses.list
k8s.jobs.list
k8s.namespace.create
k8s.namespace.delete
k8s.namespaces.list
k8s.network.list
k8s.node.cordon
k8s.node.drain
k8s.node.drain.preflight
k8s.node.uncordon
k8s.nodes.list
k8s.pod.cp
k8s.pod.debug
k8s.pod.evict
k8s.pod.logs
k8s.pods.lifecycle
k8s.pods.list
k8s.pvcs.list
k8s.pvs.list
k8s.rbac.list
k8s.rbac.subject.access
k8s.replicasets.list
k8s.resource.apply
k8s.resource.delete
k8s.resource.delete.preflight
k8s.resource.diff
k8s.resource.events
k8s.resource.get
k8s.resource.patch
k8s.resource.restart
k8s.resource.scale
k8s.rollout.history
k8s.rollout.status
k8s.rollout.undo
k8s.secret.reveal
k8s.secrets.list
k8s.services.list
k8s.statefulsets.list
k8s.storage.list
k8s.top.nodes
k8s.top.pods
k8s.workload.logs
```

**`session`** (1)

```
session.actions.clear
```

**`terminal`** (6)

```
terminal.expect
terminal.kill
terminal.read
terminal.run
terminal.send
terminal.spawn
```

**`vm`** (2)

```
vm.resources.get
vm.resources.set
```

## zemail

Thunderbird-style mail client — accounts, folders, messages, PGP/S-MIME, search  
**313 verbs** · live bus surface · call as `App::open("zemail")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`account`** (5)

```
account.add
account.autoconfig
account.list
account.remove
account.update
```

**`address`** (3)

```
address.known
address.to_ascii
address.validate
```

**`appshell`** (99)

```
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.files
appshell.files.close
appshell.files.open
appshell.gui-scripts
appshell.hooks
appshell.neon.off
appshell.neon.on
appshell.palette
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.settings
appshell.shortcuts
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.tmux-keys
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
appshell.zm.accounts
appshell.zm.advanced_search
appshell.zm.compose
appshell.zm.contacts
appshell.zm.copy_sender
appshell.zm.copy_to
appshell.zm.da_title
appshell.zm.empty_trash
appshell.zm.ex_cmd
appshell.zm.export_ellipsis
appshell.zm.file_browser
appshell.zm.filters
appshell.zm.fk_cmd
appshell.zm.folder_props
appshell.zm.fw_title
appshell.zm.go_folder:Drafts
appshell.zm.go_folder:INBOX
appshell.zm.go_folder:Junk
appshell.zm.go_folder:Notes
appshell.zm.go_folder:Sent
appshell.zm.go_folder:Trash
appshell.zm.go_folder:[Gmail]
appshell.zm.go_folder:[Gmail]/All%20Mail
appshell.zm.go_folder:[Gmail]/Bin
appshell.zm.go_folder:[Gmail]/Drafts
appshell.zm.go_folder:[Gmail]/Important
appshell.zm.go_folder:[Gmail]/Sent%20Mail
appshell.zm.go_folder:[Gmail]/Spam
appshell.zm.go_folder:[Gmail]/Starred
appshell.zm.go_folder:[Gmail]All%20Mail
appshell.zm.hooks
appshell.zm.keys
appshell.zm.lists
appshell.zm.mail_crypto
appshell.zm.mail_forensics
appshell.zm.mail_insights
appshell.zm.mail_lab
appshell.zm.mail_ops
appshell.zm.mail_settings
appshell.zm.mail_tools
appshell.zm.mail_workbench
appshell.zm.manage_folders
appshell.zm.mark_folder_read
appshell.zm.office
appshell.zm.outbox
appshell.zm.pdf
appshell.zm.qa_title
appshell.zm.quick_notes
appshell.zm.ra_title
appshell.zm.rd_cmd
appshell.zm.retention
appshell.zm.revision_timeline
appshell.zm.rl_cmd
appshell.zm.saved_searches
appshell.zm.screener
appshell.zm.search
appshell.zm.sequencer
appshell.zm.settings
appshell.zm.shortcuts
appshell.zm.shortcuts_help
appshell.zm.signatures
appshell.zm.snippets
appshell.zm.stats
appshell.zm.sync
appshell.zm.templates
appshell.zm.terminal
appshell.zm.theme
appshell.zm.tl_title
```

**`attachment`** (2)

```
attachment.parse_tnef
attachment.sniff
```

**`calendar`** (8)

```
calendar.expand_rrule
calendar.freebusy
calendar.parse_alarms
calendar.parse_invite
calendar.parse_journals
calendar.parse_todos
calendar.parse_vtimezone
calendar.rsvp
```

**`carddav`** (2)

```
carddav.fetch
carddav.put
```

**`compose`** (5)

```
compose.attachment_reminder
compose.doc_attest
compose.mail_merge
compose.parse_mailto
compose.quote_check
```

**`contact`** (11)

```
contact.add
contact.export_group
contact.export_vcard
contact.export_vcard4
contact.find_duplicates
contact.gravatar
contact.import_vcard
contact.list
contact.merge
contact.parse_groups
contact.remove
```

**`crypto`** (1)

```
crypto.mime_structure
```

**`expire`** (1)

```
expire.due
```

**`export`** (2)

```
export.eml
export.mbox
```

**`exposure`** (2)

```
exposure.room
exposure.trace
```

**`filter`** (5)

```
filter.add
filter.list
filter.remove
filter.run
filter.to_sieve
```

**`folder`** (8)

```
folder.create
folder.delete
folder.digest
folder.empty
folder.inbox_load
folder.list
folder.mark_read
folder.rename
```

**`followup`** (1)

```
followup.due
```

**`fork`** (2)

```
fork.scan
fork.thread
```

**`gloda`** (1)

```
gloda.search
```

**`html`** (2)

```
html.sanitize
html.to_text
```

**`identity`** (3)

```
identity.baseline
identity.evaluate
identity.scan_folder
```

**`imap`** (12)

```
imap.build_search
imap.folders
imap.idle
imap.parse_bodystructure
imap.parse_command
imap.parse_envelope
imap.parse_fetch
imap.parse_response
imap.parse_thread
imap.search
imap.store_flags
imap.sync
```

**`import`** (3)

```
import.eml
import.maildir
import.mbox
```

**`jmap`** (4)

```
jmap.email_get
jmap.email_object
jmap.email_query
jmap.mailbox_get
```

**`junk`** (3)

```
junk.classify
junk.run
junk.train
```

**`key`** (3)

```
key.add
key.list
key.remove
```

**`list`** (6)

```
list.add_member
list.create
list.list
list.parse_headers
list.remove
list.virtual_folders
```

**`message`** (40)

```
message.action_items
message.add_label
message.attachment_safety
message.build_rfc5322
message.categorize
message.commitment_scan
message.copy
message.delete
message.doc_attest
message.expire
message.find_duplicates
message.followup
message.forward_assemble
message.get
message.importance
message.junk
message.list
message.move
message.parse_dsn
message.parse_eml
message.parse_mdn
message.phishing_scan
message.pin
message.priority_rank
message.quote_audit
message.reading_time
message.reconstruct_thread
message.remove_label
message.roster_audit
message.save_draft
message.set_aside
message.set_flags
message.snooze
message.strip_quotes
message.thread_stats
message.thread_tree
message.threads
message.tracking_scan
message.unsnooze
message.unsubscribe
```

**`mime`** (8)

```
mime.arc_chain
mime.auth_results
mime.dkim_info
mime.encode_header
mime.flow_decode
mime.flow_encode
mime.qp_decode
mime.qp_encode
```

**`openpgp`** (5)

```
openpgp.decrypt
openpgp.encrypt
openpgp.gen_key
openpgp.sign
openpgp.verify
```

**`outbox`** (5)

```
outbox.due
outbox.list
outbox.queue
outbox.remove
outbox.schedule
```

**`policy`** (3)

```
policy.dmarc_eval
policy.dmarc_parse
policy.spf_parse
```

**`pop3`** (1)

```
pop3.fetch
```

**`profile`** (2)

```
profile.get
profile.save
```

**`provenance`** (6)

```
provenance.diff_family
provenance.diff_revisions
provenance.families
provenance.family
provenance.findings
provenance.reindex
```

**`quote_gate`** (2)

```
quote_gate.get
quote_gate.set
```

**`reading`** (2)

```
reading.draft
reading.message
```

**`retention`** (3)

```
retention.apply
retention.get
retention.set
```

**`schedule`** (1)

```
schedule.resolve
```

**`screener`** (4)

```
screener.approve
screener.list
screener.pending
screener.remove
```

**`search`** (6)

```
search.query
search.remove
search.run
search.run_saved
search.save
search.saved
```

**`sieve`** (1)

```
sieve.parse
```

**`signature`** (3)

```
signature.add
signature.list
signature.remove
```

**`smime`** (5)

```
smime.decrypt
smime.encrypt
smime.gen_cert
smime.sign
smime.verify
```

**`smtp`** (1)

```
smtp.send
```

**`snooze`** (1)

```
snooze.due
```

**`template`** (4)

```
template.add
template.list
template.remove
template.render
```

**`thread`** (3)

```
thread.mute
thread.muted
thread.unmute
```

**`vacation`** (3)

```
vacation.get
vacation.reply
vacation.set
```

**`vcard`** (1)

```
vcard.convert
```

**`vip`** (3)

```
vip.add
vip.list
vip.remove
```

**`zemail`** (5)

```
zemail.timeline.scan
zemail.view.close
zemail.view.close_all
zemail.view.open
zemail.view.toggle
```

## zcite

Zotero-style reference manager — library, collections, citations, PDF, sync  
**309 verbs** · live bus surface · call as `App::open("zcite")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`annotation`** (4)

```
annotation.add
annotation.list
annotation.remove
annotation.update
```

**`appshell`** (96)

```
appshell.analytics
appshell.attachment-pane
appshell.backups
appshell.bibextras
appshell.bibliography
appshell.browse
appshell.bulk-file
appshell.bulk-tag
appshell.bulk-trash
appshell.bulk-untag
appshell.citekeys
appshell.cleanup
appshell.collections
appshell.completeness
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.cwyw
appshell.dashboard
appshell.decompile
appshell.doc-merge
appshell.draft
appshell.drift
appshell.duplicates
appshell.export
appshell.extra-fields
appshell.feeds
appshell.fidelity
appshell.files
appshell.files.close
appshell.files.open
appshell.gotokey
appshell.gui-scripts
appshell.hooks
appshell.identifiers
appshell.import
appshell.insights
appshell.integrity
appshell.item-report
appshell.libraries
appshell.library
appshell.library-lookup
appshell.lineage
appshell.lookup
appshell.near-duplicates
appshell.neon.off
appshell.neon.on
appshell.network
appshell.new-collection
appshell.new-item
appshell.notes
appshell.openurl-resolver
appshell.palette
appshell.pdftools
appshell.provenance
appshell.quality
appshell.quickcopy
appshell.quote-attest
appshell.random
appshell.reading
appshell.recent-added
appshell.refgraph
appshell.reload
appshell.rename-files
appshell.replace-field
appshell.reports
appshell.rtfscan
appshell.saved
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.settings
appshell.shortcuts
appshell.stylediff
appshell.stylefit
appshell.sync
appshell.tag-colors
appshell.tag-manage
appshell.tags
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.texcheck
appshell.texttools
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.toggle-theme
appshell.trash
appshell.webdav
appshell.zotero
```

**`attachment`** (6)

```
attachment.filename
attachment.index
attachment.rename
attachment.rename_from_parent
attachment.snapshot
attachment.store_file
```

**`authors`** (1)

```
authors.index
```

**`backup`** (5)

```
backup.create
backup.delete
backup.list
backup.prune
backup.restore
```

**`bib`** (13)

```
bib.attested_bibliography
bib.author_substitute
bib.bibliography
bib.citation
bib.cite_key
bib.cite_keys
bib.csl
bib.csl_document
bib.disambiguate
bib.sort_key
bib.style_diff
bib.style_fit
bib.styles
```

**`cite`** (3)

```
cite.document
cite.merge3
cite.rtf_scan
```

**`cleanup`** (2)

```
cleanup.batch
cleanup.item
```

**`cluster`** (1)

```
cluster.related
```

**`collection`** (8)

```
collection.add
collection.add_item
collection.list
collection.merge
collection.remove
collection.remove_item
collection.rename
collection.tree
```

**`csl`** (1)

```
csl.validate
```

**`doc`** (2)

```
doc.decompile
doc.restyle
```

**`duplicates`** (5)

```
duplicates.fuzzy
duplicates.list
duplicates.merge
duplicates.merge_preview
duplicates.similarity
```

**`export`** (20)

```
export.biblatex
export.bibtex
export.coins
export.csl_json
export.csl_yaml
export.csv
export.endnote_tagged
export.endnote_xml
export.html
export.item_markdown
export.json_ld
export.marcxml
export.markdown
export.mods
export.ris
export.rtf
export.tsv
export.wikipedia
export.word_field
export.zotero_rdf
```

**`feed`** (7)

```
feed.add_entry
feed.fetch
feed.list
feed.mark_read
feed.parse
feed.subscribe
feed.unsubscribe
```

**`identifier`** (6)

```
identifier.add
identifier.canonicalize
identifier.detect
identifier.isbn_convert
identifier.lookup
identifier.validate
```

**`import`** (15)

```
import.biblatex
import.bibtex
import.crossref_json
import.csl_json
import.csv
import.datacite_json
import.dublin_core
import.endnote_tagged
import.endnote_xml
import.file
import.marcxml
import.mods
import.pubmed_xml
import.ris
import.zotero_rdf
```

**`inbox`** (1)

```
inbox.import
```

**`integrity`** (2)

```
integrity.check
integrity.roundtrip
```

**`item`** (28)

```
item.add
item.add_attachment
item.add_note
item.add_tag
item.convert_type
item.delete
item.duplicate
item.extra_fields
item.get
item.lineage
item.list
item.migrate_extra
item.openurl
item.reading_stats
item.relate
item.related_graph
item.remove_note
item.remove_tag
item.restore
item.set_favorite
item.set_field
item.set_rating
item.set_reading
item.suggest_related
item.trash
item.unrelate
item.update
item.update_note
```

**`items`** (5)

```
items.add_tag
items.file
items.remove_tag
items.replace_field
items.trash
```

**`journal`** (1)

```
journal.abbreviate
```

**`libraries`** (6)

```
libraries.active
libraries.create
libraries.list
libraries.remove
libraries.rename
libraries.switch
```

**`library`** (5)

```
library.analytics
library.get
library.save
library.stats
library.timeline
```

**`locale`** (3)

```
locale.list
locale.ordinal
locale.term
```

**`names`** (3)

```
names.et_al
names.format
names.parse
```

**`network`** (3)

```
network.author_stats
network.coauthor
network.export
```

**`note`** (4)

```
note.add
note.list
note.remove
note.update
```

**`pdf`** (3)

```
pdf.extract_text
pdf.metadata
pdf.recognize
```

**`quality`** (2)

```
quality.assess
quality.audit
```

**`quote`** (2)

```
quote.attest
quote.verify
```

**`refgraph`** (7)

```
refgraph.build
refgraph.drift
refgraph.exposure
refgraph.gaps
refgraph.manuscript
refgraph.mine
refgraph.provenance
```

**`report`** (6)

```
report.field_completeness
report.items
report.key_collisions
report.language
report.orphans
report.year_coverage
```

**`schema`** (2)

```
schema.fields
schema.item_types
```

**`search`** (5)

```
search.quick
search.saved.add
search.saved.list
search.saved.remove
search.saved.run
```

**`sync`** (4)

```
sync.compact
sync.pull
sync.push
sync.status
```

**`tag`** (6)

```
tag.cloud
tag.delete
tag.list
tag.merge
tag.rename
tag.set_color
```

**`tex`** (4)

```
tex.aux
tex.bbl
tex.coverage
tex.extract_citations
```

**`text`** (4)

```
text.change_case
text.extract_identifiers
text.latex_to_unicode
text.unicode_to_latex
```

**`webdav`** (4)

```
webdav.delete
webdav.download
webdav.upload
webdav.verify
```

**`zotero`** (3)

```
zotero.pull
zotero.push
zotero.verify
```

## zreq

Postman-style API client — requests, collections, auth, codegen, gRPC/WebSocket  
**288 verbs** · live bus surface · call as `App::open("zreq")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`appshell`** (130)

```
appshell.auth.oauth2
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.embed.mail
appshell.embed.office
appshell.embed.open-response
appshell.embed.pdf
appshell.environment.edit
appshell.environment.import-dotenv
appshell.files
appshell.files.close
appshell.files.open
appshell.gui-scripts
appshell.history.clear
appshell.history.search
appshell.hooks
appshell.import.curl
appshell.import.har
appshell.import.insomnia
appshell.import.openapi
appshell.import.postman
appshell.neon.off
appshell.neon.on
appshell.palette
appshell.protocol.graphql
appshell.protocol.grpc
appshell.protocol.websocket
appshell.request.codegen
appshell.request.copy-curl
appshell.request.examples
appshell.request.new
appshell.request.rename
appshell.request.save
appshell.request.send
appshell.response.cookies
appshell.response.copy
appshell.response.diff
appshell.response.regex-lens
appshell.response.save-example
appshell.response.schema-infer
appshell.response.secret-scan
appshell.response.stats
appshell.response.tree
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.settings
appshell.settings.certificates
appshell.shortcuts
appshell.sidebar.collections
appshell.sidebar.environments
appshell.sidebar.history
appshell.snapshot.diff
appshell.snapshot.pin
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.tmux-keys
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
appshell.tools.assert
appshell.tools.cachesim
appshell.tools.chainplan
appshell.tools.coherence
appshell.tools.collectiondiff
appshell.tools.collectionlint
appshell.tools.corssim
appshell.tools.curlexplain
appshell.tools.effect-attribution
appshell.tools.encoding
appshell.tools.entity-coherence
appshell.tools.exportbruno
appshell.tools.exporthar
appshell.tools.exportopenapi
appshell.tools.fuzz
appshell.tools.fuzz-explore
appshell.tools.graphqlschema
appshell.tools.haranalyze
appshell.tools.hash
appshell.tools.hmac
appshell.tools.httpsigsign
appshell.tools.importbruno
appshell.tools.importhttpie
appshell.tools.jmespath
appshell.tools.jsondiff
appshell.tools.jsonpath
appshell.tools.jwt
appshell.tools.jwtencode
appshell.tools.negmedia
appshell.tools.open
appshell.tools.openapidiff
appshell.tools.openapimock
appshell.tools.peercall
appshell.tools.peers
appshell.tools.peerstep
appshell.tools.peerverbs
appshell.tools.pkce
appshell.tools.retryplan
appshell.tools.schemaval
appshell.tools.secretscan
appshell.tools.session-replay
appshell.tools.sla
appshell.tools.soapbuild
appshell.tools.varsaudit
appshell.tools.varsresolve
appshell.tools.wsframebuild
appshell.tools.xml2json
appshell.view.dashboard
appshell.view.focus-url
appshell.view.runner
appshell.view.toggle-sidebar
appshell.view.workspace
appshell.view.zoom-in
appshell.view.zoom-out
appshell.view.zoom-reset
appshell.workspace.delete
appshell.workspace.find-replace
appshell.workspace.new
appshell.workspace.rename
appshell.workspace.save
```

**`assert`** (1)

```
assert.run
```

**`asyncapi`** (1)

```
asyncapi.parse
```

**`cache`** (1)

```
cache.simulate
```

**`cbor`** (2)

```
cbor.decode
cbor.encode
```

**`cert`** (4)

```
cert.add
cert.list
cert.match
cert.remove
```

**`chain`** (1)

```
chain.plan
```

**`chunked`** (2)

```
chunked.decode
chunked.encode
```

**`codegen`** (1)

```
codegen.generate
```

**`collection`** (7)

```
collection.add
collection.diff
collection.get
collection.lint
collection.list
collection.remove
collection.update
```

**`conditional`** (2)

```
conditional.build
conditional.evaluate
```

**`cookie`** (5)

```
cookie.clear
cookie.list
cookie.parse
cookie.select
cookie.set
```

**`cors`** (1)

```
cors.simulate
```

**`curl`** (1)

```
curl.explain
```

**`dataset`** (1)

```
dataset.parse
```

**`effect`** (2)

```
effect.attribute
effect.intents
```

**`encoding`** (1)

```
encoding.convert
```

**`entity`** (2)

```
entity.coherence
entity.views
```

**`env`** (3)

```
env.dotenv.export
env.dotenv.parse
env.merge
```

**`environment`** (4)

```
environment.activate
environment.add
environment.list
environment.remove
```

**`example`** (3)

```
example.list
example.remove
example.save
```

**`export`** (4)

```
export.bruno
export.har
export.openapi
export.postman
```

**`formdata`** (2)

```
formdata.build
formdata.parse
```

**`fuzz`** (1)

```
fuzz.explore
```

**`globals`** (2)

```
globals.get
globals.set
```

**`graphql`** (3)

```
graphql.introspection_query
graphql.parse
graphql.schema.parse
```

**`grpc`** (1)

```
grpc.call
```

**`har`** (1)

```
har.analyze
```

**`hash`** (1)

```
hash.compute
```

**`history`** (4)

```
history.clear
history.list
history.remove
history.replay
```

**`hmac`** (1)

```
hmac.compute
```

**`httpsig`** (2)

```
httpsig.sign
httpsig.verify
```

**`hypermedia`** (2)

```
hypermedia.parse
hypermedia.plan
```

**`import`** (7)

```
import.bruno
import.curl
import.har
import.httpie
import.insomnia
import.openapi
import.postman
```

**`jmespath`** (1)

```
jmespath.query
```

**`json`** (2)

```
json.diff
json.to_xml
```

**`jsonpath`** (1)

```
jsonpath.query
```

**`jsonschema`** (1)

```
jsonschema.validate
```

**`jwt`** (2)

```
jwt.decode
jwt.encode
```

**`msgpack`** (2)

```
msgpack.decode
msgpack.encode
```

**`negotiate`** (3)

```
negotiate.encoding
negotiate.language
negotiate.media
```

**`oauth2`** (1)

```
oauth2.token
```

**`openapi`** (2)

```
openapi.diff
openapi.mock
```

**`peer`** (5)

```
peer.call
peer.get
peer.list
peer.step
peer.verbs
```

**`pkce`** (2)

```
pkce.generate
pkce.verify
```

**`proto`** (1)

```
proto.parse
```

**`protobuf`** (2)

```
protobuf.decode
protobuf.encode
```

**`ratelimit`** (1)

```
ratelimit.parse
```

**`repr`** (4)

```
repr.check
repr.facts
repr.probe
repr.route
```

**`request`** (6)

```
request.add
request.fuzz
request.get
request.remove
request.send
request.update
```

**`response`** (2)

```
response.clear
response.last
```

**`retry`** (1)

```
retry.plan
```

**`runner`** (2)

```
runner.loop
runner.run
```

**`schema`** (2)

```
schema.example
schema.infer
```

**`script`** (1)

```
script.lint
```

**`secret`** (1)

```
secret.scan
```

**`session`** (9)

```
session.artifact
session.artifact_run
session.blastradius
session.clear
session.counterfactual
session.list
session.provenance
session.record
session.remove
```

**`settings`** (4)

```
settings.get
settings.path
settings.reset
settings.update
```

**`sla`** (1)

```
sla.evaluate
```

**`soap`** (2)

```
soap.build
soap.parse
```

**`sse`** (1)

```
sse.parse
```

**`template`** (1)

```
template.render
```

**`urlencoded`** (2)

```
urlencoded.build
urlencoded.parse
```

**`vars`** (2)

```
vars.audit
vars.resolve
```

**`workspace`** (10)

```
workspace.create
workspace.current
workspace.delete
workspace.find
workspace.get
workspace.list
workspace.rename
workspace.replace
workspace.save
workspace.switch
```

**`ws`** (1)

```
ws.exchange
```

**`wsframe`** (2)

```
wsframe.build
wsframe.parse
```

**`xml`** (1)

```
xml.to_json
```

## audio-haxor

Audio analyzer / DAW-project generator — spectrum, DSP, .als generation  
**287 verbs** · live bus surface · call as `App::open("audio-haxor")->call("<verb>", %args)`

**`app`** (242)

```
app.alsCancelGenerate
app.alsGenerate
app.alsLearnStyle
app.alsOverrideDelete
app.alsOverridesClearAll
app.alsPickOutput
app.alsRandomizeSeed
app.alsStartAnalysis
app.alsStopAnalysis
app.applyCustomScheme
app.browseDir
app.browseSnapshotExportDir
app.buildXrefIndex
app.cancelSavePreset
app.checkUpdates
app.clearAbLoop
app.clearAllHistory
app.clearAllNotes
app.clearAppLog
app.clearFavorites
app.clearGlobalTag
app.clearRecentlyPlayed
app.clearSettingsSearch
app.clearSnapshotExportDir
app.collapsePlayer
app.confirmSavePreset
app.createSmartPlaylist
app.createTag
app.deleteCustomSchemes
app.exportAudio
app.exportDaw
app.exportFavorites
app.exportLogPdf
app.exportMidi
app.exportNotes
app.exportPdfs
app.exportPlugins
app.exportPresets
app.exportRecentlyPlayed
app.exportSettingsPdf
app.exportVideos
app.favCurrentTrack
app.fbBulkRenameApply
app.fbBulkRenameCancel
app.fbPreviewClose
app.fbTreeClose
app.fileAppDataDir
app.fileBulkClear
app.fileBulkDelete
app.fileBulkFavorite
app.fileBulkOpen
app.fileBulkRename
app.fileBulkScan
app.fileFav
app.fileHome
app.fileNavBack
app.fileNavFwd
app.fileNewFolder
app.fileQuickNav
app.fileTogglePreview
app.fileUp
app.filterAudioSamples
app.filterCrate
app.filterDawProjects
app.filterFavorites
app.filterFiles
app.filterMidi
app.filterNotes
app.filterNowPlaying
app.filterPdfs
app.filterPlugins
app.filterPresets
app.filterSettings
app.filterShortcuts
app.filterTags
app.filterVideos
app.findDuplicates
app.hidePlayer
app.hideTagBar
app.hideTerminal
app.importAudio
app.importDaw
app.importFavorites
app.importNotes
app.importPdfs
app.importPlugins
app.importPresets
app.importRecentlyPlayed
app.importVideos
app.killTerminal
app.moveTagBar
app.nextTrack
app.openCrateBuilder
app.openDataDir
app.openLogFile
app.openNextUpdate
app.openPrefsFile
app.openReleaseWizard
app.openUpdate
app.prevTrack
app.refreshCacheStats
app.resetAllScans
app.resetEq
app.resetFzfParams
app.resetShortcuts
app.resumeAll
app.resumeAudioScan
app.resumeDawScan
app.resumeMidiScan
app.resumePdfScan
app.resumePluginScan
app.resumePresetScan
app.resumeVideoScan
app.runBpmKeyLufsAnalysis
app.runContentDupScan
app.saveAudioScanDirs
app.saveBlacklist
app.saveCustomDirs
app.saveDawScanDirs
app.saveFolderWatchDirs
app.saveMidiScanDirs
app.savePdfScanDirs
app.savePresetScanDirs
app.saveSnapshotExportDir
app.saveVideoScanDirs
app.scanAll
app.scanAudioSamples
app.scanDawProjects
app.scanMidi
app.scanPdfs
app.scanPlugins
app.scanPresets
app.scanVideos
app.setAbA
app.setAbB
app.setEqHigh
app.setEqLow
app.setEqMid
app.setGain
app.setPan
app.setPlaybackSpeed
app.setSpeedMode
app.setVolume
app.settingAnalysisPause
app.settingAudioSort
app.settingAutoplayNextSource
app.settingBatchAnalysisThreads
app.settingBatchSize
app.settingBgJobThrottle
app.settingChannelBuffer
app.settingClearAllDatabases
app.settingClearAllHistory
app.settingClearAnalysisCache
app.settingClearKvrCache
app.settingContentDupHashThreads
app.settingDawSort
app.settingDefaultTypeFilter
app.settingFdLimit
app.settingFlushInterval
app.settingLogVerbosity
app.settingMaxRecent
app.settingMidiSort
app.settingPageSize
app.settingPdfSort
app.settingPluginSort
app.settingPresetSort
app.settingPruneOldScansKeep
app.settingResetAllUI
app.settingResetColumns
app.settingResetSectionOrder
app.settingResetTabOrder
app.settingSqliteReadPoolExtra
app.settingTagBarPosition
app.settingThreadMultiplier
app.settingToggleAutoAnalysis
app.settingToggleAutoCheckUpdatesOnStartup
app.settingToggleAutoContentDupScan
app.settingToggleAutoFingerprintCache
app.settingToggleAutoPdfMetadataOnStartup
app.settingToggleAutoPdfScanOnStartup
app.settingToggleAutoPlaySampleOnSelect
app.settingToggleAutoScan
app.settingToggleAutoUpdate
app.settingToggleAutoplayNext
app.settingToggleCrt
app.settingToggleExpandOnClick
app.settingToggleFolderWatch
app.settingToggleIncludeBackups
app.settingToggleIncrementalDirectoryScan
app.settingToggleNeonGlow
app.settingTogglePdfMetadataAutoExtract
app.settingTogglePruneOldScans
app.settingToggleSingleClickPlay
app.settingToggleTagBar
app.settingToggleTheme
app.settingTooltipHoverDelay
app.settingTrayTransportSource
app.settingUiLocale
app.settingVideoAudioRoute
app.settingVizFps
app.settingWfCacheMax
app.showDepGraph
app.showGenreRules
app.showHeatmapDash
app.showPlayer
app.showSavePreset
app.showSmartPlaylistEditor
app.showTerminal
app.showToastHistory
app.skipUpdate
app.stopAll
app.stopAudioPlayback
app.stopAudioScan
app.stopBpmKeyLufsAnalysis
app.stopContentDupScan
app.stopDawScan
app.stopMidiScan
app.stopPdfMetadataExtraction
app.stopPdfScan
app.stopPluginScan
app.stopPresetScan
app.stopVideoScan
app.switchTab
app.tagCurrentTrack
app.tlFindSamples
app.tlGenerateAll
app.tlGenerateKits
app.tlGenerateMidi
app.tlPickOutput
app.tlRandomizeSeed
app.toggleAudioLoop
app.toggleAudioPlayback
app.toggleDirs
app.toggleEqSection
app.toggleMono
app.toggleMute
app.togglePdf
app.toggleRegex
app.toggleReversePlayback
app.toggleSequencer
app.toggleShuffle
app.vizFullscreen
```

**`clip`** (6)

```
clip.add
clip.list
clip.move
clip.remove
clip.set_gain
clip.set_transpose
```

**`masking`** (5)

```
masking.candidates
masking.fingerprint
masking.index_paths
masking.rebuild_edges
masking.score
```

**`office`** (2)

```
office.close
office.open
```

**`project`** (16)

```
project.certify
project.compatible_keys
project.export_als
project.export_als_certified
project.get
project.reset
project.sections
project.set_atonal
project.set_bpm
project.set_genre
project.set_hardness
project.set_key
project.set_name
project.set_output_path
project.set_section_length
project.set_track_count
```

**`sample`** (1)

```
sample.query
```

**`session`** (5)

```
session.bisect
session.journal
session.omit
session.probe
session.solve
```

**`style`** (2)

```
style.apply
style.learn
```

**`track`** (8)

```
track.add
track.clear
track.get
track.list
track.move
track.remove
track.rename
track.set_color
```

## ztunnel

Tunnelblick-style VPN client — OpenVPN / WireGuard config + control  
**260 verbs** · live bus surface · call as `App::open("ztunnel")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`appshell`** (148)

```
appshell.autoconnect
appshell.backup
appshell.cl-cmd_blocks
appshell.cl-cmd_cert
appshell.cl-cmd_fleet_forecast
appshell.cl-cmd_forecast
appshell.cl-cmd_log
appshell.cl-cmd_migrate
appshell.cl-cmd_normalize
appshell.cl-cmd_parse
appshell.cl-cmd_pki
appshell.cl-cmd_push
appshell.cl-cmd_redact
appshell.cl-cmd_wgnormalize
appshell.co-diag
appshell.co-ipcheck
appshell.co-login-status
appshell.co-login-toggle
appshell.co-scripts
appshell.compare
appshell.connect
appshell.copy_ip
appshell.cr-cmd_cookie
appshell.cr-cmd_handshake
appshell.cr-cmd_ike
appshell.cr-cmd_narrow
appshell.cr-cmd_noise
appshell.cr-cmd_proxy
appshell.cr-cmd_statickey
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.dashboard
appshell.delete
appshell.diagnostics
appshell.disconnect
appshell.dl-cmd_block
appshell.dl-cmd_bootstrap
appshell.dl-cmd_parse
appshell.dl-cmd_split
appshell.dl-cmd_wire
appshell.dns
appshell.duplicate
appshell.files
appshell.files.close
appshell.files.open
appshell.gui-scripts
appshell.hooks
appshell.import
appshell.ip-cmd
appshell.kill_switch
appshell.lint
appshell.nd-title
appshell.neon.off
appshell.neon.on
appshell.nm-cmd_axfr
appshell.nm-cmd_bench
appshell.nm-cmd_conns
appshell.nm-cmd_dns
appshell.nm-cmd_firewall
appshell.nm-cmd_tls
appshell.ns-cmd_arp
appshell.ns-cmd_knock
appshell.ns-cmd_rdap
appshell.ns-cmd_reverse
appshell.ns-cmd_subnet
appshell.ns-cmd_sweep
appshell.nt-cmd_doh
appshell.nt-cmd_headers
appshell.nt-cmd_mtu
appshell.nt-cmd_speed
appshell.nt-cmd_tls
appshell.nt-cmd_vpn
appshell.obfs
appshell.op-cmd_apppolicy
appshell.op-cmd_budget
appshell.op-cmd_failover
appshell.op-cmd_features
appshell.op-cmd_mss
appshell.op-cmd_platform
appshell.op-cmd_portfwd
appshell.op-cmd_quality
appshell.op-cmd_rank
appshell.op-cmd_reconnect
appshell.op-cmd_rollup
appshell.op-cmd_uptime
appshell.palette
appshell.ping_all
appshell.protocols
appshell.quick_connect
appshell.recommend
appshell.redact
appshell.reload
appshell.rename
appshell.rl-cmd_aggregate
appshell.rl-cmd_allowed
appshell.rl-cmd_conflicts
appshell.rl-cmd_contains
appshell.rl-cmd_coverage
appshell.rl-cmd_dedup
appshell.rl-cmd_eui64
appshell.rl-cmd_nat64
appshell.rl-cmd_split
appshell.rl-cmd_subnet
appshell.rl-cmd_ula
appshell.route_audit
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.servers
appshell.sessions
appshell.settings
appshell.shortcuts
appshell.st-title
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.tk_agg
appshell.tk_classify
appshell.tk_meltdown
appshell.tk_mtu
appshell.tk_pmtu
appshell.tk_range
appshell.tk_rekey
appshell.tk_split
appshell.tk_stackmtu
appshell.tk_subnet
appshell.tk_ula
appshell.tl-cmd_timeline
appshell.toggle-theme
appshell.toolkit
appshell.vt-cmd_cidrs
appshell.vt-cmd_classify
appshell.vt-cmd_lint
appshell.vt-cmd_mtu
appshell.vt-cmd_obfs
appshell.vt-cmd_pmtu
appshell.vt-cmd_probe
appshell.vt-cmd_wgkey
appshell.wg
```

**`config`** (16)

```
config.add
config.diff
config.duplicate
config.get
config.import
config.lint
config.lint_text
config.list
config.migrate
config.openvpn_format
config.parse
config.redact
config.remove
config.rename
config.set_options
config.wireguard_format
```

**`creds`** (2)

```
creds.clear
creds.set
```

**`dns`** (6)

```
dns.block_match
dns.bootstrap_plan
dns.leak_check
dns.parse_server
dns.query_wire
dns.split_horizon
```

**`feature`** (1)

```
feature.matrix
```

**`firewall`** (2)

```
firewall.mss_clamp
firewall.port_forward
```

**`ipsec`** (2)

```
ipsec.narrow_ts
ipsec.profile
```

**`log`** (1)

```
log.analyze
```

**`multihop`** (4)

```
multihop.chain
multihop.mtu_budget
multihop.rekey_schedule
multihop.validate
```

**`net`** (12)

```
net.cidr_aggregate
net.cidr_contains
net.ip_classify
net.ipv6_eui64
net.nat64
net.pmtu_discover
net.range_to_cidrs
net.subnet_info
net.subnet_split
net.tcp_meltdown
net.tunnel_mtu
net.ula
```

**`obfs`** (1)

```
obfs.catalog
```

**`openvpn`** (4)

```
openvpn.inline_blocks
openvpn.negotiate
openvpn.push_reply
openvpn.static_key_parse
```

**`pki`** (4)

```
pki.audit_config
pki.connect_forecast
pki.fleet_forecast
pki.parse_cert
```

**`platform`** (1)

```
platform.info
```

**`policy`** (2)

```
policy.app_decisions
policy.wifi_action
```

**`profile`** (3)

```
profile.export
profile.get
profile.import
```

**`proxy`** (1)

```
proxy.plan
```

**`route`** (4)

```
route.conflicts
route.coverage
route.leak_delta
route.leak_surface
```

**`servers`** (11)

```
servers.add
servers.failover_plan
servers.fastest
servers.favorite
servers.list
servers.ping
servers.quality
servers.rank_quality
servers.recommend
servers.remove
servers.select_strategy
```

**`settings`** (2)

```
settings.get
settings.set
```

**`split`** (3)

```
split.evaluate
split.evaluate_app
split.route_plan
```

**`stats`** (4)

```
stats.budget
stats.rollup
stats.session_summary
stats.uptime_sla
```

**`vpn`** (14)

```
vpn.autoconnect
vpn.can_transition
vpn.clear_logs
vpn.connect
vpn.connections
vpn.disconnect
vpn.impact_preview
vpn.killswitch_plan
vpn.killswitch_syntax
vpn.leak_watch
vpn.logs
vpn.network_changed
vpn.reconnect_schedule
vpn.status
```

**`wg`** (11)

```
wg.allowed_ips
wg.allowed_ips_dedup
wg.cookie_decision
wg.cookie_model
wg.genkey
wg.handshake_model
wg.noise_layout
wg.probe
wg.probe_all
wg.pubkey
wg.rank
```

## zstation

Station-style multi-app workspace — boards, tiles, panes  
**251 verbs** · live bus surface · call as `App::open("zstation")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`appshell`** (171)

```
appshell.activity_heatmap
appshell.add_site
appshell.attention_layout
appshell.board-b10
appshell.board-b11
appshell.board-b12
appshell.board-b13
appshell.board-b14
appshell.board-b15
appshell.board-b2
appshell.board-b3
appshell.board-b4
appshell.board-b5
appshell.board-b7
appshell.board-b8
appshell.board-b9
appshell.board-main
appshell.clear_all_sessions
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.dup_dash_title
appshell.export_dash_image
appshell.export_layout
appshell.files
appshell.files.close
appshell.files.open
appshell.gui-scripts
appshell.hooks
appshell.import_layout
appshell.lock_settings
appshell.lock_workspace
appshell.neon.off
appshell.neon.on
appshell.new-base64
appshell.new-baseconv
appshell.new-bigtext
appshell.new-bipolar
appshell.new-calculator
appshell.new-calendar
appshell.new-chart
appshell.new-chstrip
appshell.new-clock
appshell.new-code
appshell.new-color
appshell.new-converter
appshell.new-countdown
appshell.new-counter
appshell.new-cron
appshell.new-curve
appshell.new-dialpad
appshell.new-dice
appshell.new-drawbars
appshell.new-envelope
appshell.new-eq
appshell.new-euclid
appshell.new-fader
appshell.new-filter
appshell.new-gate
appshell.new-geomorph
appshell.new-habit
appshell.new-harmonics
appshell.new-hash
appshell.new-image
appshell.new-joystick
appshell.new-json
appshell.new-kanban
appshell.new-keyboard
appshell.new-knob
appshell.new-kv
appshell.new-lfo
appshell.new-links
appshell.new-lorem
appshell.new-markdown
appshell.new-morph
appshell.new-morphpath
appshell.new-note
appshell.new-orb
appshell.new-osc
appshell.new-pad
appshell.new-padgrid
appshell.new-password
appshell.new-pianoroll
appshell.new-pomodoro
appshell.new-progress
appshell.new-rating
appshell.new-reminder
appshell.new-richtext
appshell.new-sketch
appshell.new-slider
appshell.new-stat
appshell.new-stepper
appshell.new-stepseq
appshell.new-stopwatch
appshell.new-tags
appshell.new-terminal
appshell.new-timer
appshell.new-timestamp
appshell.new-todo
appshell.new-transport
appshell.new-trigger
appshell.new-uuid
appshell.new-wavetable
appshell.new-websearch
appshell.new-worldclock
appshell.new-xypad
appshell.new_dash_title
appshell.pack
appshell.palette
appshell.popout_dash
appshell.preset-ai-chats
appshell.preset-ai-lab
appshell.preset-command-center
appshell.preset-control
appshell.preset-dashboard
appshell.preset-dev
appshell.preset-focus
appshell.preset-full-stack
appshell.preset-music-studio
appshell.preset-newsroom
appshell.preset-social
appshell.preset-trading-desk
appshell.preset-work-comms
appshell.quick_capture
appshell.reload_all
appshell.rename_dash_title
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.select_all_tiles
appshell.session_attribution
appshell.session_convoy
appshell.session_drift
appshell.session_lens
appshell.session_probe
appshell.session_rewind
appshell.session_trail
appshell.set_dash_accent
appshell.set_dash_icon
appshell.settings
appshell.shortcuts
appshell.tab_about
appshell.tab_agenda
appshell.tab_board
appshell.tab_boards
appshell.tab_dashboard
appshell.tab_lens
appshell.tab_logs
appshell.tab_notes
appshell.tab_search
appshell.tab_sessions
appshell.tab_toasts
appshell.take_tour
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.tidy
appshell.tile-t64
appshell.tile-t65
appshell.tile-t66
appshell.tile_settings
appshell.toggle-theme
appshell.workspace_census
```

**`board`** (10)

```
board.all
board.create
board.delete
board.get
board.list
board.recent
board.rename
board.reset
board.set_icon
board.switch
```

**`branch`** (7)

```
branch.commit
branch.fork
branch.list
branch.prune
branch.remove
branch.restore
branch.snapshot
```

**`census`** (1)

```
census.audit
```

**`convoy`** (4)

```
convoy.go
convoy.list
convoy.remove
convoy.set
```

**`db`** (2)

```
db.stats
db.vacuum
```

**`layout`** (2)

```
layout.arrange
layout.save
```

**`lens`** (12)

```
lens.attribute
lens.capture_remove
lens.captures
lens.close
lens.drift
lens.list
lens.probe
lens.remove
lens.report
lens.rewind
lens.run
lens.set
```

**`library`** (1)

```
library.search
```

**`lock`** (5)

```
lock.clear
lock.configure
lock.set
lock.status
lock.verify
```

**`log`** (2)

```
log.path
log.read
```

**`notes`** (4)

```
notes.add
notes.get
notes.remove
notes.update
```

**`notifications`** (1)

```
notifications.summary
```

**`prefs`** (2)

```
prefs.get
prefs.update
```

**`service`** (2)

```
service.catalog
service.get
```

**`settings`** (2)

```
settings.get
settings.update
```

**`tile`** (8)

```
tile.add
tile.bring_front
tile.remove
tile.send_back
tile.set_muted
tile.set_unread
tile.touch
tile.update
```

**`toast`** (3)

```
toast.append
toast.clear
toast.list
```

**`trail`** (4)

```
trail.list
trail.remove
trail.set
trail.step
```

**`wiring`** (7)

```
wiring.add
wiring.analyze
wiring.list
wiring.process
wiring.remove
wiring.set_enabled
wiring.update
```

## zwire

Chromium-superset browser — tabs, windows, tab-groups, downloads, reading list, power  
**247 verbs** · live bus surface · call as `App::open("zwire")->call("<verb>", %args)`

**`(top-level)`** (134)

```
clipboard_get
clipboard_set
exec
fs_append
fs_chmod
fs_compare_dirs
fs_compress
fs_copy_path
fs_create_dir
fs_create_file
fs_delete_file
fs_diff
fs_disk_usage
fs_duplicate
fs_extract
fs_find_duplicates
fs_folder_size
fs_get_info
fs_git_status
fs_grep
fs_hash
fs_home_dir
fs_list
fs_list_dir
fs_list_subdirs
fs_mkdir
fs_move_to_trash
fs_read
fs_read_file_base64
fs_read_head
fs_read_head_bytes
fs_rename_file
fs_rm
fs_secure_delete
fs_stat
fs_symlink_retarget
fs_tail
fs_touch
fs_walk
fs_watch
fs_write
fs_xattrs
get
hello
hook_fire
hooks_delete
hooks_events
hooks_get_script
hooks_list
hooks_save
hooks_script_path
hooks_set_enabled
hooks_set_script
hooks_test_run
hostinfo
hostlog
job_list
job_poll
job_result
job_start
kill
kv_del
kv_get
kv_keys
kv_merge
kv_set
meter_stream
notify
open
page_get
page_reply
page_serve
page_states
peer_connect
peers
ping
ps
pty_kill
pty_resize
pty_spawn
pty_write
pub
remote
stryke_lsp_send
stryke_lsp_start
stryke_lsp_stop
stryke_run
sub
suite_call
suite_get
suite_list
suite_verbs
sysinfo_once
sysinfo_start
sysinfo_stop
theme
tmux_broadcast_list
tmux_buffer
tmux_buffers
tmux_capture
tmux_command
tmux_delete_buffer
tmux_export_state
tmux_focus
tmux_import_state
tmux_keys
tmux_options
tmux_panes
tmux_paste_buffer
tmux_run
tmux_search
tmux_send
tmux_sessions
tmux_set_buffer
tmux_set_key
tmux_set_option
tmux_snap_delete
tmux_snap_detail
tmux_snap_list
tmux_snap_rename
tmux_snap_restore
tmux_snap_save
tmux_status
tmux_sync
tmux_tree
tmux_unbind_key
txn_abort
txn_begin
txn_commit
unsub
verbs
watch_list
watch_stop
which
```

**`browser`** (100)

```
browser.activate
browser.addHistoryUrl
browser.addReadingList
browser.allowSleep
browser.bookmarkFolder
browser.bookmarkTab
browser.cancelDownload
browser.centerWindow
browser.clearAllData
browser.clearCache
browser.clearCacheAndCookies
browser.clearCookies
browser.clearDownloads
browser.clearHistory
browser.clearPasswords
browser.closeDuplicates
browser.closeLeft
browser.closeOthers
browser.closeRight
browser.closeTab
browser.closeWindow
browser.collapseGroups
browser.deleteHistoryUrl
browser.detectLanguage
browser.disableExtension
browser.discardTab
browser.download
browser.duplicateTab
browser.enableExtension
browser.expandGroups
browser.extensionOptions
browser.firstTab
browser.fullscreenWindow
browser.goBack
browser.goForward
browser.gotoTab
browser.groupTabs
browser.home
browser.incognitoWindow
browser.keepAwake
browser.keepDisplayAwake
browser.lastTab
browser.launchApp
browser.maximizeWindow
browser.mergeWindows
browser.minimizeWindow
browser.moveTabFirst
browser.moveTabLast
browser.moveTabLeft
browser.moveTabRight
browser.moveWindowNextDisplay
browser.muteAll
browser.muteOthers
browser.muteTab
browser.newTab
browser.newWindow
browser.nextTab
browser.nextWindow
browser.notify
browser.open
browser.openDownload
browser.openTab
browser.pauseDownload
browser.pinAll
browser.pinTab
browser.prevTab
browser.prevWindow
browser.reload
browser.reloadAll
browser.reloadHard
browser.removeBookmark
browser.removeReadingList
browser.reopenTab
browser.restoreWindow
browser.resumeDownload
browser.retryDownload
browser.screenshot
browser.showDownload
browser.showDownloads
browser.snapBottom
browser.snapBottomLeft
browser.snapBottomRight
browser.snapLeft
browser.snapRight
browser.snapTop
browser.snapTopLeft
browser.snapTopRight
browser.sortTabs
browser.tabToNewWindow
browser.tmux
browser.undo
browser.ungroupTabs
browser.uninstallExtension
browser.unmuteAll
browser.unmuteTab
browser.unpinAll
browser.unpinTab
browser.zoomIn
browser.zoomOut
browser.zoomReset
```

**`page`** (13)

```
page.assert
page.batch
page.extract
page.forms
page.headings
page.links
page.meta
page.selection
page.tables
page.text
page.title
page.url
page.witness
```

## ztranslator

BOME-style MIDI/keyboard translator — presets, translators, rules, HID  
**242 verbs** · live bus surface · call as `App::open("ztranslator")->call("<verb>", %args)`

**`(top-level)`** (170)

```
ztr_accessibility_request
ztr_accessibility_trusted
ztr_adsr_value
ztr_arpeggiate
ztr_bank_select
ztr_bpm_to_clock
ztr_bus_apps
ztr_bus_call
ztr_bus_get
ztr_bus_verbs
ztr_cc_channel_mode
ztr_cc_hires_combine
ztr_cc_hires_lsb
ztr_cc_hires_split
ztr_cc_name
ztr_cc_number
ztr_cents_to_pitchbend
ztr_channel_allowed
ztr_channel_filter
ztr_channel_is_voice
ztr_channel_mask
ztr_channel_matrix_apply
ztr_channel_remap
ztr_chord_close
ztr_chord_drop
ztr_chord_intervals
ztr_chord_invert
ztr_chord_notes
ztr_chord_spread
ztr_clock_bar_position
ztr_clock_ms_to_ticks
ztr_clock_note_beats
ztr_clock_note_duration
ztr_clock_tap_tempo
ztr_clock_ticks_to_ms
ztr_clock_to_bpm
ztr_close_input
ztr_close_source
ztr_combine_14bit
ztr_config_dir
ztr_create_virtual_input
ztr_create_virtual_output
ztr_deadzone
ztr_debounce
ztr_drum_name
ztr_drum_note
ztr_drum_remap
ztr_ema
ztr_engine_start
ztr_engine_stop
ztr_export_bmtp
ztr_format_rules
ztr_frequency_to_note
ztr_get_project
ztr_gm_family
ztr_gm_name
ztr_gm_program
ztr_groove_apply
ztr_humanize
ztr_hysteresis
ztr_identify_chord
ztr_import_bmtp
ztr_inject_sysevent
ztr_key_signature
ztr_lfo_value
ztr_list_ports
ztr_list_projects
ztr_load_json
ztr_log_path
ztr_median3
ztr_mpe_allocate
ztr_mpe_config_rpn
ztr_mpe_lower_zone
ztr_mpe_pitch_bend_range
ztr_mpe_upper_zone
ztr_mtc_decode
ztr_mtc_encode
ztr_mts_data_to_frequency
ztr_mts_frequency_data
ztr_mts_single_note
ztr_note_frequency
ztr_note_name
ztr_note_number
ztr_note_roll
ztr_open_appbus
ztr_open_artnet_input
ztr_open_audio_input
ztr_open_cv_output
ztr_open_focus_watch
ztr_open_gamepad_input
ztr_open_hid_input
ztr_open_http_input
ztr_open_input
ztr_open_link_input
ztr_open_mqtt_input
ztr_open_osc_input
ztr_open_output
ztr_open_port_watch
ztr_open_project
ztr_open_rtpmidi_input
ztr_open_sacn_input
ztr_open_schedule
ztr_open_serial_input
ztr_open_sysevent
ztr_open_tcp_input
ztr_open_ws_input
ztr_panic
ztr_parse_rules
ztr_parse_shortcut
ztr_parse_stream
ztr_parse_typed
ztr_processing_enabled
ztr_program_change
ztr_quantize
ztr_ramp
ztr_repeat_count
ztr_rpn_build
ztr_rpn_parse
ztr_run_rules
ztr_running_apps
ztr_save_json
ztr_save_to_library
ztr_scala_parse
ztr_scale_down
ztr_scale_mask
ztr_scale_notes
ztr_scale_snap
ztr_scale_up
ztr_scale_value
ztr_sequencer_step
ztr_serialize_stream
ztr_set_preset_enabled
ztr_set_processing
ztr_set_project
ztr_set_route
ztr_slew
ztr_smf_header
ztr_smf_parse_header
ztr_spell_note
ztr_split_14bit
ztr_spp_decode
ztr_spp_encode
ztr_strum
ztr_swing_quantize
ztr_sysex_gm_reset
ztr_sysex_gs_reset
ztr_sysex_identity_request
ztr_sysex_manufacturer
ztr_sysex_master_volume
ztr_sysex_pack
ztr_sysex_parse
ztr_sysex_roland_checksum
ztr_sysex_unpack
ztr_sysex_unwrap
ztr_sysex_wrap
ztr_sysex_xg_reset
ztr_test_translator
ztr_transpose
ztr_ump2_from_note
ztr_ump2_to_note
ztr_ump_from_midi1
ztr_ump_to_midi1
ztr_velocity_16_to_7
ztr_velocity_7_to_16
ztr_velocity_compress
ztr_velocity_curve
ztr_vlq_decode
ztr_vlq_encode
ztr_voice_lead
ztr_watch_path
```

**`appshell`** (72)

```
appshell.addPreset
appshell.addTranslator
appshell.aliases
appshell.analyzer
appshell.appbus
appshell.arming
appshell.bulkToggle
appshell.capture
appshell.certify
appshell.code
appshell.conflicts
appshell.copySel
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.cutSel
appshell.delSel
appshell.diff
appshell.dupSel
appshell.exportBmtp
appshell.feedback
appshell.files
appshell.files.close
appshell.files.open
appshell.grantAccess
appshell.gui-scripts
appshell.help
appshell.hooks
appshell.import
appshell.jsonView
appshell.loadJson
appshell.midiPorts
appshell.midiRef
appshell.neon.off
appshell.neon.on
appshell.new
appshell.palette
appshell.panic
appshell.pasteSel
appshell.presetJump
appshell.presetMgr
appshell.processing
appshell.properties
appshell.refreshPorts
appshell.renameSel
appshell.roundTrip
appshell.routes
appshell.saveJson
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.sequencer
appshell.settings
appshell.shortcuts
appshell.showLog
appshell.showMonitor
appshell.start
appshell.stats
appshell.stop
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.toggle-theme
appshell.verify
```

## zftp

Cyberduck-style transfer client — FTP/SFTP/WebDAV/S3/cloud, transfers, sync  
**224 verbs** · live bus surface · call as `App::open("zftp")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`appshell`** (61)

```
appshell.bookmark.options
appshell.bookmark.remove
appshell.bookmarks.export
appshell.bookmarks.import
appshell.connect
appshell.connect.selected
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.dedup
appshell.dir.compare
appshell.dir.list
appshell.dir.new
appshell.dir.size
appshell.disconnect.selected
appshell.discover
appshell.erasure.disperse
appshell.erasure.reconstruct
appshell.file.duplicate
appshell.file.edit
appshell.file.new
appshell.files
appshell.files.close
appshell.files.open
appshell.gui-scripts
appshell.hooks
appshell.mail
appshell.neon.off
appshell.neon.on
appshell.office
appshell.palette
appshell.path.copy
appshell.path.copy_url
appshell.path.goto
appshell.pdf
appshell.prefs
appshell.reload
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.session.monitor
appshell.settings
appshell.shortcuts
appshell.swarm.audit
appshell.swarm.replicate
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.tmux-keys
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
appshell.transfer.estimate
```

**`archive`** (2)

```
archive.tar_index
archive.zip_index
```

**`azure`** (1)

```
azure.sign
```

**`b2`** (1)

```
b2.authorization
```

**`bandwidth`** (2)

```
bandwidth.fair_share
bandwidth.token_bucket
```

**`bookmark`** (10)

```
bookmark.add
bookmark.get
bookmark.import
bookmark.import_filezilla
bookmark.import_winscp
bookmark.list
bookmark.option_support
bookmark.remove
bookmark.set_options
bookmark.update
```

**`checksum`** (2)

```
checksum.compute
checksum.verify_file
```

**`codec`** (2)

```
codec.base64_decode
codec.base64_encode
```

**`content`** (8)

```
content.coalesce
content.deadline
content.diff
content.fetch
content.index
content.plan
content.sync
content.triage
```

**`creds`** (6)

```
creds.clear
creds.delete
creds.load
creds.parse_netrc
creds.set
creds.store
```

**`dedup`** (1)

```
dedup.plan
```

**`delta`** (4)

```
delta.plan
delta.push
delta.push_plan
delta.signature
```

**`dircache`** (1)

```
dircache.diff
```

**`discovery`** (1)

```
discovery.scan
```

**`edit`** (1)

```
edit.map
```

**`erasure`** (7)

```
erasure.disperse
erasure.health
erasure.plan
erasure.reconstruct
erasure.repair
erasure.set_remove
erasure.sets
```

**`favorite`** (3)

```
favorite.add
favorite.list
favorite.remove
```

**`filter`** (5)

```
filter.apply
filter.expand
filter.glob_to_regex
filter.match
filter.parse_rules
```

**`fs`** (15)

```
fs.chmod
fs.copy
fs.delete
fs.du
fs.duplicate_name
fs.find
fs.list
fs.mkdir
fs.peek
fs.read_text
fs.rename
fs.rename_plan
fs.touch
fs.url
fs.write_text
```

**`ftp`** (8)

```
ftp.build_eprt
ftp.build_port
ftp.fxp_port
ftp.parse_epsv
ftp.parse_feat
ftp.parse_mlsx
ftp.parse_pasv
ftp.parse_reply
```

**`ftps`** (1)

```
ftps.negotiate
```

**`gcs`** (2)

```
gcs.resumable_plan
gcs.resume_offset
```

**`integrity`** (1)

```
integrity.repair_plan
```

**`knownhosts`** (1)

```
knownhosts.verify
```

**`listing`** (1)

```
listing.parse
```

**`manifest`** (2)

```
manifest.build
manifest.verify
```

**`path`** (2)

```
path.normalize
path.split
```

**`perms`** (3)

```
perms.chmod
perms.chmod_recursive
perms.format
```

**`pool`** (2)

```
pool.acquire
pool.maintain
```

**`profile`** (4)

```
profile.decrypt
profile.encrypt
profile.get
profile.recent
```

**`proxy`** (3)

```
proxy.http_connect
proxy.parse_socks5_reply
proxy.socks5_connect
```

**`queue`** (1)

```
queue.schedule
```

**`retry`** (1)

```
retry.classify
```

**`s3`** (4)

```
s3.complete_multipart
s3.list_objects
s3.presign
s3.sign
```

**`schedule`** (7)

```
schedule.budget
schedule.cap
schedule.next_window
schedule.set_window
schedule.show
schedule.simulate
schedule.simulate_drawn
```

**`scp`** (3)

```
scp.build_control
scp.parse_control
scp.walk
```

**`session`** (6)

```
session.clear_logs
session.connect
session.disconnect
session.list
session.logs
session.status
```

**`settings`** (2)

```
settings.get
settings.set
```

**`sftp`** (8)

```
sftp.build_ext_op
sftp.build_init
sftp.build_path_op
sftp.negotiate
sftp.parse_attrs
sftp.parse_extensions
sftp.parse_packet
sftp.parse_statvfs
```

**`sidecar`** (2)

```
sidecar.parse
sidecar.verify
```

**`ssh`** (2)

```
ssh.config_resolve
ssh.fingerprint
```

**`swarm`** (4)

```
swarm.audit
swarm.fetch
swarm.replicate
swarm.schedule
```

**`swift`** (1)

```
swift.temp_url
```

**`sync`** (4)

```
sync.compare
sync.plan
sync.resolve
sync.symlink_policy
```

**`transfer`** (10)

```
transfer.add
transfer.backoff
transfer.cancel
transfer.clear
transfer.estimate
transfer.list
transfer.multipart_plan
transfer.resume_check
transfer.segments
transfer.status
```

**`transport`** (1)

```
transport.info
```

**`tree`** (2)

```
tree.diff
tree.serialize
```

**`webdav`** (2)

```
webdav.parse_multistatus
webdav.propfind_body
```

## zgo

Alfred-style launcher — script-filter workflows and system commands  
**164 verbs** · live bus surface · call as `App::open("zgo")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`actions`** (1)

```
actions.list
```

**`base`** (1)

```
base.convert
```

**`bookmarks`** (1)

```
bookmarks.search
```

**`calc`** (2)

```
calc.eval
calc.vars
```

**`catalog`** (2)

```
catalog.habits
catalog.snapshot
```

**`chord`** (2)

```
chord.derive
chord.rederive
```

**`clipboard`** (9)

```
clipboard.add
clipboard.clear
clipboard.list
clipboard.pin
clipboard.remove
clipboard.rerun
clipboard.restore
clipboard.search
clipboard.transforms
```

**`codec`** (2)

```
codec.decode
codec.encode
```

**`color`** (3)

```
color.contrast
color.convert
color.palette
```

**`contacts`** (1)

```
contacts.search
```

**`cron`** (2)

```
cron.describe
cron.next
```

**`currency`** (1)

```
currency.convert
```

**`data`** (3)

```
data.csv_to_json
data.json_to_csv
data.json_to_yaml
```

**`date`** (2)

```
date.add
date.between
```

**`dictionary`** (1)

```
dictionary.define
```

**`feedback`** (2)

```
feedback.parse
feedback.render
```

**`file`** (3)

```
file.browse
file.filter
file.search
```

**`gen`** (7)

```
gen.lorem
gen.nanoid
gen.passphrase
gen.password
gen.strength
gen.ulid
gen.uuid
```

**`hash`** (4)

```
hash.algos
hash.compute
hash.file
hash.hmac
```

**`index`** (2)

```
index.scan
index.search
```

**`ip`** (1)

```
ip.calc
```

**`json`** (1)

```
json.format
```

**`jwt`** (1)

```
jwt.decode
```

**`keystroke`** (1)

```
keystroke.type
```

**`learn`** (2)

```
learn.rank
learn.record
```

**`list`** (1)

```
list.filter
```

**`match`** (5)

```
match.filter
match.minquery
match.regress
match.stability
match.trajectory
```

**`math`** (1)

```
math.ratio
```

**`music`** (2)

```
music.command
music.nowplaying
```

**`num`** (5)

```
num.format
num.ordinal
num.percent
num.roman
num.spell
```

**`onepassword`** (1)

```
onepassword.search
```

**`process`** (1)

```
process.match
```

**`profile`** (2)

```
profile.get
profile.save
```

**`qr`** (1)

```
qr.payload
```

**`query`** (6)

```
query.classify
query.clear
query.list
query.parse
query.recent
query.record
```

**`rank`** (1)

```
rank.blend
```

**`regex`** (3)

```
regex.match
regex.replace
regex.test
```

**`runningapps`** (1)

```
runningapps.search
```

**`saga`** (5)

```
saga.blast
saga.compose
saga.plan
saga.probe
saga.run
```

**`scriptfilter`** (4)

```
scriptfilter.keywords
scriptfilter.launch
scriptfilter.resolve
scriptfilter.run
```

**`search`** (3)

```
search.add
search.fallback
search.remove
```

**`snippet`** (8)

```
snippet.add
snippet.collection.add
snippet.collection.remove
snippet.expand
snippet.import
snippet.list
snippet.match
snippet.remove
```

**`spotlight`** (1)

```
spotlight.search
```

**`stryke`** (1)

```
stryke.run
```

**`system`** (2)

```
system.list
system.run
```

**`text`** (8)

```
text.diff
text.lines
text.metrics
text.phonetic
text.pipeline
text.readability
text.stats
text.transform
```

**`theme`** (3)

```
theme.add
theme.list
theme.remove
```

**`time`** (6)

```
time.convert
time.humanize
time.now
time.plan
time.zone
time.zones
```

**`trigger`** (6)

```
trigger.external
trigger.fallback
trigger.fileaction
trigger.hotkey
trigger.keyword
trigger.snippet
```

**`unicode`** (2)

```
unicode.char
unicode.lookup
```

**`units`** (1)

```
units.convert
```

**`url`** (1)

```
url.parse
```

**`utility`** (12)

```
utility.conditional
utility.counter
utility.delay
utility.expression
utility.file_conditional
utility.join
utility.json_config
utility.junction
utility.random
utility.replace
utility.split
utility.transform
```

**`var`** (1)

```
var.render
```

**`websearch`** (2)

```
websearch.list
websearch.url
```

**`window`** (2)

```
window.frame
window.layouts
```

**`workflow`** (8)

```
workflow.add
workflow.continue
workflow.export
workflow.get
workflow.import
workflow.list
workflow.remove
workflow.run
```

## zthrottle

System monitor / process & network throttling  
**149 verbs** · live bus surface · call as `App::open("zthrottle")->call("<verb>", %args)`

**`(top-level)`** (2)

```
capabilities
version
```

**`alerts`** (4)

```
alerts.check
alerts.list
alerts.remove
alerts.set
```

**`appshell`** (58)

```
appshell.bench-cpu
appshell.bench-disk
appshell.bench-mem
appshell.bench-net
appshell.compare-baseline
appshell.copy-run-report
appshell.cpu-limits
appshell.cpu-limits-clear
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.files
appshell.files.close
appshell.files.open
appshell.gov-ledger-clear
appshell.gui-scripts
appshell.history-clear
appshell.hooks
appshell.identify-plant
appshell.keyboard-shortcuts
appshell.metric-alerts
appshell.neon.off
appshell.neon.on
appshell.palette
appshell.processes-energy
appshell.run-all
appshell.run-contention
appshell.run-governor
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.settings
appshell.shortcuts
appshell.tab-benchmark
appshell.tab-headroom
appshell.tab-ioreg
appshell.tab-lsof
appshell.tab-network
appshell.tab-overview
appshell.tab-processes
appshell.tab-replay
appshell.tab-sensors
appshell.tab-storage
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.tmux-keys
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
```

**`bench`** (9)

```
bench.all
bench.contention
bench.cpu
bench.disk
bench.interference
bench.mem
bench.net
bench.recovery
bench.spectrum
```

**`db`** (2)

```
db.stats
db.vacuum
```

**`drives`** (2)

```
drives.list
drives.set_target
```

**`gov`** (13)

```
gov.actuate
gov.admit
gov.arbitrate
gov.chop
gov.clear
gov.headroom
gov.ledger
gov.plan
gov.release
gov.replay
gov.report
gov.restore
gov.tune
```

**`history`** (3)

```
history.clear
history.get
history.list
```

**`ioreg`** (4)

```
ioreg.find
ioreg.fuse
ioreg.node
ioreg.watch
```

**`lsof`** (1)

```
lsof.snapshot
```

**`net`** (4)

```
net.conn_rate
net.flows
net.info
net.interfaces
```

**`plant`** (4)

```
plant.identify
plant.marginal
plant.predict
plant.verify
```

**`proc`** (12)

```
proc.detail
proc.diff
proc.energy
proc.files
proc.history
proc.kill
proc.limit
proc.limits
proc.renice
proc.snapshot
proc.tree
proc.unlimit
```

**`snapshots`** (3)

```
snapshots.exclude
snapshots.list
snapshots.purge
```

**`storage`** (3)

```
storage.biggest
storage.delete
storage.scan
```

**`sys`** (19)

```
sys.battery
sys.conn_rate
sys.contention
sys.diskio
sys.disks
sys.export
sys.fans
sys.gpu
sys.history
sys.mempressure
sys.net
sys.overview
sys.power
sys.pressure
sys.processes
sys.pubip
sys.sensors
sys.smart
sys.users
```

**`zthrottle`** (6)

```
zthrottle.view.export
zthrottle.view.filter
zthrottle.view.printable
zthrottle.view.run
zthrottle.view.screenshot
zthrottle.view.tab
```

## zoffice

LibreOffice-style office engine — writer/calc/impress over ODF/OOXML  
**132 verbs** · live bus surface · call as `App::open("zoffice")->call("<verb>", %args)`

**`(top-level)`** (8)

```
convert
diff
info
inspect
meta
open
pagesetup
zoffice
```

**`base`** (3)

```
base.open
base.query
base.tables
```

**`calc`** (44)

```
calc.cell_impact
calc.cells
calc.charts
calc.charts_detail
calc.charts_render
calc.comments
calc.conditional_formats
calc.consolidate
calc.correlation
calc.critical_path
calc.csv
calc.descriptive_stats
calc.edit_cell
calc.eval
calc.evaluate
calc.filter
calc.find
calc.formulas
calc.goal_seek
calc.html
calc.impact_map
calc.markdown
calc.merge3
calc.named_ranges
calc.open
calc.pdf
calc.pivot_compute
calc.pivot_tables
calc.print_setups
calc.regression
calc.remove_duplicates
calc.render
calc.replace
calc.replace_lossless
calc.rootcause
calc.sheet_protections
calc.sheet_states
calc.sort
calc.subtotals
calc.tables
calc.text_to_columns
calc.transpose
calc.validations
calc.what_if
```

**`draw`** (8)

```
draw.connectors
draw.find
draw.html
draw.markdown
draw.open
draw.render
draw.replace
draw.svg
```

**`impress`** (24)

```
impress.charts_detail
impress.charts_render
impress.find
impress.from_outline
impress.graphic_objects
impress.hide_slides
impress.html
impress.hyperlinks
impress.layout_names
impress.layouts
impress.markdown
impress.merge3
impress.open
impress.outline
impress.pdf
impress.render
impress.replace
impress.replace_lossless
impress.shapes
impress.slide_notes
impress.slide_size
impress.tables
impress.text
impress.transitions
```

**`math`** (3)

```
math.open
math.render
math.starmath
```

**`workspace`** (4)

```
workspace.audit
workspace.impact
workspace.links
workspace.reconcile
```

**`writer`** (38)

```
writer.blame
writer.bookmark_text
writer.comment_details
writer.comments
writer.content_controls
writer.edit_table_cell
writer.epub
writer.fields
writer.find
writer.footnotes
writer.headings
writer.html
writer.hyperlinks_text
writer.images
writer.inline_images
writer.insert_toc
writer.links
writer.list_formats
writer.mail_merge
writer.markdown
writer.merge3
writer.notes
writer.open
writer.pdf
writer.redact
writer.render
writer.replace
writer.replace_lossless
writer.revision_authors
writer.runs
writer.sections
writer.settings
writer.structure
writer.style_definitions
writer.table_grids
writer.tables
writer.text
writer.track_changes
```

