//+------------------------------------------------------------------+
//|                                          MultiCurrencyExpert.mq5 |
//|                               Copyright 2021, Chaninnart Chansiu |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Chaninnart Chansiu"
#property link      ""
#property version   "1.00"


#include <Trade\Trade.mqh>
CTrade trade;

string currency [8] = {"AUD","CAD","CHF","EUR","GBP","USD","JPY","NZD"};
string pairs[28] = {"AUDCAD#","AUDCHF#","AUDJPY#","AUDNZD#","AUDUSD#","CADCHF#","CADJPY#","CHFJPY#","EURAUD#","EURCAD#","EURCHF#","EURGBP#","EURJPY#","EURNZD#","EURUSD#","GBPAUD#","GBPCAD#","GBPCHF#","GBPJPY#","GBPNZD#","GBPUSD#","NZDCAD#","NZDCHF#","NZDJPY#","NZDUSD#","USDCAD#","USDCHF#","USDJPY#"};

struct report1_market_summary_struct{string currency; double bid; double ask; int spread; report1_market_summary_struct(){currency="";bid = 0.0; ask =0.0;spread=0;}};
struct report2_ccs_summary_struct{string currency_weakest; string currency_strongest; report2_ccs_summary_struct(){currency_weakest="";currency_strongest="";}};
struct report3_order_struct{string symbol;int type;double profit;double open;double lot;double sl;double tp;int ticket;string comment ;datetime time; report3_order_struct(){symbol="";type=0;profit=0.0;open=0.0;lot=0.0;sl=0.0;tp=0.0;ticket=0;time=0;comment="";}};
//report3_order_struct report_open_order; // order to open

// getMarketSummary's variables 
bool is_custom=false; //for using SymbolExist function     
MqlRates rates[];
int copiedRates [ArraySize(pairs)];  
MqlTick Latest_Price; // Structure to get the latest prices      
int copiedTick [ArraySize(pairs)];
int tickSize;
int spread_current ;  

string debug;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   EventSetTimer(3);   
// checking 28 pairs ready to trade if not replace the pair with the working one.   
   isPairExist(); 
      
   init_handle();     //hull indicator icustom init
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){EventKillTimer();}
void OnTimer(){OnTick();}


void OnTick()  {
   getAllParameters();     //making report
   //check for open symbol status
   if (PositionsTotal()!=0){manage_Order_Strategy();}   
   //if (PositionsTotal()==0){openBuy(0.1,"GBPUSD#");}  
   
   open_Order_Strategy();
}
//---------------- manage order ---------------------------------------------------
void manage_Order_Strategy(){}
//---------------------------------------------------------------------------------

//---------------- open order -----------------------------------------------------
void open_Order_Strategy(){
   double volume = 0.1;
   string symbol = currency[ArrayMaximum(report_ccs_h4)]+ currency[ArrayMinimum(report_ccs_h4)]+ "#";
   bool found_symbol = false;
   int symbol_position ;

   for(int i=0;i<ArraySize(pairs);i++){          
      if(symbol==pairs[i]){found_symbol = true; symbol_position = i;}
   }
   // if not found invert symbol and looking for the position
   if (!found_symbol){symbol = currency[ArrayMinimum(report_ccs_h4)] + currency[ArrayMaximum(report_ccs_h4)] + "#"; }
      for(int i=0;i<ArraySize(pairs);i++){          
         if(symbol==pairs[i]){symbol_position = i;}
   }
//Comment(symbol + "\n" + found_symbol + "\n" + symbol_position + "\n" + report_hull_m15[symbol_position]);
   if (!check_Opened_Pair_Symbol(symbol) ){
      if(found_symbol == true  && report_hull_m15[symbol_position] == "buy") {openBuy(volume,symbol);}
      if(found_symbol == false && report_hull_m15[symbol_position] == "sell"){openSell(volume,symbol);}      
   }
}
//---------------------------------------------------------------------------------
void openBuy(double volume, string symbol){
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS); // number of decimal places
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);         // point
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);             // current price for closing LONG
   double sl=bid-1000*point;  sl=NormalizeDouble(sl,digits);   // normalizing Stop Loss
   double tp=bid+1000*point;  tp=NormalizeDouble(tp,digits);   // normalizing Take Profit
   
   //--- receive the current open price for LONG positions
   double open_price=SymbolInfoDouble(symbol,SYMBOL_ASK);
   string comment=StringFormat("Buy %s %G lots at %s, SL=%s TP=%s", symbol,volume, DoubleToString(open_price,digits), DoubleToString(sl,digits), DoubleToString(tp,digits));
                               
   if(!trade.Buy(volume,symbol,open_price,sl,tp,comment))
         {Print("Buy() method failed. Return code=",trade.ResultRetcode(),". Code description: ",trade.ResultRetcodeDescription());}
   else  {Print("Buy() method executed successfully. Return code=",trade.ResultRetcode()," (",trade.ResultRetcodeDescription(),")");}
}

