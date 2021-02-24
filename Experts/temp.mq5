#include <Trade\Trade.mqh>
CTrade trade;

string currency [8] = {"AUD","CAD","CHF","EUR","GBP","USD","JPY","NZD"};
string pairs [7] = {"AUDUSD","USDCAD","USDCHF","EURUSD","GBPUSD","USDJPY","NZDUSD"};
string pairs_invert[7] = {"USDAUD","CADUSD","CHFUSD","USDEUR","USDGBP","JPYUSD","USDNZD"};

int hull_handle;  //handle icustom
int ccs_handle;   //handle icustom

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
   string condition_ccs = handle_ccs();    
   
   
      
   if(condition_ccs!="NONE"){          
         ask = SymbolInfoDouble(condition_ccs,SYMBOL_ASK);
         bid = SymbolInfoDouble(condition_ccs,SYMBOL_BID);
         point_size = SymbolInfoDouble(condition_ccs, SYMBOL_POINT ); 
         
         balance = AccountInfoDouble(ACCOUNT_BALANCE);
         equity = AccountInfoDouble(ACCOUNT_EQUITY);  
         
         int check_pair_status =check_pair(condition_ccs);
      
      if(check_pair(condition_ccs) != -1){
         if (check_pair_status == 1){
            if((condition_hull == "buy") && (!Is_Symbol_Already_Open(condition_ccs))){
               trade.Buy(0.10,condition_ccs,ask,(bid - 300 * point_size),(ask + 300 * point_size),NULL);  //.Buy(volume,symbol,open_price,SL,TP,comment)
            }
            if((condition_hull == "sell") && (!Is_Symbol_Already_Open(condition_ccs))){
               trade.Sell(0.10,condition_ccs,bid,(ask + 300 * point_size),(bid - 300 * point_size),NULL);      
            }
         }
         
         if (check_pair_status == 2){
            if((condition_hull == "buy") && (!Is_Symbol_Already_Open(condition_ccs))){
               trade.Buy(0.10,condition_ccs,ask,(bid - 300 * point_size),(ask + 300 * point_size),NULL);  //.Buy(volume,symbol,open_price,SL,TP,comment)
            }
            if((condition_hull == "sell") && (!Is_Symbol_Already_Open(condition_ccs))){
               trade.Sell(0.10,condition_ccs,bid,(ask + 300 * point_size),(bid - 300 * point_size),NULL);      
            }
         }
      }  
      
       
      //text = text + "\n" + pairs[i] + "/"+ask+"/"+bid+"/"+point_size+"/"+balance +"/"+equity ;    
      //Print(text);
      //Comment(text); 
   }   
      
}

int check_pair(string pair_to_check){
   for(int i=0;i<ArraySize(pairs);i++)
     {
      if(StringFind(pairs[i],pair_to_check) != -1)
        {
         Comment(pair_to_check);
         return(1);         
        }       
     }
   
   for(int i=0;i<ArraySize(pairs);i++)
     {
      if(StringFind(pairs_invert[i],pair_to_check) != -1)
        {
         Comment(pair_to_check);
         return(2);         
        }       
  }  
     
     
   return(-1);     
}

  
void handle_init(){
      ccs_handle = iCustom(NULL,PERIOD_H4,"FlukeMultiCurrencyIndex"); 
      handle_ccs();
  
}


string handle_ccs(){   
     
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

string pair_to_trade = currency[ArrayMaximum(ccs_score_array)]+currency[ArrayMinimum(ccs_score_array)];

return (pair_to_trade);
}

string handle_hull(string pair){
      
   hull_handle = iCustom(pair,PERIOD_H1,"HullAverage2");
   
   
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



