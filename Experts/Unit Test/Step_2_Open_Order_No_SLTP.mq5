#include <Trade\Trade.mqh>

CTrade trade;
string currency [8] = {"AUD","CAD","CHF","EUR","GBP","USD","JPY","NZD"};
string pairs[28] = {"AUDCAD#","AUDCHF#","AUDJPY#","AUDNZD#","AUDUSD#","CADCHF#","CADJPY#","CHFJPY#","EURAUD#","EURCAD#","EURCHF#","EURGBP#","EURJPY#","EURNZD#","EURUSD#","GBPAUD#","GBPCAD#","GBPCHF#","GBPJPY#","GBPNZD#","GBPUSD#","NZDCAD#","NZDCHF#","NZDJPY#","NZDUSD#","USDCAD#","USDCHF#","USDJPY#"};
string pairs2[28] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};

void OnTimer(){OnTick();}
void OnInit(){
   init_handle();
   EventSetTimer(3);
}
//Initialization Process ***************************************************************************
int handle_hull[28];    //hull global variable handler
int handle_rsi[28];
int handle_ccs;

input ENUM_TIMEFRAMES hull_timeframe = PERIOD_M15;
input ENUM_TIMEFRAMES rsi_timeframe = PERIOD_M15;
input ENUM_TIMEFRAMES ccs_timeframe = PERIOD_H4;


void init_handle(){
      for(int i=0; i< ArraySize(pairs); i++){         //handle hull
         handle_hull[i] = iCustom(pairs[i],hull_timeframe,"HullAverage2"); 
         handle_rsi [i] = iRSI(pairs[i],rsi_timeframe,14,PRICE_CLOSE);
      } 
      handle_ccs = iCustom(NULL,ccs_timeframe,"FlukeMultiCurrencyIndex"); 
      //handle_ccs = iCustom(NULL,PERIOD_H4,"FlukeMultiCurrencyIndex"); 
      
}
//-----------------------------------------------------------------------------


void OnTick(){
   getAllParameters();   
   printInfo();
   printOrderInfo();
   if (PositionsTotal()!=0){close_Order_Strategy();}  
   open_Order_Strategy();        
}

input int slippage = 10; //slippage
input double profit_target = 20;
void close_Order_Strategy(){ 
   for (int i =0; i<PositionsTotal(); i++){   
      if(report_orders[i].profit > profit_target){      
         if(!trade.PositionClose(report_orders[i].pos_id,slippage))
            {Print("Close Position failed. Return code=",trade.ResultRetcode());}
         else  {Print("Close Position successfully. Return code=",trade.ResultRetcode());}
      }
   }
}


void open_Order_Strategy(){
   double volume = 0.1;
   bool is_pair_already_open = check_Opened_Pair_Symbol(bestpair);
   if (!is_pair_already_open ){
         if(invert_pair == false ){openBuy(volume,bestpair);}  
         if(invert_pair == true  ){openSell(volume,bestpair);}
      //if(invert_pair == false && report_hull_m15[check_Pair_Position_in_Array(bestpair)] == "b"){openBuy(volume,bestpair);}  
      //if(invert_pair == true  && report_hull_m15[check_Pair_Position_in_Array(bestpair)] == "s") {openSell(volume,bestpair);}    
   }
}

input int SL_input = 0;
input int TP_input = 0;
void openBuy(double volume, string symbol){
   trade.SetExpertMagicNumber(my_magic);
   int digits = (int)SymbolInfoInteger(symbol,SYMBOL_DIGITS); // number of decimal places
   double point = SymbolInfoDouble(symbol,SYMBOL_POINT);         // point
   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);             // current price for closing LONG
   double sl = bid - SL_input*point;  //sl=NormalizeDouble(sl,digits);   // normalizing Stop Loss
   double tp = bid + TP_input*point;  //tp=NormalizeDouble(tp,digits);   // normalizing Take Profit
   if (SL_input==0){sl = 0;} if (TP_input==0){tp = 0;}
   
   //--- receive the current open price for LONG positions
   double open_price=SymbolInfoDouble(symbol,SYMBOL_ASK);
   string comment=StringFormat("Buy %s %G lots at %s, SL=%s TP=%s", symbol,volume, DoubleToString(open_price,digits), DoubleToString(sl,digits), DoubleToString(tp,digits));
                               
   if(!trade.Buy(volume,symbol,open_price,sl,tp,comment))
         {Print("Buy() method failed. Return code=",trade.ResultRetcode(),". Code description: ",trade.ResultRetcodeDescription());}
   else  {Print("Buy() method executed successfully. Return code=",trade.ResultRetcode()," (",trade.ResultRetcodeDescription(),")");}
}

