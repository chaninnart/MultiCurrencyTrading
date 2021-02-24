#include <Trade\Trade.mqh>
CTrade trade;

string currency [8] = {"AUD","CAD","CHF","EUR","GBP","USD","JPY","NZD"};
string pairs [7] = {"AUDUSD","USDCAD","USDCHF","EURUSD","GBPUSD","USDJPY","NZDUSD"};

int ccs_handle;   //handle icustom
int hull_handle_AUDUSD;  //handle icustom
int hull_handle_USDCAD;  //handle icustom
int hull_handle_USDCHF;  //handle icustom
int hull_handle_EURUSD;  //handle icustom
int hull_handle_GBPUSD;  //handle icustom
int hull_handle_USDJPY;  //handle icustom
int hull_handle_NZDUSD;  //handle icustom

string text; //for debuging


void OnInit(){
   //EventSetTimer(3);
      handle_init();
 
}

void OnTimer(){
   //OnTick();
}


void OnTick()
  {
    
    handle_ccs();
    handle_hull();  
      
   text = "";     
   double ask, bid, point_size, balance, equity ;
   string condition_hull = handle_hull();      
      
  
   for(int i=0;i<=6; i++){        
         ask = SymbolInfoDouble(pairs[i],SYMBOL_ASK);
         bid = SymbolInfoDouble(pairs[i],SYMBOL_BID);
         point_size = SymbolInfoDouble(pairs[i], SYMBOL_POINT ); 
         
         balance = AccountInfoDouble(ACCOUNT_BALANCE);
         equity = AccountInfoDouble(ACCOUNT_EQUITY);  
         
      if((condition_hull == "buy") && (!Is_Symbol_Already_Open(pairs[i]))){
         trade.Buy(0.01,pairs[i],ask,0,(ask + 100 * point_size),NULL);  //.Buy(volume,symbol,open_price,SL,TP,comment)
      }
      if((condition_hull == "sell") && (!Is_Symbol_Already_Open(pairs[i]))){
         trade.Sell(0.01,pairs[i],bid,0,(bid - 100 * point_size),NULL);
      }
         
      text = text + "\n" + pairs[i] + "/"+ask+"/"+bid+"/"+point_size+"/"+balance +"/"+equity ;    
      //Print(text);
      Comment(text); 
  }     
      
}

  
void handle_init(){
      ccs_handle = iCustom(NULL,PERIOD_CURRENT,"FlukeMultiCurrencyIndex"); 
      handle_ccs();
      
 hull_handle_AUDUSD= iCustom("AUDUSD",PERIOD_CURRENT,"HullAverage2");
 hull_handle_USDCAD= iCustom("USDCAD",PERIOD_CURRENT,"HullAverage2");
 hull_handle_USDCHF= iCustom("USDCHF",PERIOD_CURRENT,"HullAverage2");
 hull_handle_EURUSD= iCustom("EURUSD",PERIOD_CURRENT,"HullAverage2");
 hull_handle_GBPUSD= iCustom("GBPUSD",PERIOD_CURRENT,"HullAverage2");
 hull_handle_USDJPY= iCustom("USDJPY",PERIOD_CURRENT,"HullAverage2");
 hull_handle_NZDUSD= iCustom("NZDUSD",PERIOD_CURRENT,"HullAverage2");

      handle_hull();  
}


