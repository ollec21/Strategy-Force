//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Force_EURUSD_M15_Params : Stg_Force_Params {
  Stg_Force_EURUSD_M15_Params() {
    symbol = "EURUSD";
    tf = PERIOD_M15;
    Force_Period = 2;
    Force_Applied_Price = 3;
    Force_Shift = 0;
    Force_TrailingStopMethod = 6;
    Force_TrailingProfitMethod = 11;
    Force_SignalOpenLevel = 36;
    Force_SignalBaseMethod = -63;
    Force_SignalOpenMethod1 = 389;
    Force_SignalOpenMethod2 = 0;
    Force_SignalCloseLevel = 36;
    Force_SignalCloseMethod1 = 1;
    Force_SignalCloseMethod2 = 0;
    Force_MaxSpread = 4;
  }
};