void openSell(double volume, string symbol){
   trade.SetExpertMagicNumber(my_magic);
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS); // number of decimal places
   double point = SymbolInfoDouble(symbol,SYMBOL_POINT);         // point
   double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);             // current price for closing LONG
   double sl = ask + SL_input*point;  //sl = NormalizeDouble(sl,digits);   // normalizing Stop Loss
   double tp = ask - TP_input*point;  //tp = NormalizeDouble(tp,digits);   // normalizing Take Profit
   if (SL_input==0){sl = 0;} if (TP_input==0){tp = 0;}
   
   //--- receive the current open price for LONG positions
   double open_price=SymbolInfoDouble(symbol,SYMBOL_BID);
   string comment=StringFormat("Sell %s %G lots at %s, SL=%s TP=%s", symbol,volume, DoubleToString(open_price,digits), DoubleToString(sl,digits), DoubleToString(tp,digits));
                               
   if(!trade.Sell(volume,symbol,open_price,sl,tp,comment))
         {Print("Sell() method failed. Return code=",trade.ResultRetcode(),". Code description: ",trade.ResultRetcodeDescription());}
   else  {Print("Sell() method executed successfully. Return code=",trade.ResultRetcode()," (",trade.ResultRetcodeDescription(),")");}
}






















//***********************************************************************************************************************
void getAllParameters(){
      for(int i=0; i< ArraySize(pairs); i++){
            getMarketSummary_report(i);            
            getHull_report(i);
            getRSI_report(i);
      }              
      getCCS_report(); 
      
      getOrdersInfo_report();         
}


//getOrdersInfo_report********************************************************************************************************
long my_magic = "5652534";
struct report1_orders_info_struct{string currency; long pos_id; double price; long pos_magic ;string comment; datetime dt;double profit; report1_orders_info_struct(){currency="";pos_id = 0; price =0.0; pos_magic = "5652534"; comment = ""; dt = 0; profit = 0.0;}};
report1_orders_info_struct report_orders[28];
void getOrdersInfo_report(){
{
//--- obtain the total number of positions
   int positions=PositionsTotal();
//--- scan the list of orders
   for(int i=0;i<positions;i++)
     {
      ResetLastError();
      //--- copy into the cache, the position by its number in the list
      string symbol=PositionGetSymbol(i); //  obtain the name of the symbol by which the position was opened
      if(symbol!="") // the position was copied into the cache, work with it
        {
         long pos_id             = PositionGetInteger(POSITION_IDENTIFIER);
         double price            = PositionGetDouble(POSITION_PRICE_OPEN);
         //ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         long pos_magic          = PositionGetInteger(POSITION_MAGIC);
         string comment          = PositionGetString(POSITION_COMMENT);
         long pos_datetime       = PositionGetInteger(POSITION_IDENTIFIER);
         datetime dt             = PositionGetInteger(POSITION_TIME);
         double profit           = PositionGetDouble(POSITION_PROFIT);
         //if(pos_magic==my_magic)
           //{
           //  process the position with a specified POSITION_MAGIC
               report_orders[i].currency =symbol;  
               report_orders[i].pos_id = pos_id;
               report_orders[i].price = price;
               report_orders[i].pos_magic = pos_magic;
               report_orders[i].comment = comment;
               report_orders[i].dt = dt;
               report_orders[i].profit = profit ;
          // }
         //PrintFormat("Position #%d by %s: POSITION_MAGIC=%d, price=%G, type=%s, commentary=%s",pos_id,symbol,pos_magic,price,comment);
        }
      else           // call to PositionGetSymbol() was unsuccessful
        {
         //PrintFormat("Error when receiving into the cache the position with index %d."+" Error code: %d", i, GetLastError());
        }
     }
  }
}