void handle_ccs(){   
     
   double ccs_buffer0 [],ccs_buffer1[],ccs_buffer2[],ccs_buffer3[],ccs_buffer4[],ccs_buffer5[],ccs_buffer6[],ccs_buffer7[];
   ArraySetAsSeries(ccs_buffer0,true);
   ArraySetAsSeries(ccs_buffer1,true);
   ArraySetAsSeries(ccs_buffer2,true);
   ArraySetAsSeries(ccs_buffer3,true);
   ArraySetAsSeries(ccs_buffer4,true);
   ArraySetAsSeries(ccs_buffer5,true);
   ArraySetAsSeries(ccs_buffer6,true);
   ArraySetAsSeries(ccs_buffer7,true);
   CopyBuffer(ccs_handle,0,0,10,ccs_buffer0);
   CopyBuffer(ccs_handle,1,0,10,ccs_buffer1);
   CopyBuffer(ccs_handle,2,0,10,ccs_buffer2);
   CopyBuffer(ccs_handle,3,0,10,ccs_buffer3);
   CopyBuffer(ccs_handle,4,0,10,ccs_buffer4);
   CopyBuffer(ccs_handle,5,0,10,ccs_buffer5);
   CopyBuffer(ccs_handle,6,0,10,ccs_buffer6);
   CopyBuffer(ccs_handle,7,0,10,ccs_buffer7);   
   
   double ccs_score_array[8];    
   ccs_score_array[0] = NormalizeDouble(ccs_buffer0[0],4);
   ccs_score_array[1] = NormalizeDouble(ccs_buffer0[1],4);
   ccs_score_array[2] = NormalizeDouble(ccs_buffer0[2],4);
   ccs_score_array[3] = NormalizeDouble(ccs_buffer0[3],4);
   ccs_score_array[4] = NormalizeDouble(ccs_buffer0[4],4);
   ccs_score_array[5] = NormalizeDouble(ccs_buffer0[5],4);
   ccs_score_array[6] = NormalizeDouble(ccs_buffer0[6],4); 
   ccs_score_array[7] = NormalizeDouble(ccs_buffer0[7],4);    

//Comment(ccs_buffer0[0] +"\n"+ ccs_buffer1[0]+"\n"+ ccs_buffer2[0]+"\n"+ ccs_buffer3[0]+"\n"+ ccs_buffer4[0]+"\n"+ ccs_buffer5[0]+"\n"+ ccs_buffer6[0]+"\n"+ ccs_buffer7[0]);
//Comment("Max/Min:"+ currency[ArrayMaximum(ccs_score_array)]+"/"+ currency[ArrayMinimum(ccs_score_array)]+"\n"+ ccs_score_array[0] +"\n"+ ccs_score_array[1]+"\n"+ ccs_score_array[2]+"\n"+ ccs_score_array[3]+"\n"+ ccs_score_array[4]+"\n"+ ccs_score_array[5]+"\n"+ ccs_score_array[6]+"\n"+ ccs_score_array[7]);
}

string handle_hull(){

   
   double hull_buffer0[],hull_buffer1[];
   
   ArraySetAsSeries(hull_buffer0,true);
   ArraySetAsSeries(hull_buffer1,true);
   CopyBuffer(hull_handle,0,0,2,hull_buffer0);
   CopyBuffer(hull_handle,1,0,2,hull_buffer1);
   
   if (hull_buffer1[0] == 1.0 && hull_buffer1[1] == 2.0){return "buy";} //1.0 = green / 2.0 = red
   if (hull_buffer1[0] == 2.0 && hull_buffer1[1] == 1.0){return "sell";}
//Comment(hull_buffer0[0] +"\n"+ hull_buffer1[0]+"\n");
   return "wait";
}  



bool Is_Symbol_Already_Open(string check_this_symbol){
   
   CPositionInfo myposition;
   int order_total=PositionsTotal();
   
   if (order_total == 0){
      Print("No open order *******************************************");      
      return false;
   }
   
   Print("Checking Open Order for symbol: "+ check_this_symbol);   
   
   for(int i=0; i<order_total; i++)
     {
      if(myposition.Select(PositionGetSymbol(i)))
        {
          string open_symbol=myposition.Symbol();          
          if (open_symbol == check_this_symbol){
            Print("***** Already Open Symbol "+ check_this_symbol);
            return true;
          }         
        }
     } 
   Print(check_this_symbol + " Not open yet! *****");  
   return (false);
}



