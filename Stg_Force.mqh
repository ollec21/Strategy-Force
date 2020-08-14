/**
 * @file
 * Implements Force strategy for the Force Index indicator.
 */

// User input params.
INPUT int Force_Period = 38;                       // Period
INPUT ENUM_MA_METHOD Force_MA_Method = 0;          // MA Method
INPUT ENUM_APPLIED_PRICE Force_Applied_Price = 2;  // Applied Price
INPUT int Force_Shift = 1;                         // Shift (relative to the current bar, 0 - default)
INPUT int Force_SignalOpenMethod = 0;              // Signal open method (0-
INPUT float Force_SignalOpenLevel = 0;             // Signal open level
INPUT int Force_SignalOpenFilterMethod = 0;        // Signal open filter method
INPUT int Force_SignalOpenBoostMethod = 0;         // Signal open boost method
INPUT int Force_SignalCloseMethod = 0;             // Signal close method (0-
INPUT float Force_SignalCloseLevel = 0;            // Signal close level
INPUT int Force_PriceLimitMethod = 0;              // Price limit method
INPUT float Force_PriceLimitLevel = 0;             // Price limit level
INPUT float Force_MaxSpread = 6.0;                 // Max spread to trade (pips)

// Includes.
#include <EA31337-classes/Indicators/Indi_Force.mqh>
#include <EA31337-classes/Strategy.mqh>

// Struct to define strategy parameters to override.
struct Stg_Force_Params : StgParams {
  unsigned int Force_Period;
  ENUM_MA_METHOD Force_MA_Method;
  ENUM_APPLIED_PRICE Force_Applied_Price;
  int Force_Shift;
  int Force_SignalOpenMethod;
  float Force_SignalOpenLevel;
  int Force_SignalOpenFilterMethod;
  int Force_SignalOpenBoostMethod;
  int Force_SignalCloseMethod;
  float Force_SignalCloseLevel;
  int Force_PriceLimitMethod;
  float Force_PriceLimitLevel;
  float Force_MaxSpread;

  // Constructor: Set default param values.
  Stg_Force_Params()
      : Force_Period(::Force_Period),
        Force_MA_Method(::Force_MA_Method),
        Force_Applied_Price(::Force_Applied_Price),
        Force_Shift(::Force_Shift),
        Force_SignalOpenMethod(::Force_SignalOpenMethod),
        Force_SignalOpenLevel(::Force_SignalOpenLevel),
        Force_SignalOpenFilterMethod(::Force_SignalOpenFilterMethod),
        Force_SignalOpenBoostMethod(::Force_SignalOpenBoostMethod),
        Force_SignalCloseMethod(::Force_SignalCloseMethod),
        Force_SignalCloseLevel(::Force_SignalCloseLevel),
        Force_PriceLimitMethod(::Force_PriceLimitMethod),
        Force_PriceLimitLevel(::Force_PriceLimitLevel),
        Force_MaxSpread(::Force_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_Force : public Strategy {
 public:
  Stg_Force(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_Force *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_Force_Params _params;
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Stg_Force_Params>(_params, _tf, stg_force_m1, stg_force_m5, stg_force_m15, stg_force_m30,
                                      stg_force_h1, stg_force_h4, stg_force_h4);
    }
    // Initialize strategy parameters.
    ForceParams force_params(_params.Force_Period, _params.Force_MA_Method, _params.Force_Applied_Price);
    force_params.SetTf(_tf);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_Force(force_params), NULL, NULL);
    sparams.logger.Ptr().SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.Force_SignalOpenMethod, _params.Force_SignalOpenLevel, _params.Force_SignalCloseMethod,
                       _params.Force_SignalOpenFilterMethod, _params.Force_SignalOpenBoostMethod,
                       _params.Force_SignalCloseLevel);
    sparams.SetPriceLimits(_params.Force_PriceLimitMethod, _params.Force_PriceLimitLevel);
    sparams.SetMaxSpread(_params.Force_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_Force(sparams, "Force");
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
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0) {
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
        _result = _indi[CURR].value[0] < -_level;
        if (METHOD(_method, 0))
          _result &= _indi[PREV].value[0] < _indi[PPREV].value[0];  // ... 2 consecutive columns are red.
        if (METHOD(_method, 1))
          _result &= _indi[PPREV].value[0] < _indi[3].value[0];                    // ... 3 consecutive columns are red.
        if (METHOD(_method, 2)) _result &= _indi[3].value[0] < _indi[4].value[0];  // ... 4 consecutive columns are red.
        if (METHOD(_method, 3))
          _result &= _indi[PREV].value[0] > _indi[PPREV].value[0];  // ... 2 consecutive columns are green.
        if (METHOD(_method, 4))
          _result &= _indi[PPREV].value[0] > _indi[3].value[0];  // ... 3 consecutive columns are green.
        if (METHOD(_method, 5))
          _result &= _indi[3].value[0] < _indi[4].value[0];  // ... 4 consecutive columns are green.
        break;
      case ORDER_TYPE_SELL:
        // FI recommends to sell (i.e. FI>0).
        _result = _indi[CURR].value[0] > _level;
        if (METHOD(_method, 0))
          _result &= _indi[PREV].value[0] < _indi[PPREV].value[0];  // ... 2 consecutive columns are red.
        if (METHOD(_method, 1))
          _result &= _indi[PPREV].value[0] < _indi[3].value[0];                    // ... 3 consecutive columns are red.
        if (METHOD(_method, 2)) _result &= _indi[3].value[0] < _indi[4].value[0];  // ... 4 consecutive columns are red.
        if (METHOD(_method, 3))
          _result &= _indi[PREV].value[0] > _indi[PPREV].value[0];  // ... 2 consecutive columns are green.
        if (METHOD(_method, 4))
          _result &= _indi[PPREV].value[0] > _indi[3].value[0];  // ... 3 consecutive columns are green.
        if (METHOD(_method, 5))
          _result &= _indi[3].value[0] < _indi[4].value[0];  // ... 4 consecutive columns are green.
        break;
    }
    return _result;
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  float PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    Indi_Force *_indi = Data();
    double level = _level * Chart().GetPipSize();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0: {
        int _bar_count = (int)_level * (int)_indi.GetPeriod();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count));
        break;
      }
      case 1: {
        int _bar_count = (int)_level * (int)_indi.GetPeriod();
        _result = _direction < 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count));
        break;
      }
    }
    return (float)_result;
  }
};