//getMarketSummary_report********************************************************************************************************
struct report1_market_summary_struct{string currency; double bid; double ask; int spread; report1_market_summary_struct(){currency="";bid = 0.0; ask =0.0;spread=0;}};
report1_market_summary_struct report_market[28];
MqlRates rates[]; MqlTick Latest_Price; // Structure to get the latest prices   
int copiedRates [28]; int copiedTick [28]; int tickSize [28]; int spread_current ;  void getMarketSummary_report(int i){
         //-----------check bid ask and spread------------   
         copiedRates [i]=CopyRates(pairs[i],PERIOD_CURRENT,0,5,rates);   
         copiedTick [i] = SymbolInfoTick(pairs[i] ,Latest_Price); 
         
         tickSize [i] = SymbolInfoInteger( pairs[i], SYMBOL_DIGITS );
         spread_current = (Latest_Price.ask - Latest_Price.bid)*MathPow(10,tickSize [i]);         
         //-----------assign price to structure------------  
         report_market[i].currency = pairs[i];     
         report_market[i].bid = Latest_Price.bid;     
         report_market[i].ask = Latest_Price.ask;
         report_market[i].spread = spread_current; 
//Print(i,"/",pairs[i],"/",Latest_Price.bid,"/",Latest_Price.ask,"/",spread_current );
}
//------------------------------------------------------------------------------------------------------------------------

//HULL ********************************************************************************************************************
string report_hull_m15 [28];
void getHull_report(int i){     
   double buffer1[];
   ArraySetAsSeries(buffer1,true);
   CopyBuffer(handle_hull[i],1,0,5,buffer1);   
   report_hull_m15[i] = " "; 
   if (buffer1[1] == 1.0 && buffer1[2] == 2.0){report_hull_m15[i] = "b";} //1.0 = green / 2.0 = red
   if (buffer1[1] == 2.0 && buffer1[2] == 1.0){report_hull_m15[i] = "s";}
};
//-------------------------------------------------------------------------------------------------------------------------

//RSI*******************************************************************************************************
double report_rsi [28];
void getRSI_report(int i){
   double buffer[];
   ArraySetAsSeries(buffer,true);
   CopyBuffer(handle_rsi[i],0,0,5,buffer);   
   report_rsi[i] = buffer[0] ; 
}
//--------------------------------------------------------------------------------------------------------------

//CCS*****************************************************************************************************************
double report_ccs_h4 [8];
string bestpair;
bool invert_pair;
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
 
   report_ccs_h4[0] = buffer0[0];
   report_ccs_h4[1] = buffer1[0];
   report_ccs_h4[2] = buffer2[0];
   report_ccs_h4[3] = buffer3[0];
   report_ccs_h4[4] = buffer4[0];
   report_ccs_h4[5] = buffer5[0];
   report_ccs_h4[6] = buffer6[0]; 
   report_ccs_h4[7] = buffer7[0]; 

   bestpair = currency[ArrayMaximum(report_ccs_h4)] +currency[ArrayMinimum(report_ccs_h4)] ;
   
   bool found_pair = false; invert_pair = false;
      for(int i=0; i< ArraySize(pairs2); i++){
         if (bestpair == pairs2[i]){found_pair = true;}
      } 
      if (found_pair != true){bestpair = currency[ArrayMinimum(report_ccs_h4)]+ currency[ArrayMaximum(report_ccs_h4)];invert_pair=true;}
   bestpair = bestpair + "#";   
//Comment("Max/Min: "+ currency[ArrayMaximum(report_ccs_h4)]+ currency[ArrayMinimum(report_ccs_h4)]+"\n"+ report_ccs_h4[0] +"\n"+ report_ccs_h4[1]+"\n"+ report_ccs_h4[2]+"\n"+ report_ccs_h4[3]+"\n"+ report_ccs_h4[4]+"\n"+ report_ccs_h4[5]+"\n"+ report_ccs_h4[6]+"\n"+ report_ccs_h4[7]);
}
//-----------------------------------------------------------------------------------------------------------------------

//Helper Functions***************************************************************************************
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

int check_Pair_Position_in_Array(string symbol){
   for(int i=0;i<ArraySize(pairs);i++){          
         if(symbol==pairs[i]){return (i);}
   }
   return (-1);
}




