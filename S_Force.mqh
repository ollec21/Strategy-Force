//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

/**
 * @file
 * Implementation of Force Strategy based on the Force Index indicator.
 *
 * @docs
 * - https://docs.mql4.com/indicators/iForce
 * - https://www.mql5.com/en/docs/indicators/iForce
 */

// Includes.
#include <EA31337-classes\Strategy.mqh>
#include <EA31337-classes\Strategies.mqh>

// User inputs.
string __Force_Parameters__ = "-- Settings for the Force Index indicator --"; // >>> FORCE <<<
#ifdef __input__ input #endif int Force_Period = 13; // Period
#ifdef __input__ input #endif ENUM_MA_METHOD Force_MA_Method = 0; // MA Method
#ifdef __input__ input #endif ENUM_APPLIED_PRICE Force_Applied_price = 0; // Applied Price
#ifdef __input__ input #endif double Force_SignalLevel = 0.00000000; // Signal level
#ifdef __input__ input #endif int Force1_SignalMethod = 31; // Signal method for M1 (0-
#ifdef __input__ input #endif int Force5_SignalMethod = 31; // Signal method for M5 (0-
#ifdef __input__ input #endif int Force15_SignalMethod = 31; // Signal method for M15 (0-
#ifdef __input__ input #endif int Force30_SignalMethod = 31; // Signal method for M30 (0-

class Force: public Strategy {
protected:

  double iforce[H1][FINAL_ENUM_INDICATOR_INDEX];
  int       open_method = EMPTY;    // Open method.
  double    open_level  = 0.0;     // Open level.

    public:

  /**
   * Update indicator values.
   */
  bool Update(int tf = EMPTY) {
    // Calculates the Force Index indicator.
    for (i = 0; i < FINAL_ENUM_INDICATOR_INDEX; i++) {
      iforce[index][i] = iForce(symbol, tf, Force_Period, Force_MA_Method, Force_Applied_price, i);
    }
    success = (bool) iforce[index][CURR];
  }

  /**
   * Check if Force indicator is on buy or sell.
   *
   * @param
   *   cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   signal_method (int) - signal method to use by using bitwise AND operation
   *   signal_level (double) - signal level to consider the signal
   */
  bool Signal(int cmd, ENUM_TIMEFRAMES tf = PERIOD_M1, int signal_method = EMPTY, double signal_level = EMPTY) {
    bool result = FALSE; int period = Timeframe::TfToIndex(tf);
    UpdateIndicator(S_FORCE, tf);
    if (signal_method == EMPTY) signal_method = GetStrategySignalMethod(S_FORCE, tf, 0);
    if (signal_level  == EMPTY) signal_level  = GetStrategySignalLevel(S_FORCE, tf, 0.0);
    switch (cmd) {
      /*
        //14. Force Index
        //To use the indicator it should be correlated with another trend indicator
        //Flag 14 is 1, when FI recommends to buy (i.e. FI<0)
        //Flag 14 is -1, when FI recommends to sell (i.e. FI>0)
        if (iForce(NULL,piforce,piforceu,MODE_SMA,PRICE_CLOSE,0)<0)
        {f14=1;}
        if (iForce(NULL,piforce,piforceu,MODE_SMA,PRICE_CLOSE,0)>0)
        {f14=-1;}
      */
      case OP_BUY:
        break;
      case OP_SELL:
        break;
    }
    result &= signal_method <= 0 || Convert::ValueToOp(curr_trend) == cmd;
    return result;
  }

};
