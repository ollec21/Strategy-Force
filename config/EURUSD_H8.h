/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_Force_Params_H8 : Indi_Force_Params {
  Indi_Force_Params_H8() : Indi_Force_Params(indi_force_defaults, PERIOD_H8) {
    applied_price = (ENUM_APPLIED_PRICE)0;
    ma_method = 0;
    period = 14;
    shift = 0;
  }
} indi_force_h8;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Force_Params_H8 : StgParams {
  // Struct constructor.
  Stg_Force_Params_H8() : StgParams(stg_force_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)1;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)1;
    price_stop_method = 0;
    price_stop_level = (float)2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_force_h8;
