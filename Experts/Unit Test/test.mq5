//+------------------------------------------------------------------+
//|                                                  SymbolExist.mq5 |
//|                              Copyright © 2019, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.00"
//--- input parameters
input string   InpSymbol_0 = "EURUSD"; // Symbol #0
input string   InpSymbol_1 = "EURUSD#"; // Symbol #1
input string   InpSymbol_2 = "USDJPY"; // Symbol #2
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   bool is_custom=false;
   if(!SymbolExist(InpSymbol_0,is_custom))
     {
      Print(__FILE__," ",__FUNCTION__,", ERROR: Symbol #0 (",InpSymbol_0,") is not exist");
      return(INIT_FAILED);
     }
   if(!SymbolExist(InpSymbol_1,is_custom))
     {
      Print(__FILE__," ",__FUNCTION__,", ERROR: Symbol #1 (",InpSymbol_1,") is not exist");
      return(INIT_FAILED);
     }
   if(!SymbolExist(InpSymbol_2,is_custom))
     {
      Print(__FILE__," ",__FUNCTION__,", ERROR: Symbol #2 (",InpSymbol_2,") is not exist");
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+