void openSell(double volume, string symbol){
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS); // number of decimal places
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);         // point
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);             // current price for closing LONG
   double sl=ask+1000*point;  sl=NormalizeDouble(sl,digits);   // normalizing Stop Loss
   double tp=ask-1000*point;  tp=NormalizeDouble(tp,digits);   // normalizing Take Profit
   
   //--- receive the current open price for LONG positions
   double open_price=SymbolInfoDouble(symbol,SYMBOL_BID);
   string comment=StringFormat("Sell %s %G lots at %s, SL=%s TP=%s", symbol,volume, DoubleToString(open_price,digits), DoubleToString(sl,digits), DoubleToString(tp,digits));
                               
   if(!trade.Sell(volume,symbol,open_price,sl,tp,comment))
         {Print("Sell() method failed. Return code=",trade.ResultRetcode(),". Code description: ",trade.ResultRetcodeDescription());}
   else  {Print("Sell() method executed successfully. Return code=",trade.ResultRetcode()," (",trade.ResultRetcodeDescription(),")");}
}


//---------------------------------------------------------------------------------
bool check_Opened_Pair_Symbol(string symbol){
   bool result = false;
   for (int i = 0; i < PositionsTotal(); i++) { 
      //Comment(PositionGetSymbol(i));
      if (symbol == PositionGetSymbol(i)){
         result = true;
      }
   }
   return(result);
}

void getAllParameters(){ 
//------------- get Market Summary Report -------------
//------------- get Hull 28 pairs reports -------------
      for(int i=0; i< ArraySize(pairs); i++){
            getMarketSummary_report(i);            
            getHull_report(i);
      }
//------------- get CCS report -------------            
      getCCS_report();               
         
}


double report_ccs_h4 [8];
void getCCS_report(){
double buffer0 [],buffer1[],buffer2[],buffer3[],buffer4[],buffer5[],buffer6[],buffer7[];
   ArraySetAsSeries(buffer0,true);ArraySetAsSeries(buffer1,true);ArraySetAsSeries(buffer2,true);ArraySetAsSeries(buffer3,true);
   ArraySetAsSeries(buffer4,true);ArraySetAsSeries(buffer5,true);ArraySetAsSeries(buffer6,true);ArraySetAsSeries(buffer7,true);
   CopyBuffer(handle_ccs,0,0,10,buffer0);
   CopyBuffer(handle_ccs,1,0,10,buffer1);
   CopyBuffer(handle_ccs,2,0,10,buffer2);
   CopyBuffer(handle_ccs,3,0,10,buffer3);
   CopyBuffer(handle_ccs,4,0,10,buffer4);
   CopyBuffer(handle_ccs,5,0,10,buffer5);
   CopyBuffer(handle_ccs,6,0,10,buffer6);
   CopyBuffer(handle_ccs,7,0,10,buffer7);   
   
 
   report_ccs_h4[0] = NormalizeDouble(buffer0[0],4);
   report_ccs_h4[1] = NormalizeDouble(buffer1[0],4);
   report_ccs_h4[2] = NormalizeDouble(buffer2[0],4);
   report_ccs_h4[3] = NormalizeDouble(buffer3[0],4);
   report_ccs_h4[4] = NormalizeDouble(buffer4[0],4);
   report_ccs_h4[5] = NormalizeDouble(buffer5[0],4);
   report_ccs_h4[6] = NormalizeDouble(buffer6[0],4); 
   report_ccs_h4[7] = NormalizeDouble(buffer7[0],4); 

Comment("Max/Min: "+ currency[ArrayMaximum(report_ccs_h4)]+ currency[ArrayMinimum(report_ccs_h4)]+"\n"+ report_ccs_h4[0] +"\n"+ report_ccs_h4[1]+"\n"+ report_ccs_h4[2]+"\n"+ report_ccs_h4[3]+"\n"+ report_ccs_h4[4]+"\n"+ report_ccs_h4[5]+"\n"+ report_ccs_h4[6]+"\n"+ report_ccs_h4[7]);
}



