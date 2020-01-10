//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements Force strategy for the Force Index indicator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_Force.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __Force_Parameters__ = "-- Force strategy params --";  // >>> FORCE <<<
INPUT int Force_Active_Tf = 0;  // Activate timeframes (1-255, e.g. M1=1,M5=2,M15=4,M30=8,H1=16,H2=32...)
INPUT ENUM_TRAIL_TYPE Force_TrailingStopMethod = 7;     // Trail stop method
INPUT ENUM_TRAIL_TYPE Force_TrailingProfitMethod = 22;  // Trail profit method
INPUT int Force_Period = 38;                            // Period
INPUT ENUM_MA_METHOD Force_MA_Method = 0;               // MA Method
INPUT ENUM_APPLIED_PRICE Force_Applied_Price = 2;       // Applied Price
INPUT double Force_SignalOpenLevel = 0;                 // Signal open level
INPUT int Force_Shift = 1;                              // Shift (relative to the current bar, 0 - default)
INPUT int Force1_SignalBaseMethod = 0;                  // Signal base method (0-
INPUT int Force1_OpenCondition1 = 971;                  // Open condition 1 (0-1023)
INPUT int Force1_OpenCondition2 = 0;                    // Open condition 2 (0-)
INPUT ENUM_MARKET_EVENT Force1_CloseCondition = 1;      // Close condition for M1
INPUT double Force_MaxSpread = 6.0;                     // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_Force_Params : Stg_Params {
  unsigned int Force_Period;
  ENUM_APPLIED_PRICE Force_Applied_Price;
  int Force_Shift;
  ENUM_TRAIL_TYPE Force_TrailingStopMethod;
  ENUM_TRAIL_TYPE Force_TrailingProfitMethod;
  double Force_SignalOpenLevel;
  long Force_SignalBaseMethod;
  long Force_SignalOpenMethod1;
  long Force_SignalOpenMethod2;
  double Force_SignalCloseLevel;
  ENUM_MARKET_EVENT Force_SignalCloseMethod1;
  ENUM_MARKET_EVENT Force_SignalCloseMethod2;
  double Force_MaxSpread;

  // Constructor: Set default param values.
  Stg_Force_Params()
      : Force_Period(::Force_Period),
        Force_Applied_Price(::Force_Applied_Price),
        Force_Shift(::Force_Shift),
        Force_TrailingStopMethod(::Force_TrailingStopMethod),
        Force_TrailingProfitMethod(::Force_TrailingProfitMethod),
        Force_SignalOpenLevel(::Force_SignalOpenLevel),
        Force_SignalBaseMethod(::Force_SignalBaseMethod),
        Force_SignalOpenMethod1(::Force_SignalOpenMethod1),
        Force_SignalOpenMethod2(::Force_SignalOpenMethod2),
        Force_SignalCloseLevel(::Force_SignalCloseLevel),
        Force_SignalCloseMethod1(::Force_SignalCloseMethod1),
        Force_SignalCloseMethod2(::Force_SignalCloseMethod2),
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
    switch (_tf) {
      case PERIOD_M1: {
        Stg_Force_EURUSD_M1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M5: {
        Stg_Force_EURUSD_M5_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M15: {
        Stg_Force_EURUSD_M15_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M30: {
        Stg_Force_EURUSD_M30_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H1: {
        Stg_Force_EURUSD_H1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H4: {
        Stg_Force_EURUSD_H4_Params _new_params;
        _params = _new_params;
      }
    }
    // Initialize strategy parameters.
    ChartParams cparams(_tf);
    Force_Params adx_params(_params.Force_Period, _params.Force_Applied_Price);
    IndicatorParams adx_iparams(10, INDI_Force);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_Force(adx_params, adx_iparams, cparams), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.Force_SignalBaseMethod, _params.Force_SignalOpenMethod1, _params.Force_SignalOpenMethod2,
                       _params.Force_SignalCloseMethod1, _params.Force_SignalCloseMethod2,
                       _params.Force_SignalOpenLevel, _params.Force_SignalCloseLevel);
    sparams.SetStops(_params.Force_TrailingProfitMethod, _params.Force_TrailingStopMethod);
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
   *   _signal_method (int) - signal method to use by using bitwise AND operation
   *   _signal_level1 (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    bool _result = false;
    double force_0 = ((Indi_Force *)this.Data()).GetValue(0);
    double force_1 = ((Indi_Force *)this.Data()).GetValue(1);
    double force_2 = ((Indi_Force *)this.Data()).GetValue(2);
    if (_signal_method == EMPTY) _signal_method = GetSignalBaseMethod();
    if (_signal_level1 == EMPTY) _signal_level1 = GetSignalLevel1();
    if (_signal_level2 == EMPTY) _signal_level2 = GetSignalLevel2();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // FI recommends to buy (i.e. FI<0).
        _result = force_0 < -_signal_level1;
        break;
      case ORDER_TYPE_SELL:
        // FI recommends to sell (i.e. FI>0).
        _result = force_0 > _signal_level1;
        break;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    if (_signal_level == EMPTY) _signal_level = GetSignalCloseLevel();
    return SignalOpen(Order::NegateOrderType(_cmd), _signal_method, _signal_level);
  }
};
