/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_Force_Params_M30 : Indi_Force_Params {
  Indi_Force_Params_M30() : Indi_Force_Params(indi_force_defaults, PERIOD_M30) {
    ma_method = 0;
    period = 4;
    shift = 0;
  }
} indi_force_m30;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Force_Params_M30 : StgParams {
  // Struct constructor.
  Stg_Force_Params_M30() : StgParams(stg_force_defaults) {
    lot_size = 0;
    signal_open_method = 2;
    signal_open_filter = 1;
    signal_open_level = 1;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = 1;
    price_stop_method = 0;
    price_stop_level = 2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_force_m30;
