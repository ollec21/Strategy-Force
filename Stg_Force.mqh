/**
 * @file
 * Implements Force strategy for the Force Index indicator.
 */

// User input params.
INPUT float Force_LotSize = 0;               // Lot size
INPUT int Force_SignalOpenMethod = 0;        // Signal open method (0-
INPUT float Force_SignalOpenLevel = 0;       // Signal open level
INPUT int Force_SignalOpenFilterMethod = 0;  // Signal open filter method
INPUT int Force_SignalOpenBoostMethod = 0;   // Signal open boost method
INPUT int Force_SignalCloseMethod = 0;       // Signal close method (0-
INPUT float Force_SignalCloseLevel = 0;      // Signal close level
INPUT int Force_PriceStopMethod = 0;         // Price stop method
INPUT float Force_PriceStopLevel = 0;        // Price stop level
INPUT int Force_TickFilterMethod = 0;        // Tick filter method
INPUT float Force_MaxSpread = 6.0;           // Max spread to trade (pips)
INPUT int Force_Shift = 1;                   // Shift (relative to the current bar, 0 - default)
INPUT string __Force_Indi_Force_Parameters__ =
    "-- Force strategy: Force indicator params --";     // >>> Force strategy: Force indicator <<<
INPUT int Indi_Force_Period = 38;                       // Period
INPUT ENUM_MA_METHOD Indi_Force_MA_Method = 0;          // MA Method
INPUT ENUM_APPLIED_PRICE Indi_Force_Applied_Price = 2;  // Applied Price

// Structs.

// Defines struct with default user indicator values.
struct Indi_Force_Params_Defaults : ForceParams {
  Indi_Force_Params_Defaults() : ForceParams(::Indi_Force_Period, ::Indi_Force_MA_Method, ::Indi_Force_Applied_Price) {}
} indi_force_defaults;

// Defines struct to store indicator parameter values.
struct Indi_Force_Params : public ForceParams {
  // Struct constructors.
  void Indi_Force_Params(ForceParams &_params, ENUM_TIMEFRAMES _tf) : ForceParams(_params, _tf) {}
};

// Defines struct with default user strategy values.
struct Stg_Force_Params_Defaults : StgParams {
  Stg_Force_Params_Defaults()
      : StgParams(::Force_SignalOpenMethod, ::Force_SignalOpenFilterMethod, ::Force_SignalOpenLevel,
                  ::Force_SignalOpenBoostMethod, ::Force_SignalCloseMethod, ::Force_SignalCloseLevel,
                  ::Force_PriceStopMethod, ::Force_PriceStopLevel, ::Force_TickFilterMethod, ::Force_MaxSpread,
                  ::Force_Shift) {}
} stg_force_defaults;

// Struct to define strategy parameters to override.
struct Stg_Force_Params : StgParams {
  Indi_Force_Params iparams;
  StgParams sparams;

  // Struct constructors.
  Stg_Force_Params(Indi_Force_Params &_iparams, StgParams &_sparams)
      : iparams(indi_force_defaults, _iparams.tf), sparams(stg_force_defaults) {
    iparams = _iparams;
    sparams = _sparams;
  }
};

// Loads pair specific param values.
#include "config/EURUSD_H1.h"
#include "config/EURUSD_H4.h"
#include "config/EURUSD_H8.h"
#include "config/EURUSD_M1.h"
#include "config/EURUSD_M15.h"
#include "config/EURUSD_M30.h"
#include "config/EURUSD_M5.h"

class Stg_Force : public Strategy {
 public:
  Stg_Force(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_Force *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Indi_Force_Params _indi_params(indi_force_defaults, _tf);
    StgParams _stg_params(stg_force_defaults);
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Indi_Force_Params>(_indi_params, _tf, indi_force_m1, indi_force_m5, indi_force_m15, indi_force_m30,
                                       indi_force_h1, indi_force_h4, indi_force_h8);
      SetParamsByTf<StgParams>(_stg_params, _tf, stg_force_m1, stg_force_m5, stg_force_m15, stg_force_m30, stg_force_h1,
                               stg_force_h4, stg_force_h8);
    }
    // Initialize indicator.
    ForceParams force_params(_indi_params);
    _stg_params.SetIndicator(new Indi_Force(_indi_params));
    // Initialize strategy parameters.
    _stg_params.GetLog().SetLevel(_log_level);
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_Force(_stg_params, "Force");
    _stg_params.SetStops(_strat, _strat);
    return _strat;
  }

  /**
   * Check if Force Index indicator is on buy or sell.
   *
   * Note: To use the indicator it should be correlated with another trend indicator.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   _method (int) - signal method to use by using bitwise AND operation
   *   _level (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_Force *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    bool _result = _is_valid;
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double level = _level * Chart().GetPipSize();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // FI recommends to buy (i.e. FI<0).
        _result = _indi[CURR][0] < -_level;
        if (METHOD(_method, 0)) _result &= _indi[PREV][0] < _indi[PPREV][0];  // ... 2 consecutive columns are red.
        if (METHOD(_method, 1)) _result &= _indi[PPREV][0] < _indi[3][0];     // ... 3 consecutive columns are red.
        if (METHOD(_method, 2)) _result &= _indi[3][0] < _indi[4][0];         // ... 4 consecutive columns are red.
        if (METHOD(_method, 3)) _result &= _indi[PREV][0] > _indi[PPREV][0];  // ... 2 consecutive columns are green.
        if (METHOD(_method, 4)) _result &= _indi[PPREV][0] > _indi[3][0];     // ... 3 consecutive columns are green.
        if (METHOD(_method, 5)) _result &= _indi[3][0] < _indi[4][0];         // ... 4 consecutive columns are green.
        break;
      case ORDER_TYPE_SELL:
        // FI recommends to sell (i.e. FI>0).
        _result = _indi[CURR][0] > _level;
        if (METHOD(_method, 0)) _result &= _indi[PREV][0] < _indi[PPREV][0];  // ... 2 consecutive columns are red.
        if (METHOD(_method, 1)) _result &= _indi[PPREV][0] < _indi[3][0];     // ... 3 consecutive columns are red.
        if (METHOD(_method, 2)) _result &= _indi[3][0] < _indi[4][0];         // ... 4 consecutive columns are red.
        if (METHOD(_method, 3)) _result &= _indi[PREV][0] > _indi[PPREV][0];  // ... 2 consecutive columns are green.
        if (METHOD(_method, 4)) _result &= _indi[PPREV][0] > _indi[3][0];     // ... 3 consecutive columns are green.
        if (METHOD(_method, 5)) _result &= _indi[3][0] < _indi[4][0];         // ... 4 consecutive columns are green.
        break;
    }
    return _result;
  }

  /**
   * Gets price stop value for profit take or stop loss.
   */
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    Indi_Force *_indi = Data();
    double level = _level * Chart().GetPipSize();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 1: {
        int _bar_count1 = (int)_level * (int)_indi.GetPeriod();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest<double>(_bar_count1))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest<double>(_bar_count1));
        break;
      }
      case 2: {
        int _bar_count2 = (int)_level * (int)_indi.GetPeriod();
        _result = _direction < 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest<double>(_bar_count2))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest<double>(_bar_count2));
        break;
      }
    }
    return (float)_result;
  }
};