//Show Output On Screen*********************************************************************************************************
string text[30]; //Array of String store custom texts on screen
void printInfo()
{ 
   for (int i = 0; i < ArraySize(pairs); i++) {    
      text[i] = "";
         if (i<10) {text[i] = "0"+text [i];}    //arrange the text 00-09
      text[i] = text[i] + i + ". " +  pairs[i]+ " : ";
         //string bid = DoubleToString(report_market[i].bid,5);
         //if (tickSize[i]==3 ){bid = "  "+DoubleToString(report_market[i].bid,3);}
         //if (StringLen(bid) == 7){bid = bid+ " ";} 
      //text[i] = text[i] + bid + " | " ;
      //   string ask = DoubleToString(report_market[i].ask,5);
      //text[i] = text[i] + ask  ;   
      text[i] = text[i] + "   *   HULL(15M) = ";
      text[i] = text[i] + report_hull_m15 [i];
      text[i] = text[i] + "   *    RSI(15M) = ";
      text[i] = text[i] + DoubleToString(report_rsi [i],1);
         
   }
   
   text[28] = "The Strongest/Weakest (4Hrs) = "+ bestpair +" (Invert Pair: " + invert_pair + ")";
   text[29] = "-------Fluke--------";

   int i=0, k=20;
   while (i<30)
   {
      string object_name = DoubleToString(i, 0);
      ObjectCreate(0,object_name, OBJ_LABEL,0,0,0);
      ObjectSetString(0,object_name,OBJPROP_FONT,"Arial");
      ObjectGetInteger(0,object_name,OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,object_name,OBJPROP_COLOR,clrOrange);
      
      ObjectSetInteger(0,object_name,OBJPROP_CORNER,CORNER_LEFT_UPPER); 
      ObjectSetInteger(0,object_name,OBJPROP_XDISTANCE,5);
      ObjectSetInteger(0,object_name,OBJPROP_YDISTANCE,k);       

      ObjectSetString(0,object_name,OBJPROP_TEXT,text[i]);
      i++;
      k=k+16;
   }       
      ObjectCreate(0,"vline", OBJ_VLINE,0,TimeCurrent(),0);
      ObjectSetInteger(0,"vline",OBJPROP_COLOR,clrWheat);
      ObjectSetInteger(0,"vline",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,"vline",OBJPROP_WIDTH,2);
      ObjectSetInteger(0,"vline",OBJPROP_BACK,false);
}
//-----------------------------------------------------------------------------

string text1[30]; //Array of String store custom texts on screen
void printOrderInfo(){
   for (int i = 0; i < ArraySize(pairs); i++) {    
      text1[i] = "";
      text1[i] = i + ": ";         
      text1[i] = text1[i] + report_orders[i].currency;   
      //text1[i] = text1[i] + " | Id = ";
      //text1[i] = text1[i] + report_orders[i].pos_id;
      text1[i] = text1[i] + " | Price = ";
      text1[i] = text1[i] + DoubleToString(report_orders[i].price,3);
      //text1[i] = text1[i] + " | Magic = ";
      //text1[i] = text1[i] + report_orders[i].pos_magic;
      //text1[i] = text1[i] + " | Date = ";
      //text1[i] = text1[i] + TimeToString(report_orders[i].dt);      
      text1[i] = text1[i] + " | Profit = ";
      text1[i] = text1[i] + DoubleToString(report_orders[i].profit,2);  
      
      if(report_orders[i].currency ==""){text1[i]=" ";}        
   }
   
   text1[28] = "-------------------------------------------------------------";
   text1[29] = "-------Fluke--------";

   int i=0, k=20;
   while (i<30)
   {
      string object_name = "Order"+DoubleToString(i, 0);
      ObjectCreate(0,object_name, OBJ_LABEL,0,0,0);
      ObjectSetString(0,object_name,OBJPROP_FONT,"Arial");
      ObjectGetInteger(0,object_name,OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,object_name,OBJPROP_COLOR,clrWhite);
      
      ObjectSetInteger(0,object_name,OBJPROP_CORNER,CORNER_LEFT_UPPER); 
      ObjectSetInteger(0,object_name,OBJPROP_XDISTANCE,400);
      ObjectSetInteger(0,object_name,OBJPROP_YDISTANCE,k);       

      ObjectSetString(0,object_name,OBJPROP_TEXT,text1[i]);
      i++;
      k=k+16;
   } 

}


