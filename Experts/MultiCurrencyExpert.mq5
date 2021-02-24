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
string pairs [7] = {"AUDUSD","USDCAD","USDCHF","EURUSD","GBPUSD","USDJPY","NZDUSD"};

struct report_currency_struct{string currency; double value; report_currency_struct(){currency="";value= 0.0;}};
report_currency_struct ccs_icustom [8];
struct report_pair_struct{string pair; string value; report_pair_struct(){pair=""; value= "";}};
report_pair_struct hull_icustom [7];
struct report_final_struct{string currency_weakest; string currency_strongest; report_final_struct(){currency_weakest="";currency_strongest="";}};


struct report_order_struct{string symbol;int type;double profit;double open;double lot;double sl;double tp;int ticket;string comment ;datetime time; report_order_struct(){symbol="";type=0;profit=0.0;open=0.0;lot=0.0;sl=0.0;tp=0.0;ticket=0;time=0;comment="";}};
report_order_struct report_open_order; // order to open


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){EventSetTimer(3); return(INIT_SUCCEEDED);}
void OnDeinit(const int reason){EventKillTimer();}
void OnTimer(){OnTick();}



void OnTick()
  {
      getAllParameters();     //making report
      decisionMaker();    
   
  }

void getAllParameters(){
   getCCS();
   getHull();
}


void getCCS(){};
void getHull(){};

void decisionMaker(){}