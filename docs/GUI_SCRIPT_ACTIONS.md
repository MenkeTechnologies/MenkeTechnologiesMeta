# GUI Script Actions — Global Catalog

Every scriptable **GUI-Script action** (automation-bus verb) exposed by every MenkeTechnologies
GUI app — the exact surface `App::open("<app>")->verbs()` returns over the
[GUI Automation Bus](GUI_AUTOMATION_BUS.md): the LIVE runtime surface (appShell verbs +
per-app `opts.commands` + dynamically-registered verbs), read from each running app.

**4308 actions** across **17 apps**. Read from each app's live bus
surface by `bin/gen-gui-actions-live` — do not hand-edit. Requires every app open when generated.

| App | Verbs | Surface |
| --- |:--:| --- |
| [`traderview`](#traderview) | 1732 | TradingView-style charting/trading terminal — view tiles + shortcut actions |
| [`zpdf`](#zpdf) | 649 | Acrobat/Preview-style PDF engine — render, edit, annotate, forms, OCR, redact |
| [`audio-haxor`](#audio-haxor) | 239 | Audio analyzer / DAW-project generator — spectrum, DSP, .als generation |
| [`zemail`](#zemail) | 208 | Thunderbird-style mail client — accounts, folders, messages, PGP/S-MIME, search |
| [`zcite`](#zcite) | 206 | Zotero-style reference manager — library, collections, citations, PDF, sync |
| [`zoffice`](#zoffice) | 199 | LibreOffice-style office engine — writer/calc/impress over ODF/OOXML |
| [`zwire`](#zwire) | 161 | Chromium-superset browser — tabs, windows, tab-groups, downloads, reading list, power |
| [`zftp`](#zftp) | 160 | Cyberduck-style transfer client — FTP/SFTP/WebDAV/S3/cloud, transfers, sync |
| [`zreq`](#zreq) | 151 | Postman-style API client — requests, collections, auth, codegen, gRPC/WebSocket |
| [`zgo`](#zgo) | 140 | Alfred-style launcher — script-filter workflows and system commands |
| [`ztunnel`](#ztunnel) | 125 | Tunnelblick-style VPN client — OpenVPN / WireGuard config + control |
| [`zphoto`](#zphoto) | 101 | Photoshop + Illustrator-style raster & vector editor — layers, filters, paths, actions |
| [`zthrottle`](#zthrottle) | 91 | System monitor / process & network throttling |
| [`ztranslator`](#ztranslator) | 54 | BOME-style MIDI/keyboard translator — presets, translators, rules, HID |
| [`zstation`](#zstation) | 37 | Station-style multi-app workspace — boards, tiles, panes |
| [`zmax-gui`](#zmax-gui) | 30 |  |
| [`zcontainer`](#zcontainer) | 25 | Docker Desktop + Lens-style container / Kubernetes manager |

---

## traderview

TradingView-style charting/trading terminal — view tiles + shortcut actions  
**1732 verbs** · live bus surface · call as `App::open("traderview")->call("<verb>", %args)`

**`(top-level)`** (1726)

```
action:abc_pattern_run
action:absorption_run
action:accounts_focus_name
action:accounts_overview_refresh
action:acf_run
action:active_share_run
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
action:signal_decomposition_run
action:spread_tracker_demo
action:spread_tracker_run
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

**`app`** (6)

```
app.fileBrowser
app.hideTerminal
app.hooksEditor
app.killTerminal
app.terminal
app.toggleSequencer
```

## zpdf

Acrobat/Preview-style PDF engine — render, edit, annotate, forms, OCR, redact  
**649 verbs** · live bus surface · call as `App::open("zpdf")->call("<verb>", %args)`

**`(top-level)`** (309)

```
accessibility_check
add_3d
add_background
add_barcode
add_bookmark
add_callout
add_data_matrix
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
add_submit_button
add_text
add_text_with_font
add_thread
add_typed_signature
adjust_image
adjust_page
apply_actions
apply_redactions
attach_file
attachments
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
compare
contact_sheet
content_fingerprint
convert_to_cmyk
create_checkbox
create_choice_field
create_from_images
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
deskew_page
detect_image_regions
detect_skew_angle
discard_search_index
discard_thumbnails
doc_js_names
document_id
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
extract_tables
extract_text
extract_text_in_region
extract_to
find_replace_text
flatten_annotations
flatten_form
flatten_layers
flatten_transparency
flip_page
form_fields
generate_thumbnails
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
make_portfolio
make_searchable
mark_visual_differences
merge_file
move_bookmark
move_field
move_page
move_text
n_up
named_destinations
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
reset_form
resize_all_pages
resize_page
restyle_text
reverse_pages
rotate_all
rotate_page
run_javascript
sanitize
save_pdf
scan_pii
search
set_all_annotation_flags
set_all_page_boxes
set_annotation_author
set_annotation_border
set_annotation_color
set_annotation_contents
set_annotation_flags
set_annotation_opacity
set_annotation_rect
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
stylize_page
suggest_filename
swap_pages
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
verify_full
verify_redaction
verify_signatures
watermark_image
watermark_text
whiteout
word_diff
xfa_datasets
xfa_packets
xmp_metadata
```

**`appshell`** (340)

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
appshell.recent:/Users/wizard/Desktop/JacobMenke2026.pdf
appshell.recent:/Users/wizard/Desktop/pdf/beginningperl.pdf
appshell.recent:/Users/wizard/RustroverProjects/MenkeTechnologiesMeta/MenkeTechnologiesPublications/gui-automation-bus/docs/book.pdf
appshell.recent:/Users/wizard/RustroverProjects/MenkeTechnologiesMeta/MenkeTechnologiesPublications/gui-automation-bus/docs/reference.pdf
appshell.recent:/Users/wizard/RustroverProjects/MenkeTechnologiesMeta/MenkeTechnologiesPublications/inventions/docs/book.pdf
appshell.recent:/Users/wizard/RustroverProjects/MenkeTechnologiesMeta/MenkeTechnologiesPublications/zwire/docs/book.pdf
appshell.recent:/Users/wizard/RustroverProjects/MenkeTechnologiesMeta/zpwr-jobs/JacobMenke2026.pdf
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
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
appshell.zp.cmd_a11y_check
appshell.zp.cmd_add_3d
appshell.zp.cmd_add_bookmark
appshell.zp.cmd_add_dest
appshell.zp.cmd_add_image
appshell.zp.cmd_add_sound
appshell.zp.cmd_add_text
appshell.zp.cmd_add_video
appshell.zp.cmd_adjust_doc
appshell.zp.cmd_advance
appshell.zp.cmd_all_page_boxes
appshell.zp.cmd_alt_text
appshell.zp.cmd_alt_texts
appshell.zp.cmd_annot_author
appshell.zp.cmd_annot_border
appshell.zp.cmd_annot_delete
appshell.zp.cmd_annot_edit
appshell.zp.cmd_annot_flags
appshell.zp.cmd_annot_opacity
appshell.zp.cmd_annot_recolor
appshell.zp.cmd_annot_rect
appshell.zp.cmd_annot_subject
appshell.zp.cmd_annots_lock
appshell.zp.cmd_annots_print
appshell.zp.cmd_attach_file
appshell.zp.cmd_attachments
appshell.zp.cmd_auto_crop
appshell.zp.cmd_auto_link
appshell.zp.cmd_auto_outline
appshell.zp.cmd_auto_tag
appshell.zp.cmd_background
appshell.zp.cmd_barcode
appshell.zp.cmd_bates
appshell.zp.cmd_binarize
appshell.zp.cmd_booklet
appshell.zp.cmd_bookmark_action
appshell.zp.cmd_bookmark_style
appshell.zp.cmd_build_toc
appshell.zp.cmd_calc_order
appshell.zp.cmd_callout
appshell.zp.cmd_canonical
appshell.zp.cmd_certify
appshell.zp.cmd_checkbox
appshell.zp.cmd_cleanup
appshell.zp.cmd_clear_metadata
appshell.zp.cmd_clear_sig
appshell.zp.cmd_compare
appshell.zp.cmd_contact_sheet
appshell.zp.cmd_convert_cmyk
appshell.zp.cmd_create_from_images
appshell.zp.cmd_create_layer
appshell.zp.cmd_create_ocmd
appshell.zp.cmd_datamatrix
appshell.zp.cmd_decrypt_cert
appshell.zp.cmd_del_annots_author
appshell.zp.cmd_del_annots_type
appshell.zp.cmd_delete_attachment
appshell.zp.cmd_delete_bookmark
appshell.zp.cmd_delete_dest
appshell.zp.cmd_delete_field
appshell.zp.cmd_delete_layer
appshell.zp.cmd_deskew
appshell.zp.cmd_detect_images
appshell.zp.cmd_detect_skew
appshell.zp.cmd_discard_index
appshell.zp.cmd_discard_thumbs
appshell.zp.cmd_doc_action
appshell.zp.cmd_doc_flags
appshell.zp.cmd_doc_js
appshell.zp.cmd_doc_js_list
appshell.zp.cmd_document_id
appshell.zp.cmd_downsample
appshell.zp.cmd_dropdown
appshell.zp.cmd_duplicate_pages
appshell.zp.cmd_edit_text
appshell.zp.cmd_encrypt
appshell.zp.cmd_encrypt_aes
appshell.zp.cmd_encrypt_cert
appshell.zp.cmd_encrypt_multi
appshell.zp.cmd_encrypt_perms
appshell.zp.cmd_export_comments_xfdf
appshell.zp.cmd_export_fdf
appshell.zp.cmd_export_svg
appshell.zp.cmd_export_xfa
appshell.zp.cmd_export_xfdf
appshell.zp.cmd_extract_attachment
appshell.zp.cmd_extract_fonts
appshell.zp.cmd_extract_images
appshell.zp.cmd_extract_tables
appshell.zp.cmd_field_align
appshell.zp.cmd_field_appearance
appshell.zp.cmd_field_calc
appshell.zp.cmd_field_colors
appshell.zp.cmd_field_default
appshell.zp.cmd_field_export
appshell.zp.cmd_field_flags
appshell.zp.cmd_field_format_js
appshell.zp.cmd_field_keystroke_js
appshell.zp.cmd_field_maxlen
appshell.zp.cmd_field_options
appshell.zp.cmd_field_rich_value
appshell.zp.cmd_field_tooltip
appshell.zp.cmd_field_validate_js
appshell.zp.cmd_find_replace
appshell.zp.cmd_fingerprint
appshell.zp.cmd_flatten_layers
appshell.zp.cmd_flatten_transparency
appshell.zp.cmd_flip_page
appshell.zp.cmd_goto_link
appshell.zp.cmd_grid_overlay
appshell.zp.cmd_header_footer
appshell.zp.cmd_hidden_audit
appshell.zp.cmd_highlight_search
appshell.zp.cmd_import_comments_xfdf
appshell.zp.cmd_import_fdf
appshell.zp.cmd_import_xfdf
appshell.zp.cmd_indent_bookmark
appshell.zp.cmd_info_prop
appshell.zp.cmd_ink_coverage
appshell.zp.cmd_insert_blank
appshell.zp.cmd_insert_pages
appshell.zp.cmd_interleave
appshell.zp.cmd_launch_link
appshell.zp.cmd_layer_usage
appshell.zp.cmd_layer_visibility
appshell.zp.cmd_line_numbers
appshell.zp.cmd_linearize
appshell.zp.cmd_list_annots
appshell.zp.cmd_list_field_actions
appshell.zp.cmd_list_fonts
appshell.zp.cmd_list_inks
appshell.zp.cmd_list_layers
appshell.zp.cmd_list_links
appshell.zp.cmd_list_output_intents
appshell.zp.cmd_lock_layer
appshell.zp.cmd_make_searchable
appshell.zp.cmd_measure
appshell.zp.cmd_move_bookmark_down
appshell.zp.cmd_move_bookmark_up
appshell.zp.cmd_move_field
appshell.zp.cmd_move_page
appshell.zp.cmd_named_action_link
appshell.zp.cmd_named_dests
appshell.zp.cmd_object_stats
appshell.zp.cmd_ocr_page
appshell.zp.cmd_ocr_words
appshell.zp.cmd_open_page
appshell.zp.cmd_optimize
appshell.zp.cmd_outdent_bookmark
appshell.zp.cmd_output_intent
appshell.zp.cmd_overlay_page
appshell.zp.cmd_page_action
appshell.zp.cmd_page_box
appshell.zp.cmd_page_boxes
appshell.zp.cmd_page_dimensions
appshell.zp.cmd_page_labels
appshell.zp.cmd_page_layout
appshell.zp.cmd_page_mode
appshell.zp.cmd_page_numbers
appshell.zp.cmd_permissions
appshell.zp.cmd_portfolio
appshell.zp.cmd_preflight
appshell.zp.cmd_print_pdf
appshell.zp.cmd_print_preset
appshell.zp.cmd_printer_marks
appshell.zp.cmd_push_button
appshell.zp.cmd_qr
appshell.zp.cmd_radio_group
appshell.zp.cmd_readability
appshell.zp.cmd_reading_direction
appshell.zp.cmd_reading_order
appshell.zp.cmd_recompress
appshell.zp.cmd_redact_pii
appshell.zp.cmd_redact_regex
appshell.zp.cmd_redact_search
appshell.zp.cmd_reflow
appshell.zp.cmd_regen_doc_id
appshell.zp.cmd_region_text
appshell.zp.cmd_remote_goto_link
appshell.zp.cmd_remove_blank
appshell.zp.cmd_remove_js
appshell.zp.cmd_rename_bookmark
appshell.zp.cmd_rename_field
appshell.zp.cmd_rename_layer
appshell.zp.cmd_reorder_pages
appshell.zp.cmd_repair
appshell.zp.cmd_replace_image
appshell.zp.cmd_replace_pages
appshell.zp.cmd_reset_form
appshell.zp.cmd_resize_all
appshell.zp.cmd_resize_page
appshell.zp.cmd_retarget_bookmark
appshell.zp.cmd_rotate_all_ccw
appshell.zp.cmd_rotate_all_cw
appshell.zp.cmd_run_js
appshell.zp.cmd_sanitize
appshell.zp.cmd_save_pdfa
appshell.zp.cmd_save_pdfx
appshell.zp.cmd_scan_pii
appshell.zp.cmd_scan_split
appshell.zp.cmd_search
appshell.zp.cmd_separations
appshell.zp.cmd_set_language
appshell.zp.cmd_set_outline
appshell.zp.cmd_set_trapped
appshell.zp.cmd_set_xfa
appshell.zp.cmd_set_xmp
appshell.zp.cmd_sign
appshell.zp.cmd_sign_image
appshell.zp.cmd_sign_visible
appshell.zp.cmd_signature_field
appshell.zp.cmd_similarity
appshell.zp.cmd_single_page
appshell.zp.cmd_space_audit
appshell.zp.cmd_split_bookmarks
appshell.zp.cmd_split_count
appshell.zp.cmd_split_grid
appshell.zp.cmd_split_oddeven
appshell.zp.cmd_split_ranges
appshell.zp.cmd_split_size
appshell.zp.cmd_split_text
appshell.zp.cmd_structure_diff
appshell.zp.cmd_stylize
appshell.zp.cmd_submit_button
appshell.zp.cmd_suggest_name
appshell.zp.cmd_swap_pages
appshell.zp.cmd_tab_order
appshell.zp.cmd_tag_pdfua
appshell.zp.cmd_text_font
appshell.zp.cmd_thread
appshell.zp.cmd_threads
appshell.zp.cmd_thumbnails
appshell.zp.cmd_timestamp
appshell.zp.cmd_transition
appshell.zp.cmd_unembed_fonts
appshell.zp.cmd_user_unit
appshell.zp.cmd_validate_pdfa
appshell.zp.cmd_validate_pdfua
appshell.zp.cmd_verify_full
appshell.zp.cmd_verify_redaction
appshell.zp.cmd_verify_sigs
appshell.zp.cmd_viewer_pref
appshell.zp.cmd_visual_diff
appshell.zp.cmd_visual_diff_score
appshell.zp.cmd_watermark
appshell.zp.cmd_watermark_img
appshell.zp.cmd_whiteout
appshell.zp.cmd_word_diff
appshell.zp.cmd_xfa_datasets
appshell.zp.cmd_xfa_packets
appshell.zp.cmd_xmp
appshell.zp.crop_page
appshell.zp.decrypt
appshell.zp.delete_page
appshell.zp.draw_brush
appshell.zp.draw_eraser
appshell.zp.draw_gradient
appshell.zp.draw_rect
appshell.zp.export_csv
appshell.zp.export_excel
appshell.zp.export_html
appshell.zp.export_image
appshell.zp.export_markdown
appshell.zp.export_ppt
appshell.zp.export_word
appshell.zp.extract_page
appshell.zp.image_adjust
appshell.zp.impose_2up
appshell.zp.impose_4up
appshell.zp.impose_8up
appshell.zp.mark_caret
appshell.zp.mark_highlight
appshell.zp.mark_ink
appshell.zp.mark_line
appshell.zp.mark_note
appshell.zp.mark_oval
appshell.zp.mark_polygon
appshell.zp.mark_polyline
appshell.zp.mark_rectangle
appshell.zp.mark_redact
appshell.zp.mark_squiggly
appshell.zp.mark_stamp
appshell.zp.mark_strikeout
appshell.zp.mark_textbox
appshell.zp.mark_underline
appshell.zp.merge_pdf
appshell.zp.open_file_browser
appshell.zp.open_hooks_editor
appshell.zp.open_pdf
appshell.zp.open_recent_menu
appshell.zp.reader_mode
appshell.zp.reverse_order
appshell.zp.rotate_90
appshell.zp.save
appshell.zp.save_as
appshell.zp.save_grayscale
appshell.zp.save_inverted
appshell.zp.tab_bookmarks
appshell.zp.tab_fields
appshell.zp.tab_metadata
appshell.zp.tab_page
appshell.zp.tab_text
appshell.zp.toggle_terminal
```

## audio-haxor

Audio analyzer / DAW-project generator — spectrum, DSP, .als generation  
**239 verbs** · live bus surface · call as `App::open("audio-haxor")->call("<verb>", %args)`

**`app`** (239)

```
app.alsCancelGenerate
app.alsGenerate
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
app.openDataDir
app.openLogFile
app.openNextUpdate
app.openPrefsFile
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

## zemail

Thunderbird-style mail client — accounts, folders, messages, PGP/S-MIME, search  
**208 verbs** · live bus surface · call as `App::open("zemail")->call("<verb>", %args)`

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

**`address`** (2)

```
address.to_ascii
address.validate
```

**`appshell`** (30)

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
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
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

**`compose`** (3)

```
compose.attachment_reminder
compose.mail_merge
compose.parse_mailto
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

**`filter`** (5)

```
filter.add
filter.list
filter.remove
filter.run
filter.to_sieve
```

**`folder`** (6)

```
folder.create
folder.delete
folder.digest
folder.inbox_load
folder.list
folder.rename
```

**`followup`** (1)

```
followup.due
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

**`message`** (34)

```
message.action_items
message.add_label
message.attachment_safety
message.build_rfc5322
message.categorize
message.commitment_scan
message.delete
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
message.parse_mdn
message.phishing_scan
message.pin
message.priority_rank
message.reading_time
message.remove_label
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

## zcite

Zotero-style reference manager — library, collections, citations, PDF, sync  
**206 verbs** · live bus surface · call as `App::open("zcite")->call("<verb>", %args)`

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

**`appshell`** (28)

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
appshell.toggle-theme
```

**`attachment`** (3)

```
attachment.index
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

**`bib`** (10)

```
bib.author_substitute
bib.bibliography
bib.citation
bib.cite_key
bib.cite_keys
bib.csl
bib.csl_document
bib.disambiguate
bib.sort_key
bib.styles
```

**`cite`** (2)

```
cite.document
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

**`integrity`** (1)

```
integrity.check
```

**`item`** (24)

```
item.add
item.add_attachment
item.add_note
item.add_tag
item.convert_type
item.delete
item.duplicate
item.get
item.list
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

**`report`** (5)

```
report.field_completeness
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

## zoffice

LibreOffice-style office engine — writer/calc/impress over ODF/OOXML  
**199 verbs** · live bus surface · call as `App::open("zoffice")->call("<verb>", %args)`

**`(top-level)`** (6)

```
diff
info
inspect
meta
open
pagesetup
```

**`appshell`** (103)

```
appshell.base_catalog
appshell.base_run_query
appshell.calc_batch_edit
appshell.calc_chart_data
appshell.calc_column_stats
appshell.calc_comments
appshell.calc_cond_formats
appshell.calc_edit_cell
appshell.calc_eval
appshell.calc_export_formulas
appshell.calc_features
appshell.calc_named_ranges
appshell.calc_overview
appshell.calc_pivots
appshell.calc_print_setups
appshell.calc_protections
appshell.calc_sheet_states
appshell.calc_sort
appshell.calc_tables
appshell.calc_validations
appshell.close_document
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.doc_properties
appshell.draw_connectors
appshell.edit_doc_properties
appshell.engine_info
appshell.export_document
appshell.extract_plain_text
appshell.files
appshell.files.close
appshell.files.open
appshell.find_in_doc
appshell.gui-scripts
appshell.hooks
appshell.impress_add_slide
appshell.impress_chart_data
appshell.impress_edit_slide
appshell.impress_export_hyperlinks
appshell.impress_extract_text
appshell.impress_graphic_objects
appshell.impress_insert_slide
appshell.impress_layout_names
appshell.impress_layouts
appshell.impress_remove_slide
appshell.impress_shapes
appshell.impress_slide_size
appshell.impress_slide_tables
appshell.impress_speaker_notes
appshell.impress_transitions
appshell.math_starmath
appshell.neon.off
appshell.neon.on
appshell.open_document
appshell.page_setup
appshell.palette
appshell.reload_document
appshell.replace_in_doc
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
appshell.switch_base
appshell.switch_calc
appshell.switch_draw
appshell.switch_impress
appshell.switch_math
appshell.switch_writer
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
appshell.writer_bookmarks
appshell.writer_compare
appshell.writer_edit_paragraph
appshell.writer_embedded_media
appshell.writer_export_comments
appshell.writer_export_hyperlinks
appshell.writer_field_codes
appshell.writer_footnotes
appshell.writer_form_fields
appshell.writer_formatting
appshell.writer_insert_paragraph
appshell.writer_list_formats
appshell.writer_revision_authors
appshell.writer_sections
appshell.writer_settings
appshell.writer_structure
appshell.writer_style_catalog
appshell.writer_table_content
appshell.writer_word_count
```

**`base`** (3)

```
base.open
base.query
base.tables
```

**`calc`** (27)

```
calc.cells
calc.charts
calc.charts_detail
calc.charts_render
calc.comments
calc.conditional_formats
calc.csv
calc.edit_cell
calc.eval
calc.evaluate
calc.find
calc.formulas
calc.html
calc.markdown
calc.named_ranges
calc.open
calc.pdf
calc.pivot_tables
calc.print_setups
calc.render
calc.replace
calc.replace_lossless
calc.sheet_protections
calc.sheet_states
calc.sort
calc.tables
calc.validations
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

**`impress`** (20)

```
impress.charts_detail
impress.charts_render
impress.find
impress.graphic_objects
impress.html
impress.hyperlinks
impress.layout_names
impress.layouts
impress.markdown
impress.open
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

**`writer`** (29)

```
writer.bookmark_text
writer.comment_details
writer.comments
writer.content_controls
writer.fields
writer.find
writer.footnotes
writer.html
writer.hyperlinks_text
writer.images
writer.inline_images
writer.links
writer.list_formats
writer.markdown
writer.notes
writer.open
writer.pdf
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
```

## zwire

Chromium-superset browser — tabs, windows, tab-groups, downloads, reading list, power  
**161 verbs** · live bus surface · call as `App::open("zwire")->call("<verb>", %args)`

**`(top-level)`** (62)

```
clipboard_get
clipboard_set
exec
fs_append
fs_list
fs_mkdir
fs_read
fs_rm
fs_stat
fs_tail
fs_walk
fs_watch
fs_write
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
peer
peer_connect
peers
ping
ps
pty_kill
pty_resize
pty_spawn
pty_write
pub
stryke_lsp_send
stryke_lsp_start
stryke_lsp_stop
stryke_run
sub
sysinfo_once
sysinfo_start
sysinfo_stop
unsub
watch_list
watch_stop
which
```

**`browser`** (99)

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

## zftp

Cyberduck-style transfer client — FTP/SFTP/WebDAV/S3/cloud, transfers, sync  
**160 verbs** · live bus surface · call as `App::open("zftp")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`appshell`** (37)

```
appshell.Connect selected
appshell.Connect to server
appshell.Disconnect selected
appshell.List directory
appshell.Preferences
appshell.Reload
appshell.Toggle terminal
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
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
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

**`bookmark`** (9)

```
bookmark.add
bookmark.get
bookmark.import
bookmark.import_filezilla
bookmark.import_winscp
bookmark.list
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

**`delta`** (2)

```
delta.plan
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

**`filter`** (5)

```
filter.apply
filter.expand
filter.glob_to_regex
filter.match
filter.parse_rules
```

**`fs`** (7)

```
fs.chmod
fs.delete
fs.list
fs.mkdir
fs.peek
fs.rename
fs.rename_plan
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

## zreq

Postman-style API client — requests, collections, auth, codegen, gRPC/WebSocket  
**151 verbs** · live bus surface · call as `App::open("zreq")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`appshell`** (30)

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
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
```

**`assert`** (1)

```
assert.run
```

**`asyncapi`** (1)

```
asyncapi.parse
```

**`cbor`** (2)

```
cbor.decode
cbor.encode
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

**`curl`** (1)

```
curl.explain
```

**`dataset`** (1)

```
dataset.parse
```

**`encoding`** (1)

```
encoding.convert
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

**`history`** (3)

```
history.clear
history.list
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

**`runner`** (1)

```
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

**`workspace`** (8)

```
workspace.create
workspace.current
workspace.delete
workspace.get
workspace.list
workspace.rename
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

## zgo

Alfred-style launcher — script-filter workflows and system commands  
**140 verbs** · live bus surface · call as `App::open("zgo")->call("<verb>", %args)`

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

**`clipboard`** (4)

```
clipboard.add
clipboard.clear
clipboard.list
clipboard.search
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

**`match`** (1)

```
match.filter
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

**`scriptfilter`** (1)

```
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

**`workflow`** (7)

```
workflow.add
workflow.export
workflow.get
workflow.import
workflow.list
workflow.remove
workflow.run
```

## ztunnel

Tunnelblick-style VPN client — OpenVPN / WireGuard config + control  
**125 verbs** · live bus surface · call as `App::open("ztunnel")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`appshell`** (28)

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
appshell.toggle-theme
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

**`multihop`** (2)

```
multihop.chain
multihop.validate
```

**`net`** (11)

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
net.tunnel_mtu
net.ula
```

**`obfs`** (1)

```
obfs.catalog
```

**`openvpn`** (3)

```
openvpn.inline_blocks
openvpn.push_reply
openvpn.static_key_parse
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

**`route`** (2)

```
route.conflicts
route.coverage
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

**`vpn`** (12)

```
vpn.autoconnect
vpn.can_transition
vpn.clear_logs
vpn.connect
vpn.connections
vpn.disconnect
vpn.killswitch_plan
vpn.killswitch_syntax
vpn.logs
vpn.network_changed
vpn.reconnect_schedule
vpn.status
```

**`wg`** (8)

```
wg.allowed_ips
wg.allowed_ips_dedup
wg.cookie_decision
wg.cookie_model
wg.genkey
wg.handshake_model
wg.noise_layout
wg.pubkey
```

## zphoto

Photoshop + Illustrator-style raster & vector editor — layers, filters, paths, actions  
**101 verbs** · live bus surface · call as `App::open("zphoto")->call("<verb>", %args)`

**`appshell`** (101)

```
appshell.addLayer
appshell.addMaskFromSel
appshell.addMaskWhite
appshell.addText
appshell.applyMask
appshell.autoContrast
appshell.blackWhite
appshell.boxBlur
appshell.brightnessContrast
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
appshell.dropShadow
appshell.dupActive
appshell.edge
appshell.emboss
appshell.equalize
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
appshell.solarize
appshell.spread
appshell.temperature
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.threshold
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
appshell.undo
appshell.valueInvert
appshell.vibrance
appshell.vignette
```

## zthrottle

System monitor / process & network throttling  
**91 verbs** · live bus surface · call as `App::open("zthrottle")->call("<verb>", %args)`

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

**`appshell`** (37)

```
appshell.bench-cpu
appshell.bench-disk
appshell.bench-mem
appshell.bench-net
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.files
appshell.files.close
appshell.files.open
appshell.gui-scripts
appshell.history-clear
appshell.hooks
appshell.neon.off
appshell.neon.on
appshell.palette
appshell.run-all
appshell.run-contention
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
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
```

**`bench`** (6)

```
bench.all
bench.contention
bench.cpu
bench.disk
bench.mem
bench.net
```

**`drives`** (2)

```
drives.list
drives.set_target
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

**`proc`** (7)

```
proc.detail
proc.diff
proc.files
proc.history
proc.kill
proc.snapshot
proc.tree
```

**`storage`** (3)

```
storage.biggest
storage.delete
storage.scan
```

**`sys`** (18)

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

## ztranslator

BOME-style MIDI/keyboard translator — presets, translators, rules, HID  
**54 verbs** · live bus surface · call as `App::open("ztranslator")->call("<verb>", %args)`

**`appshell`** (54)

```
appshell.addPreset
appshell.addTranslator
appshell.capture
appshell.code
appshell.copySel
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.cutSel
appshell.delSel
appshell.dupSel
appshell.exportBmtp
appshell.files
appshell.files.close
appshell.files.open
appshell.grantAccess
appshell.gui-scripts
appshell.help
appshell.hooks
appshell.import
appshell.loadJson
appshell.midiPorts
appshell.neon.off
appshell.neon.on
appshell.new
appshell.palette
appshell.panic
appshell.pasteSel
appshell.properties
appshell.refreshPorts
appshell.renameSel
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
appshell.stop
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.toggle-theme
```

## zstation

Station-style multi-app workspace — boards, tiles, panes  
**37 verbs** · live bus surface · call as `App::open("zstation")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
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

**`layout`** (1)

```
layout.save
```

**`library`** (1)

```
library.search
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

## zmax-gui

**30 verbs** · live bus surface · call as `App::open("zmax-gui")->call("<verb>", %args)`

**`appshell`** (30)

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
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
```

## zcontainer

Docker Desktop + Lens-style container / Kubernetes manager  
**25 verbs** · live bus surface · call as `App::open("zcontainer")->call("<verb>", %args)`

**`appshell`** (25)

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
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.toggle-theme
```