//--------------------------------------------------------------------------
int handle_hull[28];    //hull global variable handler
int handle_ccs;
void init_handle(){
      for(int i=0; i< ArraySize(pairs); i++){         //handle hull
         handle_hull[i] = iCustom(pairs[i],PERIOD_M15,"HullAverage2"); 
      }
      
      
      handle_ccs = iCustom(NULL,PERIOD_H4,"FlukeMultiCurrencyIndex"); 
            
}
//--------------------------------------------------------------------------
string report_hull_m15 [28];
void getHull_report(int i){     
      report_hull_m15[i] = getHull_value(i);
//Print("Pair "+i+":"+pairs[i] +"= "+ report_hull_m15[i]); 
};

//--------------------------------------------------------------------------
string getHull_value(int i){  
   double buffer0 [],buffer1[];
   ArraySetAsSeries(buffer0,true);
   ArraySetAsSeries(buffer1,true);

   CopyBuffer(handle_hull[i],0,0,5,buffer0);
   CopyBuffer(handle_hull[i],1,0,5,buffer1);
  
   if (buffer1[1] == 1.0 && buffer1[2] == 2.0){return "buy";} //1.0 = green / 2.0 = red
   if (buffer1[1] == 2.0 && buffer1[2] == 1.0){return "sell";}
return("NONE");
}


//--------------------------------------------------------------------------
void isPairExist(){
      for(int i=0; i< ArraySize(pairs); i++){  
         //-----------check symbol exist------------          
         //if(SymbolExist(pairs[i],is_custom)){/*Print("PASSED: Symbol #0 (",pairs[i],") is exist");*/ }
         if(!SymbolExist(pairs[i],is_custom)){/*Print("ERROR: Symbol #0 (",pairs[i],") not exist !!!!!");*/ 
               pairs[i] = pairs[i]+"#";
                  if(SymbolExist(pairs[i],is_custom)){/*Print("PASSED NEW: Symbol # replaced #0 (",pairs[i],")  !!!!!"); */ }
                  else {pairs[i]= "XXXXXX";}
         }
     }
}

//--------------------------------------------------------------------------
report1_market_summary_struct report_market[28];
void getMarketSummary_report(int i){
         //-----------check bid ask and spread------------   
         copiedRates [i]=CopyRates(pairs[i],PERIOD_CURRENT,0,5,rates);   
         copiedTick [i] = SymbolInfoTick(pairs[i] ,Latest_Price); 
         
         tickSize = SymbolInfoInteger( pairs[i], SYMBOL_DIGITS );
         spread_current = (Latest_Price.ask - Latest_Price.bid)*MathPow(10,tickSize);         
         //-----------assign price to structure------------  
         report_market[i].currency = pairs[i];     
         report_market[i].bid = Latest_Price.bid;     
         report_market[i].ask = Latest_Price.ask;
         report_market[i].spread = spread_current; 
//Print(i,"/",pairs[i],"/",Latest_Price.bid,"/",Latest_Price.ask,"/",spread_current );
}