
#include<Trade\SymbolInfo.mqh>
string pairs [7] = {"AUDUSD","USDCAD","USDCHF","EURUSD","GBPUSD","USDJPY","NZDUSD"};




int OnInit(){
   EventSetTimer(3);
  
   CSymbolInfo symbol_info;      //--- object for receiving symbol settings
   symbol_info.Name(_Symbol);    //--- set the name for the appropriate symbol
   symbol_info.RefreshRates();   //--- receive current rates and display
   Print(symbol_info.Name()," (",symbol_info.Description(),")",
         "  Bid=",symbol_info.Bid(),"   Ask=",symbol_info.Ask());
//--- receive minimum freeze levels for trade operations
   Print("StopsLevel=",symbol_info.StopsLevel()," pips, FreezeLevel=",
         symbol_info.FreezeLevel()," pips");
//--- receive the number of decimal places and point size
   Print("Digits=",symbol_info.Digits(),
         ", Point=",DoubleToString(symbol_info.Point(),symbol_info.Digits()));
//--- spread data
   Print("SpreadFloat=",symbol_info.SpreadFloat(),", Spread(current)=",
         symbol_info.Spread()," pips");
//--- request order execution type for limitations
   Print("Limitations for trade operations: ",EnumToString(symbol_info.TradeMode()),
         " (",symbol_info.TradeModeDescription(),")");
//--- clarifying trades execution mode
   Print("Trades execution mode: ",EnumToString(symbol_info.TradeExecution()),
         " (",symbol_info.TradeExecutionDescription(),")");
//--- clarifying contracts price calculation method
   Print("Contract price calculation: ",EnumToString(symbol_info.TradeCalcMode()),
         " (",symbol_info.TradeCalcModeDescription(),")");
//--- contracts' size
   Print("Standard contract size: ",symbol_info.ContractSize(),
         " (",symbol_info.CurrencyBase(),")");
//--- minimum and maximum volumes in trade operations
   Print("Volume info: LotsMin=",symbol_info.LotsMin(),"  LotsMax=",symbol_info.LotsMax(),
         "  LotsStep=",symbol_info.LotsStep());
//--- final display
   Print(__FUNCTION__,"  completed");
//---
   return(0);
}

void OnTimer(){OnTick();}


void OnTick()
  {
      double ask, bid, point_size, balance, equity ;
      string text;
      
      for(int i=0;i<=6; i++){        
         ask = SymbolInfoDouble(pairs[i],SYMBOL_ASK);
         bid = SymbolInfoDouble(pairs[i],SYMBOL_BID);
         point_size = SymbolInfoDouble(pairs[i], SYMBOL_POINT ); 
         
         balance = AccountInfoDouble(ACCOUNT_BALANCE);
         equity = AccountInfoDouble(ACCOUNT_EQUITY);  
         
         text = text + "\n" + pairs[i] + "/"+ask+"/"+bid+"/"+point_size+"/"+balance +"/"+equity ; 
         comment_this_text(text) ;    
         

      } 
}

void comment_this_text(string text){   
   Print(text);
   Comment(text);   
}






