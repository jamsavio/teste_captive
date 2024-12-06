//+------------------------------------------------------------------+
//|                                                   freela_180.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   ""
#property strict
#property indicator_buffers 9
#property indicator_chart_window
#property indicator_color1 clrWhite
#property indicator_color2 clrWhite
#property indicator_color3 clrWhite
#property indicator_color4 clrWhite
#property indicator_color5 clrWhite
#property indicator_color6 clrLawnGreen
#property indicator_color7 clrRed
#property indicator_color9 clrLime

#define CALL 1
#define PUT -1
#define EXAMPLE_PHOTO "C:\\Users\\Usuario\\AppData\\Roaming\\MetaQuotes\\Terminal\\9D15457EC01AD10E06A932AAC616DC32\\MQL4\\Files\\exemplo.jpg"
#define KEY_DELETE 46

string MSG_INICIO_MANHA = "E113 Bora para a Sessão da madrugada Galera começando... E110E110"
                          "Faça cadastro na Corretora e ganhe 200% de BONUS E110E110"
                         "https://linktr.ee/traderextreme";
string MSG_FIM_MANHA = "Finalizando as operações do período da manhã"; 
#define STOP_ATINGIDO_MANHA "Stop atingido no período da manhã, retornamos a tarde"
#define TAKE_ATINGIDO_MANHA "Take atingido no período da manhã, retornamos a tarde"

string MSG_INICIO_TARDE = "E113 Bora para a Sessão da TARDE Galerinha. E110E110"
                         "Faça cadastro na Corretora GOGO E110E110"
                         "https://linktr.ee/traderextreme";
string MSG_FIM_TARDE = "Finalizando as operações do período da tarde";
#define STOP_ATINGIDO_TARDE "Stop atingido no período da tarde, retornamos a noite"
#define TAKE_ATINGIDO_TARDE "Take atingido no período da tarde, retornamos a noite"

string MSG_INICIO_NOITE = "E113 Bora iniciar a sessão da noite Galera.. E110E110"
                         "Faça cadastro na corretora e ganhe o ExBotIA E110E110"
                         "https://linktr.ee/traderextreme";
string MSG_FIM_NOITE = "Finalizando as operações do período da noite";
#define STOP_ATINGIDO_NOITE "Stop atingido no período da noite, retornamos às 00:00 .."
#define TAKE_ATINGIDO_NOITE "Take atingido no período da noite, retornamos às 00:00 ..."

/*#import "Connector_Lib.ex4"
void put(const string ativo, const int periodo, const char modalidade, const int sinal_entrada, const string vps);
void call(const string ativo, const int periodo, const char modalidade, const int sinal_entrada, const string vps);
#import*/

#import "Connector_Broadcast_Lib.ex4"
void call(const string ativo, const int periodo, const char modalidade, const int sinal_entrada, const string nome_estrategia, const string vpss);
void put(const string ativo, const int periodo, const char modalidade, const int sinal_entrada, const string nome_estrategia, const string vpss);
string carregar_vpss();
#import

#import "MX2Trading_library.ex4"
   bool mx2trading(string par, string direcao, int expiracao, string sinalNome, int Signaltipo, int TipoExpiracao, string TimeFrame, string mID, string Corretora);
#import

#include <mq4-http.mqh>
//#include <wpp_telegram.mqh>

void sendwhats(string msg) {
   string resposta = httpGET("http://localhost:5000/wpi?message="+msg+"&grupo="+grupo);
}

enum status
{
   ativar=1, //ativado
   desativar=0 //desativado
};

enum buffers_type{
   PELA_COR, //Cor do Objeto
   PELO_NOME //Nome do Objeto
};

enum tipo{
   NA_MESMA_VELA, //Na mesma vela
   NA_PROXIMA_VELA //Na próxima vela
};

enum tool{
   B2IQ,
   MT2,
   MX2
};

enum sinal {
   MESMA_VELA = 0,
   PROXIMA_VELA = 1 
};

//---- Parâmetros de entrada - B2IQ
enum modo {
   MELHOR_PAYOUT = 'M',
   BINARIAS = 'B',
   DIGITAIS = 'D'
};

enum fibo_signal {
   inpLevel00, //DESATIVAR
   inpLevel22, //23.6
   inpLevel33, //38.2
   inpLevel44, //50.0
   inpLevel55  //61.8
};

enum OPCAO_ENTRADA
{
   SOMENTE_30, //SOMENTE 30
   SOMENTE_60, //SOMENTE 60
   OS_DOIS //OS DOIS
};

//---- Parâmetros de entrada - MT2
enum broker
{
   All = 0,
   IQOption = 1,
   Binary = 2,
   Spectre = 3,
   Alpari = 4
};

enum martingale
{
   NoMartingale = 0,
   OnNextExpiry = 1,
   OnNextSignal = 2,
   Anti_OnNextExpiry = 3,
   Anti_OnNextSignal = 4,
   OnNextSignal_Global = 5,
   Anti_OnNextSignal_Global = 6
};

//---- Parâmetros de entrada - MX2
enum tipoexpericao
{
   tempo_fixo = 0, //Tempo fixo
   retracao = 1 //Retração na mesma vela
};

struct estatisticas
{
   int win_global;
   int loss_global;
   int win_restrito;
   int loss_restrito;
   string assertividade_global_valor;
   string assertividade_restrita_valor;
   
   estatisticas()
   {
      Reset();
   }
   
   void Reset(){
      win_global=0;
      loss_global=0;
      win_restrito=0;
      loss_restrito=0;
      assertividade_global_valor="0%";
      assertividade_restrita_valor="0%";
   }
};

struct backtest
{  
   double win;   
   double loss;  
   double draw; 
   int consecutive_wins;       
   int consecutive_losses; 
   int count_win;
   int count_loss;
   int count_entries;
   backtest()
   {
      Reset();
   }
   void Reset()
   {
      win=0;   
      loss=0;  
      draw=0; 
      consecutive_wins=0;       
      consecutive_losses=0; 
      count_win=0;
      count_loss=0;
      count_entries=0;
   }
};


enum tipo_sinal
{
   pre_alerta, //Pré-alerta
   seta //Seta
};

enum usar_como
{
   filtro, //Filtro
   seta_sinal //Seta
};

extern string         grupo = "";                              //Grupo
extern string         _="  |||||||||||||| LIFE CHANGING ||||||||||||||  "; //_
extern int            total_bars = 288;                        //Total Bars - Backtest
bool                  intercalacao=true;                       //Intercalação de Sinais
extern status         inverter_sinais=false;                   //Inverter sinais?
extern int            enviar_sinais_x_tempos=0;                //Enviar Sinal X Minutos Após Outro (0-Desativado)
extern status         donforex_ltaltb=false;                   //Confluir Donforex & Lta/Ltb
extern status         mode_alert=false;                        //Alerta

extern string         sep1="  --== Lta/Ltb ==--  ";            //_
extern status         lta_ltb_filter=true;                     //LTA/LTB | Reversão
extern status         rompimento_lta_ltb=false;                //Rompimento?
extern string         ltaltb_filename="ltaltb";                //LTA/LTB - Filename
extern int            ignorar_toques=1;                        //Ignorar Toques Qtd. (lta_ltb)

extern string         sep2="  --== Don Forex ==--  ";          //_
extern status         donforex=false;                          //Donforex | Reversão
extern status         rompimento_donforex=false;               //Rompimento?
extern int            min_rectangle_size=20;                   //Tamanho Min. Sup/Res Donforex
extern string         donforex_filename="donforex";            //Donforex - Filename

extern string         ___ = "  --== Parabolic SAR ==--  ";     //_
extern status         ativar_sar=false;                        //Parabolic SAR
input  double         InpSARStep=0.02;                         //Step
input  double         InpSARMaximum=0.2;                       //Maximum

extern string         _____ = "  --== Bollinger Bands ==--  ";   //_
extern status         ativar_bb=false;                         //Bollinger Bands
extern int            BBPeriod=15;                             //Bands Period
extern double         BBDev=1.5;                               //Bands Deviation
extern ENUM_APPLIED_PRICE BBPrice=PRICE_CLOSE;                 //Bands Price

extern string         ______ = "  --== Fibonacci Levels ==--  "; //_
extern status         ativar_fibo=false;                       //Fibonacci Levels
extern fibo_signal    regiao_1_fibo=inpLevel33;                //Região 1 Sinal
extern fibo_signal    regiao_2_fibo=inpLevel44;                //Região 2 Sinal
extern color          inpLineColor=clrRed;                     //Line Color
extern color          inpLevelsColor=clrSteelBlue;             //Levels Color

extern string         sep3="  |||||||||||||| FILTROS ||||||||||||||  "; //_

extern string         sep_a0="  --== Confirmação de Sinal ==--  "; //_
extern status         ativar_confirmacao=false;                //Ativar Confirmação
extern int            confirmacao_segundos=20;                 //Segundos

extern string         sep_a="  --== Stop Win ==--  ";          //_
extern status         ativar_stop_win=false;                   //Stop Win
extern int            qtd_stop_win = 2;                        //Qtd. Stop Win

extern string         sep_b="  --== Stop Loss ==--  ";         //_
extern status         ativar_stop_loss=false;                  //Stop Loss
extern int            qtd_stop_loss = 2;                       //Qtd. Stop Loss

extern string         sep_c="  --== Block Loss ==--  ";        //_
extern status         block_loss_restrito=false;               //Block Loss Restrito
extern status         block_loss_global=false;                 //Block Loss Global
extern string         orders_extreme="order_status.txt";       //Filename Global

extern string         sep_d="  --== Filtro de Cores ==--  ";   //_
extern status         ativar_filtro_cores=false;               //Filtro de Cores
extern int            qtd_candles_map_cores=500;               //Qtd. Candles 
extern status         inverter_filtro_cores=false;             //Inverter Filtro de Cores

extern string         sep_e="  --== Filtro de Tendência ==--  "; //_
extern status         trend_filter=false;                      //Filtro de Tendência
extern int            ma_period=150;                           //Período da MM
extern ENUM_MA_METHOD ma_method=MODE_EMA;                      //Suavização da MM

extern string         selfil2 = "  --== Filtro de Notícias ==--  "; //_
extern status         filtro_noticias = false;                 //Ativar Filtro de Notícias
extern int            noticia_minutos_antes = 30;              //Desativar Sinais X Minutos Antes da Notícia
extern int            noticia_minutos_depois = 30;             //Desativar Sinais X Minutos Depois da Notícia
extern int            noticia_impacto = 3;                     //Se a Notícia Tiver Impacto Maior ou Igual que

extern string         sep4="  |||||||||||||| COMBINERS ||||||||||||||  "; //_

extern string         sep="  --== Combiner | Oscilador ==--  "; //_
extern status         ativar_combiner_oscilador = false;        //Ativar Combiner
extern tipo_sinal     aplicar_combiner_oscilador = pre_alerta;  //Aplicar no(a)
extern usar_como      usar_como_oscilador = seta_sinal;         //Usar como
extern string         combiner_filename_oscilador = "CCI";      //Filename
extern int            combiner_buff_oscilador = 0;              //Buffer
extern int            combiner_nivel_sobrecompra_oscilador = 160;//Nível de Sobrecompra
extern int            combiner_nivel_sobrevenda_oscilador = -160; //Nível de Sobrevenda
extern int            qtd_candles_oscilador = 30;               //Qtd. Candles Abaixo/Acima 
extern int            indice_buffers_3 = 0;                     //Buffer Índice

extern string         __________="  --== Combiner | Seta 1 ==--  "; //_
extern status         ativar_combiner = false;                 //Ativar Combiner
extern tipo_sinal     aplicar_combiner = pre_alerta;           //Aplicar no(a)
extern string         combiner_filename = "";                  //Filename
extern int            combiner_buff_up = 0;                    //Buffer Up
extern int            combiner_buff_down = 1;                  //Buffer Down
extern int            indice_buffers = 0;                      //Buffers Índice

extern string         ___________="  --== Combiner | Seta 2 ==--  "; //_
extern status         ativar_combiner_2 = false;                 //Ativar Combiner
extern tipo_sinal     aplicar_combiner_2 = pre_alerta;           //Aplicar no(a)
extern string         combiner_filename_2 = "";                  //Filename
extern int            combiner_buff_up_2 = 0;                    //Buffer Up
extern int            combiner_buff_down_2 = 1;                  //Buffer Down
extern int            indice_buffers_2 = 0;                      //Buffers Índice

extern string         sep5="  |||||||||||||| CONECTORES ||||||||||||||  "; //_

extern status         autotrading=false;                       //Trading Automático
extern tool           select_tool = B2IQ;                      //Trading Automático - Ferramenta
extern tipo_sinal     sinal_na = seta;                         //Tipo Sinal

extern string         ______________= "  --== B2IQ Conf ==--  ";     //_
extern sinal          SinalEntrada = MESMA_VELA;               //Entrar na
extern modo           Modalidade = MELHOR_PAYOUT;              //Modalidade
extern string         NomeEstrategia = "";                     //Nome Estrategia
extern string         vps = "";                                //IP:PORTA da VPS (caso utilize)

extern string         _______________= "  --== MT2 Conf ==--  ";     //_
extern int            ExpiryMinutes = 1;                       //Expiração em Minuto
extern double         TradeAmount     = 25;                    //Investimento
extern martingale     MartingaleType  = NoMartingale;          //Martingale
extern int            MartingaleSteps = 1;                     //Passos do Martingale
extern double         MartingaleCoef  = 2.3;                   //Coeficiente do Martingale
extern broker         Broker          = All;                   //Corretora

extern string         ________________="  --== Conf. MX2 ==--  ";          //_
extern int            expiraca_mx2    = 0;                     //Tempo de Expiração em Minuto (0-Auto)
extern sinal          sinal_tipo_mx2  = MESMA_VELA;            //Entrar na
extern tipoexpericao  tipo_expiracao_mx2 = tempo_fixo;         //Tipo Expiração

extern string         sep6="  |||||||||||||| TELEGRAM ||||||||||||||  "; //_

extern string         __________________= "  --== Telegram Conf ==--  ";//_
extern status         ativar_win_gale = true;                                //Ativar Win Gale
extern status         ativar_win_gale2 = true;                               //Ativar Win Gale 2
extern int            tempo_expiracao = 0;                                   //Expiracação em Minutos (0-TF)
extern tipo           Entrada = NA_PROXIMA_VELA;                      
extern status         mostrar_taxa=true;                                     //Mostrar Taxa? (MESMA VELA)                             

extern string         ___________________ = "  --==  Estatísticas  ==--  ";  //_
extern status         assertividade_global = true;                          //Exibir Assertividade Global
extern status         assertividade_restrita = true;                        //Exibir Assertividade Restrita
extern status         block_registros_duplicados = true;                    //Não Registrar Sinais Duplicados
extern string         arquivo_estatisticas = "lifechanging_results.txt";     //Filename 

extern string         _____________________= "  --==  API Conf  ==--  ";            //_
extern string         nome_sala = "TRADER EXTREME";                          //Nome da Sala
extern string         apikey = "";                                           //API Key
extern string         chatid = "";                                           //Chat ID
extern string         ______________________= "  --== Win/Loss ==--  "; //_
extern string         message_win = " ";                       //Mensagem de Win
extern string         message_win_gale = " ";                  //Mensagem de Win Gale
extern string         message_win_gale2 = "loss";              //Mensagem de Win Gale2
extern string         message_loss = "loss";                   //Mensagem de Loss
extern string         message_empate = " ";                    //Mensagem de Empate
extern string         file_win = EXAMPLE_PHOTO;                //Imagem de Win
extern string         file_win_gale = EXAMPLE_PHOTO;           //Imagem de Win Gale
extern string         file_win_gale2 = EXAMPLE_PHOTO;          //Imagem de Win Gale 2
extern string         file_loss = EXAMPLE_PHOTO;               //Imagem de Loss

extern string         _____f = "  --==  Msgs / Sinais por sessão ==--  "; //_
extern status         enviar_msg_sessao = false;                             //Enviar Msgs
extern status         ativar_msg_geral = true;                               //Ativar Resultado Geral
extern string         msg_personalizada_ao_vivo_geral = "EXTREME RESULTADO GERAL";   //Msg Personalizada | Geral
extern string         msg_personalizada_ao_vivo = "EXTREME PARCIAL";         //Msg Personalizada | Parcial
extern status         sessao_manha = false;                              //--== Período Manhã ==--
extern string         HORARIO_INICIO_MANHA = "00:10";                        //Horário Inicio
extern string         HORARIO_FIM_MANHA = "11:50";                           //Horário Fim
extern status         sessao_tarde = false;                              //--== Período Tarde ==--
extern string         HORARIO_INICIO_TARDE = "12:10";                        //Horário Inicio
extern string         HORARIO_FIM_TARDE = "17:50";                           //Horário Fim
extern status         sessao_noite = false;                              //--== Período Noite ==--
extern string         HORARIO_INICIO_NOITE = "21:01";                        //Horário Inicio
extern string         HORARIO_FIM_NOITE = "23:50";                           //Horário Fim

string         arquivo_estatisticas2 = "lifechanging_results_bkp.txt";

bool first_message_telegram_manha=false,
     end_message_telegram_manha=false,
     first_message_telegram_tarde=false,
     end_message_telegram_tarde=false,
     first_message_telegram_noite=false,
     end_message_telegram_noite=false;
     
int SPC;
double rate=0;

//--buffers
double PossibleUpBf[], PossibleDwBf[], Up[], Dw[], ExtLineBuffer[];
double ganhou[], perdeu[], empatou[],
       ganhou1[], perdeu1[], empatou1[],
       ganhou2[], perdeu2[], empatou2[];
double ExtSARBuffer[];
       
string program=MQLInfoString(MQL_PROGRAM_NAME);

double buffer_up_combiner=0, buffer_down_combiner=0,
       buffer_up_combiner_2=0, buffer_down_combiner_2=0,
       buffer_combiner_oscilador=0, 
       oscilador_bef1=0, oscilador_bef2=0, oscilador_bef3=0, oscilador_bef4=0, oscilador_bef5=0;


datetime horario_expiracao_gale, horario_expiracao_gale2, horario_agora;
bool LIBERAR_ACESSO=true;

//DEFINIR EXPIRAÇÃO PARA EA
string DataExpiracao = "2030.11.30 00:00:00";          
int NumeroConta=15062083;
//--------------------------------
string expiracao="", up="⬆️", down="⬇️",msg2="";

string signalID;
backtest info, infog1, infog2;
datetime befTime_panel, befTime, befTime_signal, befTime_telegram, befTime_check, befTime_repaint;
string vpss = "";
static string ultimo_resultado="win";
static string ultima_operacao="";
int mID = IntegerToString(ChartID());
string timeframe = "M"+IntegerToString(_Period);   
bool sinaltelegram=true; //Enviar Sinais Telegram

#import "mt2trading_library.ex4"   // Please use only library version 12.4 or higher !!!
bool mt2trading(string symbol, string direction, double amount, int expiryMinutes);
bool mt2trading(string symbol, string direction, double amount, int expiryMinutes, string signalname);
bool mt2trading(string symbol, string direction, double amount, int expiryMinutes, martingale martingaleType, int martingaleSteps, double martingaleCoef, broker myBroker, string signalName, string signalid);
int  traderesult(string signalid);
#import

#import "Telegram4Mql.dll"
   string TelegramSendText(string ApiKey, string ChatId, string ChatText);
   string TelegramSendText(string apiKey, string chatId, string chatText);
   string TelegramSendPhotoAsync(string apiKey, string chatId, string filePath, string caption = "");
#import

//---Fibo parameters
string   inpName     = "Fibo_01";      // Fibo Name
int      inpDepth          = 12;             // ZigZag Depth
int      inpDeviation      = 5;              // ZigZag Deviation
int      inpBackStep       = 3;              // ZigZag BackStep
int      inpLeg            = 1;              // ZigZag Leg
bool     inpRay            = false;          // Ray
double   inpLevel1         = 0.0;            // Level 1
double   inpLevel2         = 23.6;           // Level 2
double   inpLevel3         = 38.2;           // Level 3
double   inpLevel4         = 50.0;           // Level 4
double   inpLevel5         = 61.8;           // Level 5
double   inpLevel6         = 100.0;          // Level 6
double   inpLevel7         = 161.8;          // Level 7
double   inpLevel8         = 261.8;          // Level 8
double   inpLevel9         = 423.6;          // Level 9
double   levels[9];        // Levels Array
double   levels_price[9];
int      regiao_1_fibo_ind,regiao_2_fibo_ind,shift_ref0_fibo,shift_ref5_fibo;
//----------------

datetime horario_inicio_telegram, horario_fim_telegram,
         horario_inicio_manha, horario_fim_manha,
         horario_inicio_tarde, horario_fim_tarde,
         horario_inicio_noite, horario_fim_noite;
         
static bool eh_repinte=true;
static int total_bars_shift=total_bars;      
static int tipo_entrada[];
static datetime horario_expiracao[],horario_entrada[];
static string horario_entrada_local[];
static double entrada[];
static int ratestotal=0;
static bool first=true;   
   
//--- global variables PARABOLIC SAR
double       ExtSarStep;
double       ExtSarMaximum;
int          ExtLastReverse;
bool         ExtDirectionLong;
double       ExtLastStep,ExtLastEP,ExtLastSAR;
double       ExtLastHigh,ExtLastLow;
int          count_dd=0;
string       fibo_status;
int stop_win_atual, stop_loss_atual;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
      IndicatorSetString(INDICATOR_SHORTNAME,"Life Changing");
      IndicatorDigits(Digits);
      
      if(/*NumeroConta!=AccountNumber() ||*/ TimeGMT()-10800 > StrToTime(DataExpiracao)){
         LIBERAR_ACESSO=false;
         Alert("Licença inválida ou expirou.");
      }
      
      EventSetMillisecondTimer(1);
      
      SPC=Period()==PERIOD_M1?5:20;
      if(expiraca_mx2==0) expiraca_mx2=_Period;
      if(tempo_expiracao==0) tempo_expiracao=_Period;
      
      if(tempo_expiracao==1)
         expiracao="1 minuto";
      else if(tempo_expiracao>1 && tempo_expiracao<60)
         expiracao=IntegerToString(tempo_expiracao)+" minutos";
      else if(tempo_expiracao==60)
         expiracao="1 hora";
      else if(tempo_expiracao>60)
         expiracao=(IntegerToString(tempo_expiracao/60))+" horas";
      
      if(ativar_win_gale==true) msg2="COM 1G SE NECESSÁRIO"; 
      else if(ativar_win_gale2) msg2="COM 2G SE NECESSÁRIO"; 
      else msg2="SEM MARTINGALE";
      
      // Set Levels Array - Fibo
      levels[0] = inpLevel1;  levels[1] = inpLevel2;  levels[2] = inpLevel3;  levels[3] = inpLevel4;  levels[4] = inpLevel5;
      levels[5] = inpLevel6;  levels[6] = inpLevel7;  levels[7] = inpLevel8;  levels[8] = inpLevel9;
      
      switch(regiao_1_fibo){
         case inpLevel22:
            regiao_1_fibo_ind=1;
            break;
         case inpLevel33:
            regiao_1_fibo_ind=2;
            break;
         case inpLevel44:
            regiao_1_fibo_ind=3;
            break;
         case inpLevel55:
            regiao_1_fibo_ind=4;
            break;   
         case inpLevel00:
            regiao_1_fibo_ind=0;
            break;
      }
      
      switch(regiao_2_fibo){
         case inpLevel22:
            regiao_2_fibo_ind=1;
            break;
         case inpLevel33:
            regiao_2_fibo_ind=2;
            break;
         case inpLevel44:
            regiao_2_fibo_ind=3;
            break;
         case inpLevel55:
            regiao_2_fibo_ind=4;
            break;  
         case inpLevel00:
            regiao_2_fibo_ind=0;
            break;
      }
   
//--- indicator buffers mapping
      IndicatorBuffers(15);
      
      //--- Arrow
      SetIndexStyle(0,DRAW_ARROW,NULL,0);
      SetIndexArrow(0,233); 
      SetIndexBuffer(0,Up);
      SetIndexLabel(0,"UP");
      
      SetIndexStyle(1,DRAW_ARROW,NULL,0);
      SetIndexArrow(1,234); 
      SetIndexBuffer(1,Dw);
      SetIndexLabel(1,"DOWN");
      
      SetIndexStyle(2,DRAW_ARROW,NULL,1);
      SetIndexArrow(2,159);
      SetIndexBuffer(2,PossibleUpBf);
      SetIndexLabel(2,"Possivel UP");
      
      SetIndexStyle(3,DRAW_ARROW,NULL,1);
      SetIndexArrow(3,159); 
      SetIndexBuffer(3,PossibleDwBf);
      SetIndexLabel(3,"Possivel DOWN");
   
      SetIndexStyle(4,DRAW_LINE,EMPTY,3);
      SetIndexShift(4,0);
      SetIndexDrawBegin(4,ma_period-1);
      
      //--- indicator buffers mapping
      SetIndexBuffer(4,ExtLineBuffer);
      SetIndexLabel(4,"MA["+IntegerToString(ma_period)+"]");
      
      //--Statistics buffers
      SetIndexStyle(5,DRAW_ARROW,NULL,2);
      SetIndexArrow(5,254); 
      SetIndexBuffer(5,ganhou);
      SetIndexLabel(5,"WIN");
      
      SetIndexStyle(6,DRAW_ARROW,NULL,2);
      SetIndexArrow(6,253);
      SetIndexBuffer(6,perdeu);
      SetIndexLabel(6,"LOSS");
      
      SetIndexBuffer(7,empatou);
      SetIndexLabel(7,"DRAW");
      
      if(InpSARStep<0.0){
         ExtSarStep=0.02;
         Print("Input parametr InpSARStep has incorrect value. Indicator will use value ",
            ExtSarStep," for calculations.");
      }else ExtSarStep=InpSARStep;
      
      if(InpSARMaximum<0.0){
         ExtSarMaximum=0.2;
         Print("Input parametr InpSARMaximum has incorrect value. Indicator will use value ",
            ExtSarMaximum," for calculations.");
      }else ExtSarMaximum=InpSARMaximum;
      
      //--buffer parabolic sar
      SetIndexStyle(8,DRAW_ARROW);
      SetIndexArrow(8,159);
      SetIndexBuffer(8,ExtSARBuffer);
      SetIndexLabel(8,"Parabolic SAR");
      
      //--- set global variables parabolic sar
      ExtLastReverse=0;
      ExtDirectionLong=false;
      ExtLastStep=ExtLastEP=ExtLastSAR=0.0;
      ExtLastHigh=ExtLastLow=0.0;
      
      
      SetIndexBuffer(9,ganhou1);
      SetIndexBuffer(10,perdeu1);
      SetIndexBuffer(11,empatou1);
      
      SetIndexBuffer(12,ganhou2);
      SetIndexBuffer(13,perdeu2);
      SetIndexBuffer(14,empatou2);
      
      //---
      SetIndexEmptyValue(0,EMPTY_VALUE);
      SetIndexEmptyValue(1,EMPTY_VALUE);
      SetIndexEmptyValue(2,EMPTY_VALUE);
      SetIndexEmptyValue(3,EMPTY_VALUE);   
      SetIndexEmptyValue(4,EMPTY_VALUE);
      SetIndexEmptyValue(5,EMPTY_VALUE);
      SetIndexEmptyValue(6,EMPTY_VALUE);
      SetIndexEmptyValue(8,EMPTY_VALUE);
      SetIndexEmptyValue(9,EMPTY_VALUE);
      SetIndexEmptyValue(10,EMPTY_VALUE);
      SetIndexEmptyValue(11,EMPTY_VALUE);
      SetIndexEmptyValue(12,EMPTY_VALUE);
      SetIndexEmptyValue(13,EMPTY_VALUE);
      SetIndexEmptyValue(14,EMPTY_VALUE);
      
      //--Background - painel
      ChartSetInteger(0,CHART_FOREGROUND,0,false);
      ObjectCreate("MAIN",OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSet("MAIN",OBJPROP_CORNER,0);
      ObjectSet("MAIN",OBJPROP_XDISTANCE,10);
      ObjectSet("MAIN",OBJPROP_YDISTANCE,20);
      ObjectSet("MAIN",OBJPROP_XSIZE,210);
      ObjectSet("MAIN",OBJPROP_YSIZE,155);
      ObjectSet("MAIN",OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSet("MAIN",OBJPROP_COLOR,clrWhite);
      ObjectSet("MAIN",OBJPROP_BGCOLOR,clrBlack); //C'24,31,44'
      
      vpss = carregar_vpss();
      
      if(ativar_combiner)
         count_dd++;
      if(ativar_combiner_2)
         count_dd++;
      if(ativar_combiner_oscilador)
         count_dd++;
//---
   return(INIT_SUCCEEDED);
  }
  


void deinit(){
   ResetLastError();
 
   ObjectDelete("consecutive_losses");
   ObjectDelete("consecutive_wins");
   ObjectDelete("count_entries");
   ObjectDelete("draw");        
   ObjectDelete("quant");  
   ObjectDelete("wins");  
   ObjectDelete("wins_rate");
   ObjectDelete("gales");
   
   ObjectDelete("start_count");
   ObjectDelete("MAIN");      
   ObjectDelete("estrategia_info");
   
   ArrayInitialize(PossibleUpBf,EMPTY_VALUE);
   ArrayInitialize(PossibleDwBf,EMPTY_VALUE);
   ArrayInitialize(Up,EMPTY_VALUE);
   ArrayInitialize(Dw,EMPTY_VALUE);
   
   ArrayInitialize(ganhou,EMPTY_VALUE);
   ArrayInitialize(perdeu,EMPTY_VALUE);
   ArrayInitialize(empatou,EMPTY_VALUE);
   
   ArrayInitialize(ganhou1,EMPTY_VALUE);
   ArrayInitialize(perdeu1,EMPTY_VALUE);
   ArrayInitialize(empatou1,EMPTY_VALUE);
   
   ArrayInitialize(ganhou2,EMPTY_VALUE);
   ArrayInitialize(perdeu2,EMPTY_VALUE);
   ArrayInitialize(empatou2,EMPTY_VALUE);
   
   info.Reset();
   infog1.Reset();
   infog2.Reset();      
         
   ObjectsDeleteAll(0,program,0);
   
   if(LIBERAR_ACESSO==false) ChartIndicatorDelete(0,0,"Life Changing");
}

datetime FiltroNoticias(){
   datetime desativar_sinais_horario;
   
   int EventMinute = (int)iCustom(NULL,0,"ffcal2",0,0);
   int EventImpact = (int)iCustom(NULL,0,"ffcal2",1,0);
   
   if(EventMinute <= noticia_minutos_antes && EventImpact >= noticia_impacto)
      desativar_sinais_horario = iTime(NULL,PERIOD_M1,0)+(noticia_minutos_antes+noticia_minutos_depois)*60;
 
   return desativar_sinais_horario;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   if(LIBERAR_ACESSO==false) deinit();
   
   
   static datetime befTime_bars;
   
   if(first){
      befTime_bars = iTime(NULL,0,total_bars);
      first=false;
   }
   
   if(!lta_ltb_filter && !ativar_bb && !ativar_fibo){
      total_bars_shift = iBarShift(NULL,0,befTime_bars,false);
   }
   
   //--- first calculation or number of bars was changed
   if(prev_calculated==0){
      ArrayInitialize(ExtLineBuffer,0);
         
      MqlDateTime horario;
      TimeLocal(horario);
      horario_inicio_manha = StringToTime(horario.year+"."+horario.mon+"."+horario.day+" "+HORARIO_INICIO_MANHA);      
      horario_fim_manha = StringToTime(horario.year+"."+horario.mon+"."+horario.day+" "+HORARIO_FIM_MANHA);
      
      horario_inicio_tarde = StringToTime(horario.year+"."+horario.mon+"."+horario.day+" "+HORARIO_INICIO_TARDE);      
      horario_fim_tarde = StringToTime(horario.year+"."+horario.mon+"."+horario.day+" "+HORARIO_FIM_TARDE);
      
      horario_inicio_noite = StringToTime(horario.year+"."+horario.mon+"."+horario.day+" "+HORARIO_INICIO_NOITE);      
      horario_fim_noite = StringToTime(horario.year+"."+horario.mon+"."+horario.day+" "+HORARIO_FIM_NOITE);
   
   }
   
   if(trend_filter){
      //--- counting from 0 to rates_total
      ArraySetAsSeries(ExtLineBuffer,false);
      ArraySetAsSeries(close,false);
        
      //--- calculation
      switch(ma_method)
     {
      case MODE_EMA:  CalculateEMA(rates_total,prev_calculated,close);        break;
      case MODE_LWMA: CalculateLWMA(rates_total,prev_calculated,close);       break;
      case MODE_SMMA: CalculateSmoothedMA(rates_total,prev_calculated,close); break;
      case MODE_SMA:  CalculateSimpleMA(rates_total,prev_calculated,close);   break;
     }
   }
   
   //--- check for bars count
  /* if(rates_total<ma_period-1 || ma_period<2)
      return(0);
  */    
  
   //---Fibonacci
   datetime times[2];
   double price[2];
   // Get Times and Price ZigZag Values.
   if(!GetZZ(times,price)) ativar_fibo=false;
   
   if(((PossibleDwBf[0] == EMPTY_VALUE && PossibleDwBf[1] == EMPTY_VALUE) && (PossibleUpBf[0] == EMPTY_VALUE && PossibleUpBf[1] == EMPTY_VALUE)) 
   || (Up[1]!=EMPTY_VALUE && Dw[1]!=EMPTY_VALUE)){ 
      if(ObjectFind(0,inpName)<0 && ativar_fibo==true) FiboDraw(inpName,times,price,inpLineColor,inpLevelsColor);    // Create new Fibonacci
      else if(ativar_fibo==true) FiboMove(inpName,times,price,inpLevelsColor);                                       // Move current Fibonacci
      else ObjectDelete(inpName);
      ChartRedraw();                                                                                                 // Refresh chart
   }
   //----
   
   int limit = prev_calculated==0 ? total_bars_shift : 0;
   int bar = 0;
   
   //--parabolic sar local variables
   bool   dir_long;
   double last_high,last_low,ep,sar,step;
   int sar_index;
   sar_index=prev_calculated-1;
   double high_sar[], low_sar[];
   
   if(ativar_sar){
      CopyHigh(NULL,0,0,iBars(NULL,0),high_sar);
      CopyLow(NULL,0,0,iBars(NULL,0),low_sar);
      
      ArraySetAsSeries(high_sar,false);
      ArraySetAsSeries(low_sar,false);
      ArraySetAsSeries(ExtSARBuffer,false);
      
      if(sar_index<1)
     {
      ExtLastReverse=0;
      dir_long=true;
      step=ExtSarStep;
      last_high=-10000000.0;
      last_low=10000000.0;
      sar=0;
      sar_index=1;
      while(sar_index<rates_total-1)
        {
         ExtLastReverse=sar_index;
         if(last_low>low_sar[sar_index])
            last_low=low_sar[sar_index];
         if(last_high<high_sar[sar_index])
            last_high=high_sar[sar_index];
         if(high_sar[sar_index]>high_sar[sar_index-1] && low_sar[sar_index]>low_sar[sar_index-1])
            break;
         if(high_sar[sar_index]<high_sar[sar_index-1] && low_sar[sar_index]<low_sar[sar_index-1])
           {
            dir_long=false;
            break;
           }
         sar_index++;
        }
      //--- initialize with zero
      ArrayInitialize(ExtSARBuffer,0.0);
      //--- go check
      if(dir_long)
        {
         ExtSARBuffer[sar_index]=low_sar[sar_index-1];
         ep=high_sar[sar_index];
        }
      else
        {
        
         ExtSARBuffer[sar_index]=high_sar[sar_index-1];
         ep=low_sar[sar_index];
        }
      sar_index++;
     }
   else
     {
      //--- calculations to be continued. restore last values
      sar_index=ExtLastReverse;
      step=ExtLastStep;
      dir_long=ExtDirectionLong;
      last_high=ExtLastHigh;
      last_low=ExtLastLow;
      ep=ExtLastEP;
      sar=ExtLastSAR;
     }
//---main cycle
   while(sar_index<rates_total)
     {
      //--- check for reverse
      if(dir_long && low_sar[sar_index]<ExtSARBuffer[sar_index-1])
        {
         SaveLastReverse(sar_index,true,step,low_sar[sar_index],last_high,ep,sar);
         step=ExtSarStep;
         dir_long=false;
         ep=low_sar[sar_index];
         last_low=low_sar[sar_index];
         ExtSARBuffer[sar_index++]=last_high;
         continue;
        }
      if(!dir_long && high_sar[sar_index]>ExtSARBuffer[sar_index-1])
        {
         SaveLastReverse(sar_index,false,step,last_low,high_sar[sar_index],ep,sar);
         step=ExtSarStep;
         dir_long=true;
         ep=high_sar[sar_index];
         last_high=high_sar[sar_index];
         ExtSARBuffer[sar_index++]=last_low;
         continue;
        }
      //---
      sar=ExtSARBuffer[sar_index-1]+step*(ep-ExtSARBuffer[sar_index-1]);
      //--- LONG?
      if(dir_long)
        {
         if(ep<high_sar[sar_index])
           {
            if((step+ExtSarStep)<=ExtSarMaximum)
               step+=ExtSarStep;
           }
         if(high_sar[sar_index]<high_sar[sar_index-1] && sar_index==2)
            sar=ExtSARBuffer[sar_index-1];
         if(sar>low_sar[sar_index-1])
            sar=low_sar[sar_index-1];
         if(sar>low_sar[sar_index-2])
            sar=low_sar[sar_index-2];
         if(sar>low_sar[sar_index])
           {
            SaveLastReverse(sar_index,true,step,low_sar[sar_index],last_high,ep,sar);
            step=ExtSarStep; dir_long=false; ep=low_sar[sar_index];
            last_low=low_sar[sar_index];
            ExtSARBuffer[sar_index++]=last_high;
            continue;
           }
         if(ep<high_sar[sar_index])
            ep=last_high=high_sar[sar_index];
        }
      else // SHORT
        {
         if(ep>low_sar[sar_index])
           {
            if((step+ExtSarStep)<=ExtSarMaximum)
               step+=ExtSarStep;
           }
         if(low_sar[sar_index]<low_sar[sar_index-1] && sar_index==2)
            sar=ExtSARBuffer[sar_index-1];
         if(sar<high_sar[sar_index-1])
            sar=high_sar[sar_index-1];
         if(sar<high_sar[sar_index-2])
            sar=high_sar[sar_index-2];
         if(sar<high_sar[sar_index])
           {
            SaveLastReverse(sar_index,false,step,last_low,high_sar[sar_index],ep,sar);
            step=ExtSarStep;
            dir_long=true;
            ep=high_sar[sar_index];
            last_high=high_sar[sar_index];
            ExtSARBuffer[sar_index++]=last_low;
            continue;
           }
         if(ep>low_sar[sar_index])
            ep=last_low=low_sar[sar_index];
        }
        
      ExtSARBuffer[sar_index++]=sar;
     }
   }
   ArraySetAsSeries(ExtSARBuffer,true);
   
   if(ratestotal!=rates_total){
      if(ativar_fibo==false){
         ArrayInitialize(PossibleUpBf,EMPTY_VALUE);
         ArrayInitialize(PossibleDwBf,EMPTY_VALUE);
         ArrayInitialize(Up,EMPTY_VALUE);
         ArrayInitialize(Dw,EMPTY_VALUE);
         
         ArrayInitialize(ganhou,EMPTY_VALUE);
         ArrayInitialize(perdeu,EMPTY_VALUE);
         ArrayInitialize(empatou,EMPTY_VALUE);
         
         ArrayInitialize(ganhou1,EMPTY_VALUE);
         ArrayInitialize(perdeu1,EMPTY_VALUE);
         ArrayInitialize(empatou1,EMPTY_VALUE);
         
         ArrayInitialize(ganhou2,EMPTY_VALUE);
         ArrayInitialize(perdeu2,EMPTY_VALUE);
         ArrayInitialize(empatou2,EMPTY_VALUE);
      } else {
         info.Reset();
         infog1.Reset();
         infog2.Reset();
      }
      
      limit=total_bars_shift;
      ratestotal=rates_total;
   }
   
   //block loss restrito
   if(block_loss_restrito && ultimo_resultado=="loss"){
      bar=1;
   }
   
   //block loss global
   //verifica se na ultima operação global houve um loss, se sim, então não mandará mais sinais até ter um win
   string ultimo_result = ultimo_resultado_global();
   if(block_loss_global && (ultimo_result=="loss"||ultimo_result=="nda")){
      if((ultimo_result=="nda" && get_chart_id()!=ChartID()) 
      || ultimo_result=="loss" 
      || (ultimo_result=="nda" && get_chart_id()==ChartID() && iTime(NULL,0,0)>ultimo_resultado_global_time() && PossibleDwBf[0]==EMPTY_VALUE && PossibleUpBf[0]==EMPTY_VALUE)
      ){
         bar=1;
      }
   }
   
   if(befTime_telegram==iTime(NULL,0,1)){
      if(ultima_operacao=="down") PossibleDwBf[1]=high[1]+SPC*Point;
      else if(ultima_operacao=="up") PossibleUpBf[1]=low[1]-SPC*Point;
   }
   
   //---
   double resistencia_ultimo_sinal=0, suporte_ultimo_sinal=0;
   int contador_sinal_supres=0;
        
   for(int i=limit; i>=bar; i--){

      double moving_average, resistance, support, resistance_bef, support_bef, 
             ltb, lta, ltb_bef, lta_bef, 
             upperBand, lowerBand, upperBand_bef, lowerBand_bef,
             value_close, value_open, value_close_bef, value_open_bef,
             parabolic_sar;
      
      if(trend_filter==true) moving_average = iMA(NULL,0,ma_period,0,ma_method,PRICE_CLOSE,i);
      if(ativar_sar) parabolic_sar = ExtSARBuffer[i];
      if(lta_ltb_filter==true || rompimento_lta_ltb){
         ltb = iCustom(Symbol(),0,ltaltb_filename,0,i);
         lta = iCustom(Symbol(),0,ltaltb_filename,1,i);
         ltb_bef = iCustom(Symbol(),0,ltaltb_filename,0,i+1);
         lta_bef = iCustom(Symbol(),0,ltaltb_filename,1,i+1);
      }
      if(ativar_bb==true){
          upperBand = iBands(NULL,0,BBPeriod,BBDev,0,BBPrice,MODE_UPPER,i);
          upperBand_bef = iBands(NULL,0,BBPeriod,BBDev,0,BBPrice,MODE_UPPER,i+1);
          lowerBand = iBands(NULL,0,BBPeriod,BBDev,0,BBPrice,MODE_LOWER,i);
          lowerBand_bef = iBands(NULL,0,BBPeriod,BBDev,0,BBPrice,MODE_LOWER,i+1);
      }
      if(ativar_combiner==true){
         buffer_up_combiner=iCustom(NULL,0,combiner_filename,combiner_buff_up,i+indice_buffers);
         buffer_down_combiner=iCustom(NULL,0,combiner_filename,combiner_buff_down,i+indice_buffers);
      }
      if(ativar_combiner_2==true){
         buffer_up_combiner_2=iCustom(NULL,0,combiner_filename_2,combiner_buff_up_2,i+indice_buffers_2);
         buffer_down_combiner_2=iCustom(NULL,0,combiner_filename_2,combiner_buff_down_2,i+indice_buffers_2);
      }
      if(ativar_combiner_oscilador ==true){
         buffer_combiner_oscilador=iCustom(NULL,0,combiner_filename_oscilador,combiner_buff_oscilador,i+indice_buffers_3);
      }
      if(donforex || rompimento_donforex){
         double donforex = iCustom(NULL,0,donforex_filename,0,0); 
      }
      
      //---entrada pra PUT
      if((trend_filter==false || (open[i] < moving_average && Close[i] < moving_average)) 
      && (!donforex || DonForex(high[i], open[i], close[i], false)==true)
      && (lta_ltb_filter==false || (open[i]<lta && high[i] >= lta && lta != EMPTY_VALUE && lta_bef != EMPTY_VALUE))
      && ((!donforex_ltaltb && rompimento_donforex && DonForex(close[i], open[i], close[i], true,true)==true)
      || (!donforex_ltaltb && rompimento_lta_ltb && open[i]>ltb && close[i] <= ltb && ltb != EMPTY_VALUE && ltb_bef != EMPTY_VALUE)
      || (!rompimento_donforex && !rompimento_lta_ltb)
      || (donforex_ltaltb && rompimento_donforex && rompimento_lta_ltb && DonForex(close[i], open[i], close[i], true,true)==true && open[i]>ltb && close[i] <= ltb && ltb != EMPTY_VALUE && ltb_bef != EMPTY_VALUE))
      && (ativar_bb==false || ((open[i] < upperBand && high[i] >= upperBand) && (open[i+1] < upperBand_bef && high[i+1] < upperBand_bef)))
      && (ativar_fibo==false || (open[i]<levels_price[inpLevel55] && ((open[i] < levels_price[regiao_1_fibo_ind] && high[i] >= levels_price[regiao_1_fibo_ind] && regiao_1_fibo!=inpLevel00)
      || (open[i] < levels_price[regiao_2_fibo_ind] && high[i] >= levels_price[regiao_2_fibo_ind] && regiao_2_fibo!=inpLevel00)) && i<shift_ref5_fibo && i<shift_ref0_fibo))
      && (!ativar_combiner||aplicar_combiner==seta||(buffer_down_combiner!=0&&buffer_down_combiner!=EMPTY_VALUE&&aplicar_combiner==pre_alerta))
      && (!ativar_combiner_2||aplicar_combiner_2==seta||(buffer_down_combiner_2!=0&&buffer_down_combiner_2!=EMPTY_VALUE&&aplicar_combiner_2==pre_alerta))
      && (!ativar_combiner_oscilador||aplicar_combiner_oscilador==seta||usar_como_oscilador==seta_sinal||(buffer_combiner_oscilador>combiner_nivel_sobrecompra_oscilador&&usar_como_oscilador==filtro&&aplicar_combiner_oscilador==pre_alerta))
      && (!ativar_combiner_oscilador||aplicar_combiner_oscilador==seta||usar_como_oscilador==filtro
      ||(buffer_combiner_oscilador>combiner_nivel_sobrecompra_oscilador 
      && OsciladorBef(i,false)==true
      && usar_como_oscilador==seta_sinal&&aplicar_combiner_oscilador==pre_alerta))
      && (!block_loss_global || i!=1 || get_chart_id()==ChartID())
      && (i!=0 || (befTime_check==Time[0] && ultimo_resultado=="win") || !block_loss_restrito)
      && (i!=0 || (befTime_check==Time[0] && ultimo_result=="win") || !block_loss_global)
      && (befTime_telegram!=iTime(NULL,0,1) || i>2)
      && (enviar_sinais_x_tempos==0 || i!=0 || iTime(NULL,0,0)>(befTime_telegram+PeriodSeconds()+enviar_sinais_x_tempos*60))
      && (!ativar_sar || parabolic_sar>high[i])
      && (i!=0 || CountWinsAndLosses(arquivo_estatisticas))
      && ((ativar_stop_win && stop_win_atual < qtd_stop_win) || !ativar_stop_win || i!=0)
      && ((ativar_stop_loss && stop_loss_atual < qtd_stop_loss) || !ativar_stop_loss || i!=0) 
      && (!ativar_confirmacao || (CountSeconds()<=confirmacao_segundos && i==0) || i!=0)
      ){
      
         //-- filtro: ignorar toques lta_ltb
         bool mostrar_sinal=false;
         if(ignorar_toques!=0 && lta_ltb_filter==true){
            int contador=0;

            for(int n=i+1; n<=total_bars; n++){
               lta = iCustom(Symbol(),0,ltaltb_filename,1,n);
               lta_bef = iCustom(Symbol(),0,ltaltb_filename,1,n+1);
               
               if(open[n]<lta && high[n] >= lta && lta != EMPTY_VALUE && PossibleUpBf[n] == EMPTY_VALUE && Up[n] == EMPTY_VALUE && lta_bef != EMPTY_VALUE && PossibleDwBf[n+1] == EMPTY_VALUE){
                  contador++;
               }
               if(lta_bef == EMPTY_VALUE) break;
               if(contador>=ignorar_toques){
                  mostrar_sinal=true;
                  break;
               }
            }
         }else mostrar_sinal=true;
         //----
         
         //-- filtro: contar cores
         if(ativar_filtro_cores){
             string cores[]; //position: 0 -> green | 1 -> red
             StringSplit(filtro_contar_cores(i+1),StringGetCharacter(";",0),cores);
             if(mostrar_sinal==true){
               if((!inverter_filtro_cores && StringToInteger(cores[0]) > StringToInteger(cores[1])) || (inverter_filtro_cores && (StringToInteger(cores[1]) > StringToInteger(cores[0])))) mostrar_sinal=false;
             }else{
               if((!inverter_filtro_cores && StringToInteger(cores[0]) < StringToInteger(cores[1])) || (inverter_filtro_cores && (StringToInteger(cores[1]) < StringToInteger(cores[0])))) mostrar_sinal=true;  
             }
         }
         //--
         
         if(mostrar_sinal==true){
         
         //--sinal com filtro ou sem filtro de intercalação        
         if(ativar_fibo==true && intercalacao==true && PossibleUpBf[i] == EMPTY_VALUE && PossibleDwBf[i+1] == EMPTY_VALUE && PossibleUpBf[i+1] == EMPTY_VALUE){
            if(!inverter_sinais) PossibleDwBf[i]=high[i]+SPC*Point;
            else PossibleUpBf[i]=low[i]-SPC*Point;
         }
         else if(ativar_fibo==true && intercalacao==false && PossibleUpBf[i]==EMPTY_VALUE){
            if(!inverter_sinais) PossibleDwBf[i]=high[i]+SPC*Point;
            else PossibleUpBf[i]=low[i]-SPC*Point;
         }
         else if(ativar_fibo==false && intercalacao==true && PossibleUpBf[i] == EMPTY_VALUE && PossibleDwBf[i+1] == EMPTY_VALUE && PossibleUpBf[i+1] == EMPTY_VALUE){
            if(!inverter_sinais) PossibleDwBf[i]=high[i]+SPC*Point;
            else PossibleUpBf[i]=low[i]-SPC*Point;
         }
         
         else if(intercalacao==true && lta_ltb_filter==true){
            lta = iCustom(Symbol(),0,ltaltb_filename,1,i);
            lta_bef = iCustom(Symbol(),0,ltaltb_filename,1,i+1);
            
            if(open[i]<lta && high[i] >= lta && lta != EMPTY_VALUE && PossibleUpBf[i] == EMPTY_VALUE && Up[i] == EMPTY_VALUE && lta_bef != EMPTY_VALUE && PossibleDwBf[i+1] == EMPTY_VALUE && PossibleUpBf[i+1] == EMPTY_VALUE){
               if(!inverter_sinais) PossibleDwBf[i]=high[i]+SPC*Point;
               else PossibleUpBf[i]=low[i]-SPC*Point;
            }
         } 

        //mandar sinal para o automatizador pelo pré-alerta
        if(autotrading==true && sinal_na==pre_alerta && i==0 && PossibleDwBf[i]!=EMPTY_VALUE && befTime_signal!=Time[0]){
            if(select_tool==MT2) mt2trading(_Symbol, "PUT", TradeAmount, ExpiryMinutes, MartingaleType, MartingaleSteps, MartingaleCoef, Broker, "LIFE CHANGING", signalID);
            else if(select_tool==MX2) mx2trading(_Symbol, "PUT", expiraca_mx2, "LIFE CHANGING", sinal_tipo_mx2, tipo_expiracao_mx2, timeframe, mID, "0");
            else if(select_tool==B2IQ){
               /*if(vpss=="") put(Symbol(), Period(), Modalidade, SinalEntrada, vps);
               else*/ put(Symbol(), Period(), Modalidade, SinalEntrada, NomeEstrategia, vpss);
            }
            befTime_signal=Time[0];
         }
         //---
                   
         //--pré alerta            
         if(mode_alert && i==0 && PossibleDwBf[i]!=EMPTY_VALUE && befTime!=Time[i]){
            Alert(Symbol()+" ["+IntegerToString(Period())+"] => Possível PUT!");
            befTime=Time[i];
         }  
         
         //---
         
         if(PossibleDwBf[i]!=EMPTY_VALUE && i==0){
            eh_repinte=false;
            befTime_repaint=iTime(NULL,0,0);
         }
         else if(PossibleDwBf[i]!=EMPTY_VALUE && i!=0 && befTime_repaint!=iTime(NULL,0,1)) eh_repinte=true;
         
         }
      }
      //--- entrada pra PUT FIM
      
      //Print(ultimo_resultado_global()+" "+i);
      
      //--- entrada pra CALL
      if(((open[i] > moving_average && Close[i] > moving_average) || trend_filter==false) 
         && (!donforex || DonForex(low[i], open[i], close[i], true)==true)
         && (lta_ltb_filter==false || (open[i]>ltb && low[i] <= ltb && ltb != EMPTY_VALUE && ltb_bef != EMPTY_VALUE))
         && ((!donforex_ltaltb && rompimento_donforex && DonForex(close[i], open[i], close[i], false, true)==true) 
         || (!donforex_ltaltb && rompimento_lta_ltb && open[i]<lta && close[i] >= lta && lta != EMPTY_VALUE && lta_bef != EMPTY_VALUE)
         || (!rompimento_donforex && !rompimento_lta_ltb)
         || (donforex_ltaltb && rompimento_donforex && rompimento_lta_ltb && DonForex(close[i], open[i], close[i], false, true)==true && open[i]<lta && close[i] >= lta && lta != EMPTY_VALUE && lta_bef != EMPTY_VALUE))
         && (ativar_bb==false || ((open[i] > lowerBand && low[i] <= lowerBand) && (open[i+1] > lowerBand_bef && low[i+1] > lowerBand_bef)))
         && (ativar_fibo==false || (open[i] > levels_price[inpLevel55] && ((open[i]>levels_price[regiao_1_fibo_ind] && low[i] <= levels_price[regiao_1_fibo_ind] && regiao_1_fibo!=inpLevel00)
         || (open[i]>levels_price[regiao_2_fibo_ind] && low[i] <= levels_price[regiao_2_fibo_ind] && regiao_2_fibo!=inpLevel00)) && i<shift_ref5_fibo && i<shift_ref0_fibo))
         && (!ativar_combiner||aplicar_combiner==seta||(buffer_up_combiner!=0&&buffer_up_combiner!=EMPTY_VALUE&&aplicar_combiner==pre_alerta))
         && (!ativar_combiner_2||aplicar_combiner_2==seta||(buffer_up_combiner_2!=0&&buffer_up_combiner_2!=EMPTY_VALUE&&aplicar_combiner_2==pre_alerta))
         && (!ativar_combiner_oscilador||aplicar_combiner_oscilador==seta||usar_como_oscilador==seta_sinal||(buffer_combiner_oscilador<combiner_nivel_sobrevenda_oscilador&&usar_como_oscilador==filtro&&aplicar_combiner_oscilador==pre_alerta))
         && (!ativar_combiner_oscilador||aplicar_combiner_oscilador==seta||usar_como_oscilador==filtro
         ||(buffer_combiner_oscilador<combiner_nivel_sobrevenda_oscilador 
         && OsciladorBef(i,true)==true
         && usar_como_oscilador==seta_sinal&&aplicar_combiner_oscilador==pre_alerta))
         && (!block_loss_global || i!=1 || get_chart_id()==ChartID())
         && (i!=0 || (befTime_check==Time[0] && ultimo_resultado=="win") || !block_loss_restrito)
         && (i!=0 || (befTime_check==Time[0] && ultimo_result=="win") || !block_loss_global)
         && (befTime_telegram!=iTime(NULL,0,1) || i>2)
         && (enviar_sinais_x_tempos==0 || i!=0 || iTime(NULL,0,0)>(befTime_telegram+PeriodSeconds()+enviar_sinais_x_tempos*60))
         && (!ativar_sar || parabolic_sar<low[i])
         && (i!=0 || CountWinsAndLosses(arquivo_estatisticas))
         && ((ativar_stop_win && stop_win_atual < qtd_stop_win) || !ativar_stop_win || i!=0)
         && ((ativar_stop_loss && stop_loss_atual < qtd_stop_loss) || !ativar_stop_loss || i!=0)
         && (!ativar_confirmacao || (CountSeconds()<=confirmacao_segundos && i==0) || i!=0)
         ){
         
         //--ignorar toques lta e ltb
         bool mostrar_sinal = false;
         if(ignorar_toques!=0 && lta_ltb_filter==true){
            int contador=0;

            for(int n=i+1; n<=total_bars; n++){
               ltb = iCustom(Symbol(),0,ltaltb_filename,0,n);
               ltb_bef = iCustom(Symbol(),0,ltaltb_filename,0,n+1);
               
               if(open[n]>ltb && low[n] <= ltb && ltb != EMPTY_VALUE && PossibleDwBf[n] == EMPTY_VALUE && Dw[n] == EMPTY_VALUE && ltb_bef != EMPTY_VALUE && PossibleUpBf[n+1] == EMPTY_VALUE && PossibleDwBf[n+1] == EMPTY_VALUE){
                  contador++;
               }
               if(ltb_bef == EMPTY_VALUE) break;
               if(contador>=ignorar_toques){
                  mostrar_sinal=true;
                  break;
               }
            }
         }else mostrar_sinal=true;
         
         if(ativar_filtro_cores){
             string cores[]; //position: 0 -> green | 1 -> red
             StringSplit(filtro_contar_cores(i+1),StringGetCharacter(";",0),cores);
             if(mostrar_sinal==true){
               if((!inverter_filtro_cores && StringToInteger(cores[1]) > StringToInteger(cores[0])) || (inverter_filtro_cores && (StringToInteger(cores[0]) > StringToInteger(cores[1])))) mostrar_sinal=false;
             }else{
               if((!inverter_filtro_cores && StringToInteger(cores[1]) < StringToInteger(cores[0])) || (inverter_filtro_cores && (StringToInteger(cores[0]) < StringToInteger(cores[1])))) mostrar_sinal=true;  
             }
         }
         
         if(mostrar_sinal==true){
         
         if(ativar_fibo==true && intercalacao==true && PossibleDwBf[i] == EMPTY_VALUE && PossibleDwBf[i+1] == EMPTY_VALUE && PossibleUpBf[i+1] == EMPTY_VALUE){
            if(!inverter_sinais) PossibleUpBf[i]=low[i]-SPC*Point;
            else PossibleDwBf[i]=high[i]+SPC*Point;
         }
         else if(ativar_fibo==true && intercalacao==false && PossibleDwBf[i]==EMPTY_VALUE){
            if(!inverter_sinais) PossibleUpBf[i]=low[i]-SPC*Point;
            else PossibleDwBf[i]=high[i]+SPC*Point;
         }
         else if(ativar_fibo==false && intercalacao==true && PossibleDwBf[i] == EMPTY_VALUE && PossibleDwBf[i+1] == EMPTY_VALUE && PossibleUpBf[i+1] == EMPTY_VALUE){
            if(!inverter_sinais) PossibleUpBf[i]=low[i]-SPC*Point;
            else PossibleDwBf[i]=high[i]+SPC*Point;
         }
         
         else if(intercalacao==true && lta_ltb_filter==true && mostrar_sinal==true){
            ltb = iCustom(Symbol(),0,ltaltb_filename,0,i);
            ltb_bef = iCustom(Symbol(),0,ltaltb_filename,0,i+1);
            
            if(open[i]>ltb && low[i] <= ltb && ltb != EMPTY_VALUE && PossibleDwBf[i] == EMPTY_VALUE && Dw[i] == EMPTY_VALUE && ltb_bef != EMPTY_VALUE && PossibleUpBf[i+1] == EMPTY_VALUE && PossibleDwBf[i+1] == EMPTY_VALUE){
               if(!inverter_sinais) PossibleUpBf[i]=low[i]-SPC*Point;
               else PossibleDwBf[i]=high[i]+SPC*Point;
            }
         } 
         
         if(autotrading==true && sinal_na==pre_alerta && i==0 && PossibleUpBf[i]!=EMPTY_VALUE && befTime_signal!=Time[0]){
            if(!filtro_noticias || iTime(NULL,PERIOD_M1,0) > FiltroNoticias()){
               if(select_tool==MT2) mt2trading(_Symbol, "CALL", TradeAmount, ExpiryMinutes, MartingaleType, MartingaleSteps, MartingaleCoef, Broker, "LIFE CHANGING", signalID);
               else if(select_tool==MX2) mx2trading(_Symbol, "CALL", expiraca_mx2, "LIFE CHANGING", sinal_tipo_mx2, tipo_expiracao_mx2, timeframe, mID, "0");
               else if(select_tool==B2IQ){
                  /*if(vpss=="") call(Symbol(), Period(), Modalidade, SinalEntrada, vps);
                  else*/ call(Symbol(), Period(), Modalidade, SinalEntrada, NomeEstrategia, vpss);
               }
            }
            befTime_signal=Time[0];
         }
         
         if(mode_alert && i==0 && PossibleUpBf[i]!=EMPTY_VALUE && befTime!=Time[i]){
            Alert(Symbol()+" ["+IntegerToString(Period())+"] => Possível CALL!");
            befTime=Time[i];
         }  
         
         if(PossibleUpBf[i]!=EMPTY_VALUE && i==0){
            eh_repinte=false;
            befTime_repaint=iTime(NULL,0,0);
         }
         else if(PossibleUpBf[i]!=EMPTY_VALUE && i!=0 && befTime_repaint!=iTime(NULL,0,1)) eh_repinte=true;
         
         }
      }
      //--- entrada pra CALL FIM
      
      if(PossibleDwBf[i]!=EMPTY_VALUE && i==0) PossibleDwBf[i]=High[i]+SPC*Point;
      else if(PossibleUpBf[i]!=EMPTY_VALUE && i==0) PossibleUpBf[i]=Low[i]-SPC*Point;
      
      if(PossibleDwBf[i+1]!=EMPTY_VALUE && (i!=0 || get_chart_id()==ChartID() || !block_loss_global) && (i!=0 || !eh_repinte || (!block_loss_global && !block_loss_restrito))){
         //----confluências na seta
            int count_confluencias=0;
            
           //somente combiner 1
            if(ativar_combiner 
            && aplicar_combiner==seta 
            && buffer_down_combiner!=0 && buffer_down_combiner!=EMPTY_VALUE){
               count_confluencias++;
            }
            
            else if(ativar_combiner && aplicar_combiner==pre_alerta)
               count_confluencias++;
            
            //somente combiner 2
            if(ativar_combiner_2 
            && aplicar_combiner_2==seta 
            && buffer_down_combiner_2!=0 && buffer_down_combiner_2!=EMPTY_VALUE){
               count_confluencias++;
            }
            
            else if(ativar_combiner_2 && aplicar_combiner_2==pre_alerta)
               count_confluencias++;
            
            //somente oscilador
            if(ativar_combiner_oscilador
            && aplicar_combiner_oscilador==seta 
            && ((buffer_combiner_oscilador > combiner_nivel_sobrecompra_oscilador && usar_como_oscilador == filtro)
            || (buffer_combiner_oscilador > combiner_nivel_sobrecompra_oscilador 
            && OsciladorBef(i,false)==true
            && usar_como_oscilador == seta_sinal))
            ){
               count_confluencias++;
            }
            
            else if(ativar_combiner_oscilador && aplicar_combiner_oscilador==pre_alerta)
               count_confluencias++;
               
            if(count_confluencias==count_dd && count_confluencias>0)
               Dw[i]=high[i]+SPC*Point;
         //---
      
         if(!ativar_combiner && !ativar_combiner_2 && !ativar_combiner_oscilador)
            Dw[i]=high[i]+SPC*Point;

         //autotrading - sinais automatizados
         if(autotrading==true && sinal_na==seta && i==0 && befTime_signal!=Time[0] && Dw[i]!=EMPTY_VALUE){
            if(!filtro_noticias || iTime(NULL,PERIOD_M1,0) > FiltroNoticias()){
               if(select_tool==MT2) mt2trading(_Symbol, "PUT", TradeAmount, ExpiryMinutes, MartingaleType, MartingaleSteps, MartingaleCoef, Broker, "LIFE CHANGING", signalID);
               else if(select_tool==MX2) mx2trading(_Symbol, "PUT", expiraca_mx2, "LIFE CHANGING", sinal_tipo_mx2, tipo_expiracao_mx2, timeframe, mID, "0");
               else if(select_tool==B2IQ){
                  /*if(vpss=="") put(Symbol(), Period(), Modalidade, SinalEntrada, vps);
                  else*/ put(Symbol(), Period(), Modalidade, SinalEntrada, NomeEstrategia, vpss);
               }
            }
            befTime_signal=Time[0];
         }
      }
      
      else if(PossibleUpBf[i+1]!=EMPTY_VALUE && (i!=0 || get_chart_id()==ChartID() || !block_loss_global) && (i!=0 || !eh_repinte || (!block_loss_global && !block_loss_restrito))){
         //----confluências na seta
            int count_confluencias=0;
            
           //somente combiner 1
            if(ativar_combiner 
            && aplicar_combiner==seta 
            && buffer_up_combiner!=0 && buffer_up_combiner!=EMPTY_VALUE){
               count_confluencias++;
            }
            
            else if(ativar_combiner && aplicar_combiner==pre_alerta)
               count_confluencias++;
           
            //somente combiner 2
            if(ativar_combiner_2 
            && aplicar_combiner_2==seta 
            && buffer_up_combiner_2!=0 && buffer_up_combiner_2!=EMPTY_VALUE){
               count_confluencias++;
            }
            
            else if(ativar_combiner_2 && aplicar_combiner_2==pre_alerta)
               count_confluencias++;
           
            //somente oscilador
            if(ativar_combiner_oscilador
            && aplicar_combiner_oscilador==seta 
            && ((buffer_combiner_oscilador < combiner_nivel_sobrevenda_oscilador && usar_como_oscilador == filtro)
            || (buffer_combiner_oscilador < combiner_nivel_sobrevenda_oscilador 
            && OsciladorBef(i,true)==true
            && usar_como_oscilador == seta_sinal))
            ){
               count_confluencias++;
            }
            
            else if(ativar_combiner_oscilador && aplicar_combiner_oscilador==pre_alerta)
               count_confluencias++;
            
            if(count_confluencias==count_dd && count_confluencias>0)
               Up[i]=low[i]-SPC*Point;
         //---
         
         if(!ativar_combiner && !ativar_combiner_2 && !ativar_combiner_oscilador)
            Up[i]=low[i]-SPC*Point;
         
         //autotrading - sinais automatizados
         if(autotrading==true && sinal_na==seta && i==0 && befTime_signal!=Time[0] && Up[i]!=EMPTY_VALUE){
            if(!filtro_noticias || iTime(NULL,PERIOD_M1,0) > FiltroNoticias()){
               if(select_tool==MT2) mt2trading(_Symbol, "CALL", TradeAmount, ExpiryMinutes, MartingaleType, MartingaleSteps, MartingaleCoef, Broker, "LIFE CHANGING", signalID);
               else if(select_tool==MX2) mx2trading(_Symbol, "CALL", expiraca_mx2, "LIFE CHANGING", sinal_tipo_mx2, tipo_expiracao_mx2, timeframe, mID, "0");
               else if(select_tool==B2IQ){
                  /*if(vpss=="") call(Symbol(), Period(), Modalidade, SinalEntrada, vps);
                  else*/ call(Symbol(), Period(), Modalidade, SinalEntrada, NomeEstrategia, vpss);
               }
            }
            befTime_signal=Time[0];
         }
      }
      
      if(Dw[i]!=EMPTY_VALUE && i==0) Dw[i]=High[i]+SPC*Point;
      else if(Up[i]!=EMPTY_VALUE && i==0) Up[i]=Low[i]-SPC*Point;
      //--
   
      //---Check result
      if((Up[i]!=EMPTY_VALUE && i!=0) || ((Up[i+1]!=EMPTY_VALUE && i==0) && befTime_check!=Time[0])){
         int v=i;
         if(i==0) v=1;
         
         if(Close[v]>Open[v]){
            ganhou[v]=high[v]+SPC*_Point;
            
            if(v==1){
               ultimo_resultado="win";
            
               if(block_loss_global){
                  string ultimo_result_global = ultimo_resultado_global();
               
                  if((ultimo_result_global=="nda"||ultimo_result_global=="loss") && iTime(NULL,0,v)>ultimo_resultado_global_time()) SalvarSinal(iTime(NULL,0,v),"win");
               }
            }
         }else if(Close[v]<Open[v]){
            perdeu[v]=high[v]+SPC*_Point;
            if(ultimo_resultado=="win" && v==1) ultimo_resultado="loss";
         }
         else{
            empatou[v]=high[v];
            if(ultimo_resultado=="win" && v==1) ultimo_resultado="loss";
         }
         
         if(v>2){
            if(perdeu[v]!=EMPTY_VALUE){
               if(Close[v-1]>Open[v-1]) ganhou1[v-1]=High[v-1]+SPC*_Point;
               else if(Close[v-1]<Open[v-1]) perdeu1[v-1]=High[v-1]+SPC*_Point;
               else empatou1[v-1]=High[v-1];
               
               if(perdeu1[v-1]!=EMPTY_VALUE){
                  if(Close[v-2]>Open[v-2]) ganhou2[v-2]=High[v-2]+SPC*_Point;
                  else if(Close[v-2]<Open[v-2]) perdeu2[v-2]=High[v-2]+SPC*_Point;
                  else empatou2[v-2]=High[v-2];
               }
            }
        }
         
         befTime_check=Time[0];
      }
      
      else if((Dw[i]!=EMPTY_VALUE && i!=0) || ((Dw[i+1]!=EMPTY_VALUE && i==0) && befTime_check!=Time[0])){
         int v=i;
         if(i==0) v=1;
         
         if(Close[v]<Open[v]){
            ganhou[v]=low[v]-SPC*_Point;
            
            if(v==1){
               ultimo_resultado="win";
               
               if(block_loss_global){
                  string ultimo_result_global = ultimo_resultado_global();
               
                  if((ultimo_result_global=="nda"||ultimo_result_global=="loss") && iTime(NULL,0,v)>ultimo_resultado_global_time()) SalvarSinal(iTime(NULL,0,v),"win");
               }
            }
         }
         else if(Close[v]>Open[v]){
            perdeu[v]=low[v]-SPC*_Point;
            if(ultimo_resultado=="win" && v==1) ultimo_resultado="loss";
         }
         else if(Close[v]==Open[v]){
            empatou[v]=low[v];
            if(ultimo_resultado=="win" && v==1) ultimo_resultado="loss";
         }
         
         if(v>2){
            if(perdeu[v]!=EMPTY_VALUE){
               if(Close[v-1]<Open[v-1]) ganhou1[v-1]=High[v-1]+SPC*_Point;
               else if(Close[v-1]>Open[v-1]) perdeu1[v-1]=High[v-1]+SPC*_Point;
               else empatou1[v-1]=High[v-1];
               
               if(perdeu1[v-1]!=EMPTY_VALUE){
                  if(Close[v-2]<Open[v-2]) ganhou2[v-2]=High[v-2]+SPC*_Point;
                  else if(Close[v-2]>Open[v-2]) perdeu2[v-2]=High[v-2]+SPC*_Point;
                  else empatou2[v-2]=High[v-2];
               }
            }
         }
         
         befTime_check=Time[0]; 
      }

            
            if(enviar_msg_sessao) SendMessageTelegram();
            
            if(PossibleUpBf[i] != 0 && PossibleUpBf[i] != EMPTY_VALUE && befTime_telegram != Time[0] && 
            (!filtro_noticias || iTime(NULL,PERIOD_M1,0) > FiltroNoticias())
            && ((sessao_manha && (TimeLocal()>=horario_inicio_manha&&TimeLocal()<horario_fim_manha))
            || ((sessao_tarde && TimeLocal()>=horario_inicio_tarde&&TimeLocal()<horario_fim_tarde))
            || ((sessao_noite && TimeLocal()>=horario_inicio_noite&&TimeLocal()<horario_fim_noite))
            || (!sessao_manha && !sessao_noite && !sessao_tarde))
            ){
               ArrayResize(entrada,ArraySize(entrada)+1);
               entrada[ArraySize(entrada)-1]=Close[0];
               ultima_operacao="up";
                     
               if(Entrada==NA_MESMA_VELA){
                  ArrayResize(horario_entrada,ArraySize(horario_entrada)+1);
                  horario_entrada[ArraySize(horario_entrada)-1]=iTime(Symbol(),_Period,0);
                  
                  datetime time_final = iTime(Symbol(),_Period,0)+tempo_expiracao*60;
                  datetime horario_inicial = Offset(iTime(Symbol(),_Period,0),time_final);
                  int tempo_restante = TimeMinute(time_final)-TimeMinute(horario_inicial);
                  
                  if(tempo_restante==1 && TimeSeconds(TimeGMT())>30){
                     ArrayResize(horario_expiracao,ArraySize(horario_expiracao)+1);    
                     horario_expiracao[ArraySize(horario_expiracao)-1]=iTime(Symbol(),_Period,0)+(tempo_expiracao*2)*60;
                  }else{
                     ArrayResize(horario_expiracao,ArraySize(horario_expiracao)+1);    
                     horario_expiracao[ArraySize(horario_expiracao)-1]=iTime(Symbol(),_Period,0)+tempo_expiracao*60;
                  }
               }else{
                  datetime h_entrada=iTime(Symbol(),_Period,0)+_Period*60;
                  
                  ArrayResize(horario_entrada,ArraySize(horario_entrada)+1);
                  horario_entrada[ArraySize(horario_entrada)-1]=h_entrada;
                           
                  ArrayResize(horario_expiracao,ArraySize(horario_expiracao)+1);    
                  horario_expiracao[ArraySize(horario_expiracao)-1] = h_entrada+tempo_expiracao*60; 
               }
      
               ArrayResize(tipo_entrada,ArraySize(tipo_entrada)+1);
               tipo_entrada[ArraySize(tipo_entrada)-1]=CALL;
                              
               ArrayResize(horario_entrada_local,ArraySize(horario_entrada_local)+1);
               horario_entrada_local[ArraySize(horario_entrada_local)-1]=GetHoraMinutos(iTime(Symbol(),_Period,0));
               
               datetime tempo = Entrada==NA_PROXIMA_VELA ? iTime(Symbol(),_Period,0) : iTime(Symbol(),PERIOD_M1,0);
               
               estatisticas estatistica;
               if(assertividade_global==true || assertividade_restrita==true){
                  estatistica.Reset();
                  AtualizarEstatisticas(estatistica, arquivo_estatisticas);
               }
               
               string msg="", msg_telegram="";
               if(Entrada==NA_PROXIMA_VELA){
                  msg = "E103E103E103E103E103E103E103E103E103"
                  +"E110 E104 "+nome_sala+" E105"
                  +"E110E110"
                  +"E112 SINAL "+Symbol()+" CALL E107 "+up+"E110"
                  +"E112 ENTRADA "+GetHoraMinutos(tempo)+"E110"
                  +"E112 "+msg2+"E110"
                  +"E112 Expiração de "+expiracao;
                  
                  msg_telegram = "E103E103E103E103E103E103E103E103E103"
                  +"E110 E104 "+nome_sala+" E105"
                  +"E110E110"
                  +"E112 SINAL "+Symbol()+" CALL E107 "+up+"E110"
                  +"E112 ENTRADA "+GetHoraMinutos(tempo)+"E110"
                  +"E112 "+msg2+"E110"
                  +"E112 Expiração de "+expiracao;
               }else{
                  msg = !mostrar_taxa ? "E103E103E103E103E103E103E103E103E103"
                  +"E110 E104 "+nome_sala+" E105"
                  +"E110E110"
                  +"E112 SINAL "+Symbol()+" CALL E107 "+up+"E110"
                  +"E112 ENTRADA "+GetHoraMinutos(tempo)+" (AGORA)E110"
                  +"E112 EXPIRAÇÃO "+GetHoraMinutos2(horario_expiracao[ArraySize(horario_expiracao)-1])+"E110"
                  +"E112 "+msg2+"E110"
                  +"E112 Expiração de "+expiracao  :"E103E103E103E103E103E103E103E103E103"
                  +"E110 E104 "+nome_sala+" E105"
                  +"E110E110"
                  +"E112 SINAL "+Symbol()+" CALL E107 "+up+"E110"
                  +"E112 ENTRADA "+GetHoraMinutos(tempo)+" (AGORA)E110"
                  +"E112 TAXA "+entrada[ArraySize(entrada)-1]+"E110"
                  +"E112 EXPIRAÇÃO "+GetHoraMinutos2(horario_expiracao[ArraySize(horario_expiracao)-1])+"E110"
                  +"E112 "+msg2+"E110"
                  +"E112 Expiração de "+expiracao;
               }
               
               if(assertividade_global==true && assertividade_restrita==true){
                  msg+="E110E110Win: "+estatistica.win_global+" | Loss: "+estatistica.loss_global+" ("+estatistica.assertividade_global_valor+")E110";
                  msg+="Esse par: "+estatistica.win_restrito+"x"+estatistica.loss_restrito+" ("+estatistica.assertividade_restrita_valor+")";
               }
               
               else if(assertividade_global==true && assertividade_restrita==false)
                  msg+="E110E110Win: "+estatistica.win_global+" | Loss: "+estatistica.loss_global+" ("+estatistica.assertividade_global_valor+")E110";
               
               else if(assertividade_global==false && assertividade_restrita==true)
                  msg+="E110E110Esse par: "+estatistica.win_restrito+"x"+estatistica.loss_restrito+" ("+estatistica.assertividade_restrita_valor+")";
               
               if(TelegramSendText(apikey, chatid, WppConverterSymbol(msg))==IntegerToString(0)
                     ){
                        Print("=> Enviou sinal de CALL para o Telegram");
                        sendwhats(msg);
                     }
               
               befTime_telegram = Time[0];
               
               if(block_loss_global){
                  SalvarSinal(horario_entrada[ArraySize(horario_entrada)-1]+(tempo_expiracao*60)*2,"nda"); 
               }
            }
         
            else if(PossibleDwBf[i] != 0 && PossibleDwBf[i] != EMPTY_VALUE && befTime_telegram != Time[0] && 
            (!filtro_noticias || iTime(NULL,PERIOD_M1,0) > FiltroNoticias())
            && ((sessao_manha && (TimeLocal()>=horario_inicio_manha&&TimeLocal()<horario_fim_manha))
            || (sessao_tarde && (TimeLocal()>=horario_inicio_tarde&&TimeLocal()<horario_fim_tarde))
            || (sessao_noite && (TimeLocal()>=horario_inicio_noite&&TimeLocal()<horario_fim_noite))
            || (!sessao_manha && !sessao_noite && !sessao_tarde))
            ){
               ArrayResize(entrada,ArraySize(entrada)+1);
               entrada[ArraySize(entrada)-1]=Close[0];
               ultima_operacao="down";
               
               if(Entrada==NA_MESMA_VELA){
                  ArrayResize(horario_entrada,ArraySize(horario_entrada)+1);
                  horario_entrada[ArraySize(horario_entrada)-1]=iTime(Symbol(),_Period,0);
                  
                  datetime time_final = iTime(Symbol(),_Period,0)+tempo_expiracao*60;
                  datetime horario_inicial = Offset(iTime(Symbol(),_Period,0),time_final);
                  int tempo_restante = TimeMinute(time_final)-TimeMinute(horario_inicial);
                  
                  if(tempo_restante==1 && TimeSeconds(TimeGMT())>30){
                     ArrayResize(horario_expiracao,ArraySize(horario_expiracao)+1);    
                     horario_expiracao[ArraySize(horario_expiracao)-1]=iTime(Symbol(),_Period,0)+(tempo_expiracao*2)*60;
                  }else{
                     ArrayResize(horario_expiracao,ArraySize(horario_expiracao)+1);    
                     horario_expiracao[ArraySize(horario_expiracao)-1]=iTime(Symbol(),_Period,0)+tempo_expiracao*60;
                  }
               }else{
                  datetime h_entrada=iTime(Symbol(),_Period,0)+_Period*60;
                  
                  ArrayResize(horario_entrada,ArraySize(horario_entrada)+1);
                  horario_entrada[ArraySize(horario_entrada)-1]=h_entrada;
                           
                  ArrayResize(horario_expiracao,ArraySize(horario_expiracao)+1);    
                  horario_expiracao[ArraySize(horario_expiracao)-1]= h_entrada+tempo_expiracao*60; 
               }
               
               ArrayResize(tipo_entrada,ArraySize(tipo_entrada)+1);
               tipo_entrada[ArraySize(tipo_entrada)-1]=PUT;

               ArrayResize(horario_entrada_local,ArraySize(horario_entrada_local)+1);
               horario_entrada_local[ArraySize(horario_entrada_local)-1]=GetHoraMinutos(iTime(Symbol(),_Period,0));
               
               datetime tempo = Entrada==NA_PROXIMA_VELA ? iTime(Symbol(),_Period,0) : iTime(Symbol(),PERIOD_M1,0);
               
               estatisticas estatistica;
               if(assertividade_global==true || assertividade_restrita==true){
                  estatistica.Reset();
                  AtualizarEstatisticas(estatistica, arquivo_estatisticas);
               }
               
               string msg="";
               if(Entrada==NA_PROXIMA_VELA){
                  //Whatsapp msg
                  msg = "E103E103E103E103E103E103E103E103E103"
                  +"E110 E104 "+nome_sala+" E105"
                  +"E110E110"
                  +"E112 SINAL "+Symbol()+" PUT E106 "+down+"E110"
                  +"E112 ENTRADA "+GetHoraMinutos(tempo)+"E110"
                  +"E112 "+msg2+"E110"
                  +"E112 Expiração de "+expiracao;
               }else{
                  //Whatsapp msg
                  msg = !mostrar_taxa ? "E103E103E103E103E103E103E103E103E103"
                  +"E110 E104 "+nome_sala+" E105"
                  +"E110E110"
                  +"E112 SINAL "+Symbol()+" PUT E106 "+down+"E110"
                  +"E112 ENTRADA "+GetHoraMinutos(tempo)+" (AGORA)E110"
                  +"E112 EXPIRAÇÃO "+GetHoraMinutos2(horario_expiracao[ArraySize(horario_expiracao)-1])+"E110"
                  +"E112 "+msg2+"E110"
                  +"E112 Expiração de "+expiracao :"E103E103E103E103E103E103E103E103E103"
                  +"E110 E104 "+nome_sala+" E105"
                  +"E110E110"
                  +"E112 SINAL "+Symbol()+" PUT E106 "+down+"E110"
                  +"E112 ENTRADA "+GetHoraMinutos(tempo)+" (AGORA)E110"
                  +"E112 TAXA "+entrada[ArraySize(entrada)-1]+"E110"
                  +"E112 EXPIRAÇÃO "+GetHoraMinutos2(horario_expiracao[ArraySize(horario_expiracao)-1])+"E110"
                  +"E112 "+msg2+"E110" 
                  +"E112 Expiração de "+expiracao;
                  
               }
               
               if(assertividade_global==true && assertividade_restrita==true){
                  msg+="E110E110Win: "+estatistica.win_global+" | Loss: "+estatistica.loss_global+" ("+estatistica.assertividade_global_valor+")E110";
                  msg+="Esse par: "+estatistica.win_restrito+"x"+estatistica.loss_restrito+" ("+estatistica.assertividade_restrita_valor+")";
               }
               
               else if(assertividade_global==true && assertividade_restrita==false)
                  msg+="E110E110Win: "+estatistica.win_global+" | Loss: "+estatistica.loss_global+" ("+estatistica.assertividade_global_valor+")E110";
               
               else if(assertividade_global==false && assertividade_restrita==true)
                  msg+="E110E110Esse par: "+estatistica.win_restrito+"x"+estatistica.loss_restrito+" ("+estatistica.assertividade_restrita_valor+")";
                  
               if(TelegramSendText(apikey, chatid, WppConverterSymbol(msg))==IntegerToString(0)
                  ){
                     Print("=> Enviou sinal de PUT para o Telegram");
                     sendwhats(msg);
                  }
               
               befTime_telegram = Time[0];
               
               if(block_loss_global){
                  SalvarSinal(horario_entrada[ArraySize(horario_entrada)-1]+(tempo_expiracao*60)*2,"nda"); 
               }
            }
    }
      
    if(befTime_panel != Time[0]){
         Statistics();
         Painel();  
         VerticalLine(total_bars_shift,clrWhite);
         befTime_panel=Time[0];
     }
     
    

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

string WppConverterSymbol(string message){
    StringReplace(message,"E100", "❤️");
    StringReplace(message,"E101", "👇🏼");
    StringReplace(message,"E102", "✅");
    StringReplace(message,"E103", "⚠");
    StringReplace(message,"E104", "》》");
    StringReplace(message,"E105", "《《");
    StringReplace(message,"E106", "⬇️");
    StringReplace(message,"E107", "⬆️");
    StringReplace(message,"E108", "→");
    StringReplace(message,"E109", "✖");
    StringReplace(message,"E111", "🟢");
    StringReplace(message,"E112", "‼️");
    StringReplace(message,"E110", "\n");
    StringReplace(message,"E113", "🟢");
    StringReplace(message,"?", "");
    
    return message;
}


void OnTimer(){
   //---Check result Telegram
   
   for(int i=0; i<ArraySize(tipo_entrada); i++){
      horario_expiracao_gale = horario_expiracao[i]+tempo_expiracao*60; //horário acrescido para checkar o gale
      horario_expiracao_gale2 = horario_expiracao_gale+tempo_expiracao*60; //horário acrescido para checkar o gale
      horario_agora = iTime(Symbol(),_Period,0);
      bool remove_index=false;
   
      if(horario_agora>=horario_expiracao[i] || horario_agora>=horario_expiracao_gale){
         int shift_abertura=iBarShift(NULL,0,horario_entrada[i]);
         int shift_expiracao=tempo_expiracao==_Period ? shift_abertura : iBarShift(NULL,0,horario_expiracao[i]);
         
         int shift_abertura_gale=iBarShift(NULL,0,horario_expiracao[i]);
         int shift_expiracao_gale=tempo_expiracao==_Period ? shift_abertura_gale : iBarShift(NULL,0,horario_expiracao_gale);
         
         int shift_abertura_gale2=iBarShift(NULL,0,horario_expiracao_gale);
         int shift_expiracao_gale2=tempo_expiracao==_Period ? shift_abertura_gale2 : iBarShift(NULL,0,horario_expiracao_gale2);
         
         if(tipo_entrada[i]==CALL){ //entrada CALL
            if(ativar_win_gale==false){
               if(Entrada==NA_MESMA_VELA){
                  if(Close[shift_expiracao]>entrada[i]){
                     if(message_win!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                        sendwhats(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                     }
                     if(file_win!=EXAMPLE_PHOTO&&file_win!="") TelegramSendPhotoAsync(apikey, chatid, file_win, "");
                     remove_index=true;
                     if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"call","win");
                     else GravarResultado(Symbol(),horario_entrada_local[i],"call","win#");
                    
                     ultimo_resultado="win";
                     SalvarSinal(horario_agora,"win");
                  }
                   
                  else if(Close[shift_expiracao]<entrada[i]){
                     if(message_loss!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                        sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                     }
                     if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                     remove_index=true;
                     if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"call","loss");
                     else GravarResultado(Symbol(),horario_entrada_local[i],"call","loss#");
                    
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
                  
                  else if(Close[shift_expiracao]==entrada[i]){
                     if(message_empate!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_empate+"E109️ ️E108 "+Symbol()+" "+horario_entrada_local[i]+" E107 "+up));
                        sendwhats(message_empate+"E109️ ️E108 "+Symbol()+" "+horario_entrada_local[i]+" E107 "+up);
                     }
                     remove_index=true;
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
               }else{
                  if(Close[shift_expiracao]>Open[shift_abertura]){
                     if(message_win!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                        sendwhats(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                     }
                     if(file_win!=EXAMPLE_PHOTO&&file_win!="") TelegramSendPhotoAsync(apikey, chatid, file_win, "");
                     remove_index=true;
                     if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"call","win");
                     else GravarResultado(Symbol(),horario_entrada_local[i],"call","win#");
                    
                     ultimo_resultado="win";
                     SalvarSinal(horario_agora,"win");
                  }
                   
                  else if(Close[shift_expiracao]<Open[shift_abertura]){
                     if(message_loss!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                        sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                     }
                     if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                     remove_index=true;
                     if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"call","loss");
                     else GravarResultado(Symbol(),horario_entrada_local[i],"call","loss#");
                    
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
                  
                  else if(Close[shift_expiracao]==Open[shift_abertura]){
                     if(message_empate!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_empate+"E109️ ️E108 "+Symbol()+" "+horario_entrada_local[i]+" E107 "+up));
                        sendwhats(message_empate+"E109️ ️E108 "+Symbol()+" "+horario_entrada_local[i]+" E107 "+up);
                     }
                     remove_index=true;
                    
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");

                  }
               }//ok
            }
            
            else{ //ativar gale ==true
               if(Entrada==NA_MESMA_VELA){  
                  if(Close[shift_expiracao]>entrada[i] && horario_agora>=horario_expiracao[i]){
                     if(message_win!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                        sendwhats(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                     }
                     if(file_win!=EXAMPLE_PHOTO&&file_win!="") TelegramSendPhotoAsync(apikey, chatid, file_win, "");
                     remove_index=true;
                     if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"call","win");
                     else GravarResultado(Symbol(),horario_entrada_local[i],"call","win#");
                    
                     ultimo_resultado="win";
                     SalvarSinal(horario_agora,"win");
                  }
                  
                  else if(Close[shift_expiracao]==entrada[i] && horario_agora>=horario_expiracao[i]){
                     if(message_win!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_empate+"E109 E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                        sendwhats(message_empate+"E109 E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                     }
                     remove_index=true;
                    
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
                  
                  else if(Close[shift_expiracao_gale]>Open[shift_abertura_gale]){
                     if(horario_agora>=horario_expiracao_gale){
                        if(message_win_gale!="") {
                           TelegramSendText(apikey, chatid, WppConverterSymbol(message_win_gale+"E1021G E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                           sendwhats(message_win_gale+"E1021G E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                        }
                        if(file_win_gale!=EXAMPLE_PHOTO&&file_win_gale!="") TelegramSendPhotoAsync(apikey, chatid, file_win_gale, "");
                        remove_index=true;
                        if(assertividade_global==true || assertividade_restrita==true){
                           if(message_win_gale=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","lossg1");
                           else GravarResultado(Symbol(),horario_entrada_local[i],"call","wing1");
                        }else{
                           if(message_win_gale=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","lossg1#");
                           else GravarResultado(Symbol(),horario_entrada_local[i],"call","wing1#");
                        }
                     }
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
                  
                  else if(Close[shift_expiracao_gale]<Open[shift_abertura_gale]){
                     if(horario_agora>=horario_expiracao_gale){
                        if(ativar_win_gale2==false){
                           if(message_loss!="") {
                              TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                              sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                           }
                           if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                           remove_index=true;
                           if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"call","loss");
                        }else{
                           if(Close[shift_expiracao_gale2]>Open[shift_abertura_gale2] && horario_agora>=horario_expiracao_gale2){
                              if(message_win_gale2!="") {
                                 TelegramSendText(apikey, chatid, WppConverterSymbol(message_win_gale2+"E102G2 E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                                 sendwhats(message_win_gale2+"E102G2 E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                              }
                              if(file_win_gale2!=EXAMPLE_PHOTO&&file_win_gale2!="") TelegramSendPhotoAsync(apikey, chatid, file_win_gale2, "");
                              remove_index=true;
                              if(assertividade_global==true || assertividade_restrita==true){
                                 if(message_win_gale2=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","lossg2");
                                 else GravarResultado(Symbol(),horario_entrada_local[i],"call","wing2");
                              }else{
                                 if(message_win_gale2=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","lossg2#");
                                 else GravarResultado(Symbol(),horario_entrada_local[i],"call","wing2#");
                              }
                           }
                           
                           else if(Close[shift_expiracao_gale2]<Open[shift_abertura_gale2] && horario_agora>=horario_expiracao_gale2){
                              if(message_loss!="") {
                                 TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                                 sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                              }
                              if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                              remove_index=true;
                              if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"call","loss");
                              else GravarResultado(Symbol(),horario_entrada_local[i],"call","loss#");
                           }
                           
                           else if(Close[shift_expiracao_gale2]==Open[shift_abertura_gale2] && horario_agora>=horario_expiracao_gale2){
                              if(message_loss!="") {
                                 TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                                 sendwhats( message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                              }
                              if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                              remove_index=true;
                              if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"call","loss");
                              else GravarResultado(Symbol(),horario_entrada_local[i],"call","loss#");
                           }
                        }
                     }
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }//ok
                  
                  else if(Close[shift_expiracao_gale]==Open[shift_abertura_gale]){
                     if(horario_agora>=horario_expiracao_gale){
                        if(message_loss!="") {
                           TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                           sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                        }
                        if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                        remove_index=true;
                        if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"call","loss");
                        else GravarResultado(Symbol(),horario_entrada_local[i],"call","loss#");
                     }
                    
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
               }else{ //na proxima vela
                  if(Close[shift_expiracao]>Open[shift_abertura] && horario_agora>=horario_expiracao[i]){
                     if(message_win!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                        sendwhats(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                     }
                     if(file_win!=EXAMPLE_PHOTO&&file_win!="") TelegramSendPhotoAsync(apikey, chatid, file_win, "");
                     remove_index=true;
                     if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"call","win");
                     else GravarResultado(Symbol(),horario_entrada_local[i],"call","win#");
                    
                     ultimo_resultado="win";
                     SalvarSinal(horario_agora,"win");
                  }
                  
                  else if(Close[shift_expiracao]==Open[shift_abertura]){
                     if(message_empate!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_empate+"E109️ ️E108 "+Symbol()+" "+horario_entrada_local[i]+"  E107"+up));
                        sendwhats(message_empate+"E109️ ️E108 "+Symbol()+" "+horario_entrada_local[i]+" E107 "+up);
                     }
                     remove_index=true;
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
                  
                  else if(Close[shift_expiracao_gale]>Open[shift_abertura_gale]){
                     if(horario_agora>=horario_expiracao_gale){
                        if(message_win_gale!="") {
                           TelegramSendText(apikey, chatid, WppConverterSymbol(message_win_gale+"E1021G E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                           sendwhats(message_win_gale+"E1021G E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                        }
                        if(file_win_gale!=EXAMPLE_PHOTO&&file_win_gale!="") TelegramSendPhotoAsync(apikey, chatid, file_win_gale, "");
                        remove_index=true;
                        if(assertividade_global==true || assertividade_restrita==true){
                           if(message_win_gale=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","lossg1");
                           else GravarResultado(Symbol(),horario_entrada_local[i],"call","wing1");
                        }else{
                           if(message_win_gale=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","lossg1#");
                           else GravarResultado(Symbol(),horario_entrada_local[i],"call","wing1#");
                        }
                     }
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
                  
                  else if(Close[shift_expiracao_gale]<Open[shift_abertura_gale]){
                     if(horario_agora>=horario_expiracao_gale){
                        if(ativar_win_gale2==true){
                           if(Close[shift_expiracao_gale2]>Open[shift_abertura_gale2] && horario_agora>=horario_expiracao_gale2){
                              if(message_win_gale2!="") {
                                 TelegramSendText(apikey, chatid, WppConverterSymbol(message_win_gale2+"E1022G E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                                 sendwhats(message_win_gale2+"E1022G E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                              }
                              if(file_win_gale2!=EXAMPLE_PHOTO&&file_win_gale2!="") TelegramSendPhotoAsync(apikey, chatid, file_win_gale2, "");
                              remove_index=true;
                              if(assertividade_global==true || assertividade_restrita==true){
                                 if(message_win_gale2=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","lossg2");
                                 else GravarResultado(Symbol(),horario_entrada_local[i],"call","wing2");
                              }else{
                                 if(message_win_gale2=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","lossg2#");
                                 else GravarResultado(Symbol(),horario_entrada_local[i],"call","wing2#");
                              }
                           }
                           
                           else if(Close[shift_expiracao_gale2]<Open[shift_abertura_gale2] && horario_agora>=horario_expiracao_gale2){
                              if(message_loss!="") {
                                 TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                                 sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                              }
                              if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                              remove_index=true;
                              if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"call","loss");
                              else GravarResultado(Symbol(),horario_entrada_local[i],"call","loss#");
                           }
                           
                           else if(Close[shift_expiracao_gale2]==Open[shift_abertura_gale2] && horario_agora>=horario_expiracao_gale2){
                              if(message_loss!="") {
                                 TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                                 sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                              }
                              if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                              remove_index=true;
                              if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"call","loss");
                              else GravarResultado(Symbol(),horario_entrada_local[i],"call","loss#");
                           }
                        }else{
                           if(message_loss!="") {
                              TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                              sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                           }
                           if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                           remove_index=true;
                           if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"call","loss");
                           else GravarResultado(Symbol(),horario_entrada_local[i],"call","loss#");
                        }
                     }
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
                  
                  else if(Close[shift_expiracao_gale]==Open[shift_abertura_gale]){
                     if(horario_agora>=horario_expiracao_gale){
                        if(message_loss!="") {
                           TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up));
                           sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E107"+up);
                        }
                        if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                        remove_index=true;
                        if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"call","loss");
                        else GravarResultado(Symbol(),horario_entrada_local[i],"call","loss#");
                     }
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
               }
            } //fim ativar gale true - ok
            
         //ENTRADA PUT   
         }else if(tipo_entrada[i]==PUT){
             if(ativar_win_gale==false){
               if(Entrada==NA_MESMA_VELA){
                  if(Close[shift_expiracao]<entrada[i]){
                     if(message_win!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                        sendwhats(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                     }
                     if(file_win!=EXAMPLE_PHOTO&&file_win!="") TelegramSendPhotoAsync(apikey, chatid, file_win, "");
                     remove_index=true;
                     if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"put","win");
                     else GravarResultado(Symbol(),horario_entrada_local[i],"put","win#");
                    
                     ultimo_resultado="win";
                     SalvarSinal(horario_agora,"win");
                  }
                   
                  else if(Close[shift_expiracao]>entrada[i]){
                     if(message_loss!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                        sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                     }
                     if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                     remove_index=true;
                     if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"put","loss");
                     else GravarResultado(Symbol(),horario_entrada_local[i],"put","loss#");
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
                  
                  else if(Close[shift_expiracao]==entrada[i]){
                     if(message_empate!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_empate+"E109️ E108 "+Symbol()+" "+horario_entrada_local[i]+" E106 "+down));
                        sendwhats(message_empate+"E109️ E108 "+Symbol()+" "+horario_entrada_local[i]+" E106 "+down);
                     }
                     remove_index=true;
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
               }else{
                  if(Close[shift_expiracao]<Open[shift_abertura]){
                     if(message_win!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                        sendwhats(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                     }
                     if(file_win!=EXAMPLE_PHOTO&&file_win!="") TelegramSendPhotoAsync(apikey, chatid, file_win, "");
                     remove_index=true;
                     if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"put","win");
                     else GravarResultado(Symbol(),horario_entrada_local[i],"put","win#");
                    
                     ultimo_resultado="win";
                     SalvarSinal(horario_agora,"win");
                  }
                   
                  else if(Close[shift_expiracao]>Open[shift_abertura]){
                     if(message_loss!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                        sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                     }
                     if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                     remove_index=true;
                     if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"put","loss");
                     else GravarResultado(Symbol(),horario_entrada_local[i],"put","loss#");
                    
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
                  
                  else if(Close[shift_expiracao]==Open[shift_abertura]){
                     if(message_empate!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_empate+"E109️ E108 "+Symbol()+" "+horario_entrada_local[i]+" E106 "+down));
                        sendwhats(message_empate+"E109️ E108 "+Symbol()+" "+horario_entrada_local[i]+"E106 "+down);
                     }
                     remove_index=true;
                    
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
               }//ok
               
            }else{ //ativar gale ==true
               if(Entrada==NA_MESMA_VELA){  
                  if(Close[shift_expiracao]<entrada[i] && horario_agora>=horario_expiracao[i]){
                     if(message_win!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                        sendwhats(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                     }
                     if(file_win!=EXAMPLE_PHOTO&&file_win!="") TelegramSendPhotoAsync(apikey, chatid, file_win, "");
                     remove_index=true;
                     if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"put","win");
                     else GravarResultado(Symbol(),horario_entrada_local[i],"put","win#");
                    
                     ultimo_resultado="win";
                     SalvarSinal(horario_agora,"win");
                  }
                  
                  else if(Close[shift_expiracao]==entrada[i] && horario_agora>=horario_expiracao[i]){
                     if(message_empate!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_empate+"E109️ E108 "+Symbol()+" "+horario_entrada_local[i]+" E106 "+down));
                        sendwhats(message_empate+"E109️ E108 "+Symbol()+" "+horario_entrada_local[i]+"E106 "+down);
                     }
                     remove_index=true;
                    
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
                  
                  else if(Close[shift_expiracao_gale]<Open[shift_abertura_gale]){
                     if(horario_agora>=horario_expiracao_gale){
                        if(message_win_gale!="") {
                           TelegramSendText(apikey, chatid, WppConverterSymbol(message_win_gale+"E1021G E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                           sendwhats(message_win_gale+"E1021G E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                        }
                        if(file_win_gale!=EXAMPLE_PHOTO&&file_win_gale!="") TelegramSendPhotoAsync(apikey, chatid, file_win_gale, "");
                        remove_index=true;
                        if(assertividade_global==true || assertividade_restrita==true){
                           if(message_win_gale=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","loss");
                           else GravarResultado(Symbol(),horario_entrada_local[i],"call","win");
                        }else{
                           if(message_win_gale=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","loss#");
                           else GravarResultado(Symbol(),horario_entrada_local[i],"call","win#");
                        }
                     }
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
                  
                  else if(Close[shift_expiracao_gale]>Open[shift_abertura_gale]){
                     if(horario_agora>=horario_expiracao_gale){
                        if(ativar_win_gale2==true){
                           if(Close[shift_expiracao_gale2]<Open[shift_abertura_gale2] && horario_agora>=horario_expiracao_gale2){
                              if(message_win_gale2!="") {
                                 TelegramSendText(apikey, chatid, WppConverterSymbol(message_win_gale2+"E1022G E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                                 sendwhats(message_win_gale2+"E1022G E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                              }
                              if(file_win_gale2!=EXAMPLE_PHOTO&&file_win_gale2!="") TelegramSendPhotoAsync(apikey, chatid, file_win_gale2, "");
                              remove_index=true;
                              if(assertividade_global==true || assertividade_restrita==true){
                                 if(message_win_gale2=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","lossg2");
                                 else GravarResultado(Symbol(),horario_entrada_local[i],"call","wing2");
                              }else{
                                 if(message_win_gale2=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","lossg2#");
                                 else GravarResultado(Symbol(),horario_entrada_local[i],"call","wing2#");
                              }
                           }
                           
                           else if(Close[shift_expiracao_gale2]>Open[shift_abertura_gale2] && horario_agora>=horario_expiracao_gale2){
                              if(message_loss!="") {
                                 TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                                 sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                              }
                              if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                              remove_index=true;
                              if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"put","loss");
                              else GravarResultado(Symbol(),horario_entrada_local[i],"put","loss#");
                           }
                           
                           else if(Close[shift_expiracao_gale2]==Open[shift_abertura_gale2] && horario_agora>=horario_expiracao_gale2){
                              if(message_loss!="") {
                                 TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                                 sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                              }
                              if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                              remove_index=true;
                              if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"put","loss");
                              else GravarResultado(Symbol(),horario_entrada_local[i],"put","loss#");
                           }
                        }else{
                           if(message_loss!="") {
                              TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                              sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                           }
                           if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                           remove_index=true;
                           if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"put","loss");
                           else GravarResultado(Symbol(),horario_entrada_local[i],"put","loss#");
                        }
                     }
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }//ok
                  
                  else if(Close[shift_expiracao_gale]==Open[shift_abertura_gale]){
                     if(horario_agora>=horario_expiracao_gale){
                        if(message_loss!="") {
                           TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                           sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                        }
                        if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                        remove_index=true;
                        if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"put","loss");
                        else GravarResultado(Symbol(),horario_entrada_local[i],"put","loss#");
                     }
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
               }else{ //na proxima vela
                  if(Close[shift_expiracao]<Open[shift_abertura] && horario_agora>=horario_expiracao[i]){
                     if(message_win!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                        sendwhats(message_win+"E102 E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                     }
                     if(file_win!=EXAMPLE_PHOTO&&file_win!="") TelegramSendPhotoAsync(apikey, chatid, file_win, "");
                     remove_index=true;
                     if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"put","win");
                     else GravarResultado(Symbol(),horario_entrada_local[i],"put","win#");
                    
                     ultimo_resultado="win";
                     SalvarSinal(horario_agora,"win");
                  }
                  
                  else if(Close[shift_expiracao]==Open[shift_abertura] && horario_agora>=horario_expiracao[i]){
                     if(message_empate!="") {
                        TelegramSendText(apikey, chatid, WppConverterSymbol(message_empate+"E109️ E108 "+Symbol()+" "+horario_entrada_local[i]+" E106 "+down));
                        sendwhats(message_empate+"E109️ E108 "+Symbol()+" "+horario_entrada_local[i]+ " E106 "+down);
                     }
                     remove_index=true;
                    
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
                  
                  else if(Close[shift_expiracao_gale]<Open[shift_abertura_gale]){
                     if(horario_agora>=horario_expiracao_gale){
                        if(message_win_gale!="") {
                           TelegramSendText(apikey, chatid, WppConverterSymbol(message_win_gale+"E1021G E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                           sendwhats(message_win_gale+"E1021G E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                        }
                        if(file_win_gale!=EXAMPLE_PHOTO&&file_win_gale!="") TelegramSendPhotoAsync(apikey, chatid, file_win_gale, "");
                        remove_index=true;
                        if(assertividade_global==true || assertividade_restrita==true){
                           if(message_win_gale=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","lossg1");
                           else GravarResultado(Symbol(),horario_entrada_local[i],"call","wing1");
                        }else{
                           if(message_win_gale=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","lossg1#");
                           else GravarResultado(Symbol(),horario_entrada_local[i],"call","wing1#");
                        }
                     }
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
                  
                  else if(Close[shift_expiracao_gale]>Open[shift_abertura_gale]){
                     if(horario_agora>=horario_expiracao_gale2){
                        if(ativar_win_gale2==true){
                           if(Close[shift_expiracao_gale2]<Open[shift_abertura_gale2] && horario_agora>=horario_expiracao_gale2){
                              if(message_win_gale2!="") {
                                 TelegramSendText(apikey, chatid,  WppConverterSymbol(message_win_gale2+"E1022G E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                                 sendwhats(message_win_gale2+"E1022G E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                              }
                              if(file_win_gale2!=EXAMPLE_PHOTO&&file_win_gale2!="") TelegramSendPhotoAsync(apikey, chatid, file_win_gale2, "");
                              remove_index=true;
                              if(assertividade_global==true || assertividade_restrita==true){
                                 if(message_win_gale2=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","lossg2");
                                 else GravarResultado(Symbol(),horario_entrada_local[i],"call","wing2");
                              }else{
                                 if(message_win_gale2=="loss") GravarResultado(Symbol(),horario_entrada_local[i],"call","lossg2#");
                                 else GravarResultado(Symbol(),horario_entrada_local[i],"call","wing2#");
                              }
                           }
                           
                           else if(Close[shift_expiracao_gale2]>Open[shift_abertura_gale2] && horario_agora>=horario_expiracao_gale2){
                              if(message_loss!="") {
                                 TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                                 sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                              }
                              if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                              remove_index=true;
                              if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"put","loss");
                              else GravarResultado(Symbol(),horario_entrada_local[i],"put","loss#");
                           }
                           
                           else if(Close[shift_expiracao_gale2]==Open[shift_abertura_gale2] && horario_agora>=horario_expiracao_gale2){
                              if(message_loss!="") {
                                 TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                                 sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                              }
                              if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                              remove_index=true;
                              if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"put","loss");
                              else GravarResultado(Symbol(),horario_entrada_local[i],"put","loss#");
                           }
                        }else{
                           if(message_loss!="") {
                              TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                              sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                           }
                           if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                           remove_index=true;
                           if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"put","loss");
                           else GravarResultado(Symbol(),horario_entrada_local[i],"put","loss#");
                        }
                     }
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
                  
                  else if(Close[shift_expiracao_gale]==Open[shift_abertura_gale]){
                     if(horario_agora>=horario_expiracao_gale){
                        if(message_loss!="") {
                           TelegramSendText(apikey, chatid, WppConverterSymbol(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down));
                           sendwhats(message_loss+" E108 "+Symbol()+" "+horario_entrada_local[i]+" E106"+down);
                        }
                        if(file_loss!=EXAMPLE_PHOTO&&file_loss!="") TelegramSendPhotoAsync(apikey, chatid, file_loss, "");
                        remove_index=true;
                        if(assertividade_global==true || assertividade_restrita==true) GravarResultado(Symbol(),horario_entrada_local[i],"put","loss");
                        else GravarResultado(Symbol(),horario_entrada_local[i],"put","loss#");
                     }
                     
                     ultimo_resultado="loss";
                     SalvarSinal(horario_agora,"loss");
                  }
               }
         }//ok
      }
      
       if(remove_index==true){
           RemoveIndexFromArray(horario_entrada,i);
           RemoveIndexFromArray(horario_entrada_local,i);
           RemoveIndexFromArray(horario_expiracao,i);
           RemoveIndexFromArray(tipo_entrada,i);
           RemoveIndexFromArray(entrada,i); 
        }
      } 
    } 
}


template <typename T> void RemoveIndexFromArray(T& A[], int iPos){
   int iLast;
   for(iLast = ArraySize(A) - 1; iPos < iLast; ++iPos) 
      A[iPos] = A[iPos + 1];
   ArrayResize(A, iLast);
}

//+------------------------------------------------------------------+
//|   parabolic sar                                               |
//+------------------------------------------------------------------+
void SaveLastReverse(int reverse,bool dir,double step,double last_low,double last_high,double ep,double sar)
  {
   ExtLastReverse=reverse;
   if(ExtLastReverse<2)
      ExtLastReverse=2;
   ExtDirectionLong=dir;
   ExtLastStep=step;
   ExtLastLow=last_low;
   ExtLastHigh=last_high;
   ExtLastEP=ep;
   ExtLastSAR=sar;
  }
 
  
string GetHoraMinutos(datetime time_open, bool resul=false){
   string entry,hora,minuto;
   
   MqlDateTime time_open_str, time_local_str, time_entrada_str; //structs
   TimeToStruct(time_open,time_open_str); //extraindo o time de abertura do candle atual e armazenando em um struct
   TimeLocal(time_local_str); //extraindo o time local e armazenando em um struct
   string time_local_abertura_str = IntegerToString(time_local_str.year)+"."+IntegerToString(time_local_str.mon)+"."+IntegerToString(time_local_str.day)+" "+IntegerToString(time_local_str.hour)+":"+IntegerToString(time_open_str.min)+":"+IntegerToString(time_open_str.sec);
   datetime time_local_abertura_dt = StrToTime(time_local_abertura_str); //convertendo de volta pra datetime já com o horário local e o time de abertura do candle
  
   if(Entrada == NA_PROXIMA_VELA && resul==false) time_local_abertura_dt=time_local_abertura_dt+_Period*60;
      
   TimeToStruct(time_local_abertura_dt,time_entrada_str); //convertendo datetime em struct para extrair hora e minuto
   
   //--formatando horário
   if(time_entrada_str.hour >= 0 && time_entrada_str.hour <= 9) hora = "0"+IntegerToString(time_entrada_str.hour);
   else hora = IntegerToString(time_entrada_str.hour);
   
   if(time_entrada_str.min >= 0 && time_entrada_str.min <= 9) minuto = "0"+IntegerToString(time_entrada_str.min);
   else minuto = IntegerToString(time_entrada_str.min);
   
   entry = hora+":"+minuto;
   //--
   
   return entry;
}

string GetHoraMinutos2(datetime time_open, bool resul=false){
   string entry,hora,minuto;
   
   MqlDateTime time_open_str, time_local_str, time_entrada_str; //structs
   TimeToStruct(time_open,time_open_str); //extraindo o time de abertura do candle atual e armazenando em um struct
   TimeLocal(time_local_str); //extraindo o time local e armazenando em um struct
   string time_local_abertura_str;
   if(time_open_str.min!=0){
      time_local_abertura_str = IntegerToString(time_local_str.year)+"."+IntegerToString(time_local_str.mon)+"."+IntegerToString(time_local_str.day)+" "+IntegerToString(time_local_str.hour)+":"+IntegerToString(time_open_str.min)+":"+IntegerToString(time_open_str.sec);
   }else{
      datetime timer_local = TimeLocal()+tempo_expiracao*60;
      TimeToStruct(timer_local,time_local_str);
      time_local_abertura_str = IntegerToString(time_local_str.year)+"."+IntegerToString(time_local_str.mon)+"."+IntegerToString(time_local_str.day)+" "+IntegerToString(time_local_str.hour)+":00:"+IntegerToString(time_open_str.sec);      
   }
   
   datetime time_local_abertura_dt = StrToTime(time_local_abertura_str); //convertendo de volta pra datetime já com o horário local e o time de abertura do candle
  
   if(Entrada == NA_PROXIMA_VELA && resul==false) time_local_abertura_dt=time_local_abertura_dt+_Period*60;
      
   TimeToStruct(time_local_abertura_dt,time_entrada_str); //convertendo datetime em struct para extrair hora e minuto
   
   //--formatando horário
   if(time_entrada_str.hour >= 0 && time_entrada_str.hour <= 9) hora = "0"+IntegerToString(time_entrada_str.hour);
   else hora = IntegerToString(time_entrada_str.hour);
   
   if(time_entrada_str.min >= 0 && time_entrada_str.min <= 9) minuto = "0"+IntegerToString(time_entrada_str.min);
   else minuto = IntegerToString(time_entrada_str.min);
   
   entry = hora+":"+minuto;
   //--
   
   return entry;
}


void CalculateEMA(int rates_total,int prev_calculated,const double &price[])
  {
   int    i,limit;
   double SmoothFactor=2.0/(1.0+ma_period);
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=ma_period;
      ExtLineBuffer[0]=price[0];
      for(i=1; i<limit; i++)
         ExtLineBuffer[i]=price[i]*SmoothFactor+ExtLineBuffer[i-1]*(1.0-SmoothFactor);
     }
   else
      limit=prev_calculated-1;
//--- main loop
   for(i=limit; i<rates_total && !IsStopped(); i++)
      ExtLineBuffer[i]=price[i]*SmoothFactor+ExtLineBuffer[i-1]*(1.0-SmoothFactor);
//---
  }
  
  
//+------------------------------------------------------------------+
//|   simple moving average                                          |
//+------------------------------------------------------------------+
void CalculateSimpleMA(int rates_total,int prev_calculated,const double &price[])
  {
   int i,limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
   
     {
      limit=ma_period;
      //--- calculate first visible value
      double firstValue=0;
      for(i=0; i<limit; i++)
         firstValue+=price[i];
      firstValue/=ma_period;
      ExtLineBuffer[limit-1]=firstValue;
     }
   else
      limit=prev_calculated-1;
//--- main loop
   for(i=limit; i<rates_total && !IsStopped(); i++)
      ExtLineBuffer[i]=ExtLineBuffer[i-1]+(price[i]-price[i-ma_period])/ma_period;
//---
  }

//+------------------------------------------------------------------+
//|  linear weighted moving average                                  |
//+------------------------------------------------------------------+
void CalculateLWMA(int rates_total,int prev_calculated,const double &price[])
  {
   int        i,limit;
   static int weightsum;
   double     sum;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      weightsum=0;
      limit=ma_period;
      //--- calculate first visible value
      double firstValue=0;
      for(i=0;i<limit;i++)
        {
         int k=i+1;
         weightsum+=k;
         firstValue+=k*price[i];
        }
      firstValue/=(double)weightsum;
      ExtLineBuffer[limit-1]=firstValue;
     }
   else
      limit=prev_calculated-1;
//--- main loop
   for(i=limit; i<rates_total && !IsStopped(); i++)
     {
      sum=0;
      for(int j=0;j<ma_period;j++)
         sum+=(ma_period-j)*price[i-j];
      ExtLineBuffer[i]=sum/weightsum;
     }
//---
  }
//+------------------------------------------------------------------+
//|  smoothed moving average                                         |
//+------------------------------------------------------------------+
void CalculateSmoothedMA(int rates_total,int prev_calculated,const double &price[])
  {
   int i,limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=ma_period;
      double firstValue=0;
      for(i=0; i<limit; i++)
         firstValue+=price[i];
      firstValue/=ma_period;
      ExtLineBuffer[limit-1]=firstValue;
     }
   else
      limit=prev_calculated-1;
//--- main loop
   for(i=limit; i<rates_total && !IsStopped(); i++)
      ExtLineBuffer[i]=(ExtLineBuffer[i-1]*(ma_period-1)+price[i])/ma_period;
//---
  }
//+------------------------------------------------------------------+


void Statistics()
{
   info.Reset();
   infog1.Reset();
   infog2.Reset();
   
   for(int i=total_bars_shift; i>2; i--){
      //--- Statistics
      if(ganhou[i]!=EMPTY_VALUE){
         info.win++;
         info.count_win++;
         info.count_entries++;
         info.count_loss=0;
         if (info.count_win>info.consecutive_wins) info.consecutive_wins++;
      }
      else if(perdeu[i]!=EMPTY_VALUE){
         info.loss++;
         info.count_loss++;
         info.count_entries++;
         info.count_win=0;
         if(info.count_loss>info.consecutive_losses) info.consecutive_losses++;
         
         //--gale 1
         if(ganhou1[i-1]!=EMPTY_VALUE){
            infog1.win++;
            infog1.count_win++;
            infog1.count_entries++;
            infog1.count_loss=0;
            if (infog1.count_win>infog1.consecutive_wins) infog1.consecutive_wins++;
         }
         
         if(perdeu1[i-1]!=EMPTY_VALUE){
            infog1.loss++;
            infog1.count_loss++;
            infog1.count_entries++;
            infog1.count_win=0;
            if(infog1.count_loss>infog1.consecutive_losses) infog1.consecutive_losses++;
            
            //--gale 2
            if(ganhou2[i-2]!=EMPTY_VALUE){
               infog2.win++;
               infog2.count_win++;
               infog2.count_entries++;
               infog2.count_loss=0;
               if (infog2.count_win>infog2.consecutive_wins) infog2.consecutive_wins++;
            }
            
            if(perdeu2[i-2]!=EMPTY_VALUE){
               infog2.loss++;
               infog2.count_loss++;
               infog2.count_entries++;
               infog2.count_win=0;
               if(infog2.count_loss>infog2.consecutive_losses) infog2.consecutive_losses++;
            }
            
            if(empatou2[i-2]!=EMPTY_VALUE){
               infog2.draw++;
               infog2.count_entries++;
            }
         }
         
         if(empatou1[i-1]!=EMPTY_VALUE){
            infog1.draw++;
            infog1.count_entries++;
         }
      }
      else if(empatou[i]!=EMPTY_VALUE){
         info.draw++;
         info.count_entries++;
      }
   }
}

void Painel()
{
   color textColor = clrWhite;
   int Corner = 0;
   int font_size=8;
   int font_x=30; 
   int font_x2=25; //martingales
   string font_type="Time New Roman";
   double rate2=0, rate3=0;

   if(info.win != 0) rate = (info.win/(info.win+info.loss))*100;
   else rate = 0;
   
   if(infog1.win != 0) rate2 = (infog1.win/(infog1.win+infog1.loss))*100;
   else rate2 = 0;
   
   if(infog2.win != 0) rate3 = (infog2.win/(infog2.win+infog2.loss))*100;
   else rate3 = 0;
   
   string quant = "WIN: "+DoubleToString(info.win,0)+" | LOSS: "+DoubleToString(info.loss,0)+" | DRAW: "+DoubleToString(info.draw,0);
   CreateTextLable("wins",quant,font_size,font_type,textColor,Corner,font_x,70);
   
   string consecutive_wins = "CONSECUTIVE WINS: "+IntegerToString(info.consecutive_wins);
   CreateTextLable("consecutive_wins",consecutive_wins,font_size,font_type,textColor,Corner,font_x,90);
   
   string consecutive_losses = "CONSECUTIVE LOSSES: "+IntegerToString(info.consecutive_losses);
   CreateTextLable("consecutive_losses",consecutive_losses,font_size,font_type,textColor,Corner,font_x,110);
   
   string count_entries = "COUNT ENTRIES: "+IntegerToString(info.count_entries);
   CreateTextLable("count_entries",count_entries,font_size,font_type,textColor,Corner,font_x,50);
   
   string wins_rate = "WIN RATE: "+DoubleToString(rate,0)+"%";
   CreateTextLable("wins_rate",wins_rate,font_size,font_type,textColor,Corner,font_x,130);
   
   string bars_total = "COUNT BARS: "+IntegerToString(total_bars);
   CreateTextLable("quant",bars_total,font_size,font_type,textColor,Corner,font_x,30);
   
   string gales = "WIN G1: "+DoubleToString(rate2,0)+"% | WIN G2: "+DoubleToString(rate3,0)+"%";
   CreateTextLable("gales",gales,font_size,font_type,textColor,Corner,font_x,150);
}

void CreateTextLable
(string TextLableName, string Text, int TextSize, string FontName, color TextColor, int TextCorner, int X, int Y)
{
//---
   ObjectCreate(TextLableName, OBJ_LABEL, 0, 0, 0);
   ObjectSet(TextLableName, OBJPROP_CORNER, TextCorner);
   ObjectSet(TextLableName, OBJPROP_XDISTANCE, X);
   ObjectSet(TextLableName, OBJPROP_YDISTANCE, Y);
   ObjectSetText(TextLableName,Text,TextSize,FontName,TextColor);
   ObjectSetInteger(0,TextLableName,OBJPROP_HIDDEN,true);
}

void VerticalLine(int index, color clr)   
{
   ObjectDelete("start_count");
   string objName = "start_count";
  
   ObjectCreate(objName, OBJ_VLINE,0,Time[index],0);
   ObjectSet   (objName, OBJPROP_COLOR, clr);  
   ObjectSet   (objName, OBJPROP_BACK, true);
   ObjectSet   (objName, OBJPROP_STYLE, 2);
   ObjectSet   (objName, OBJPROP_WIDTH, 0); 
   ObjectSet   (objName, OBJPROP_SELECTABLE, false); 
   ObjectSet   (objName, OBJPROP_HIDDEN, true); 

}

//+------------------------------------------------------------------+
//| FiboMove function                                                |
//+------------------------------------------------------------------+
void FiboMove(string name,datetime &time[],double &price[],color clrLevels)
  {
// Move current Fibonacci
   ObjectMove(0,name,0,time[1],price[1]);    // Move first point of the fibo
   ObjectMove(0,name,1,time[0],price[0]);    // Move second point of the fibo
   FiboSetLevels(name,price,clrLevels);      // Set Levels of the fibo
   ChartRedraw();                            // Refresh chart
  }
//+------------------------------------------------------------------+ 
//| FiboDraw function                                                | 
//+------------------------------------------------------------------+ 
bool FiboDraw( const string      name,                   // object name 
              datetime          &time[],                // array time 
              double            &price[],               // array price 
              const color       clrFibo=clrRed,         // object color 
              const color       clrLevels=clrYellow)    // levels color 
  {

   long chart_ID=0;
   int sub_window=0;

   ResetLastError();

// Create Fibonacci Object
   if(!ObjectCreate(chart_ID,name,OBJ_FIBO,sub_window,time[1],price[1],time[0],price[0]))
     {
      Print(__FUNCTION__,
            ": failed to create \"Fibonacci Retracement\"! Error code = ",GetLastError());
      return(false);
     }
//--- set fibonacci object properties
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clrFibo);      // Set Fibo Color
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,STYLE_SOLID);  // Set Fibo Line Style
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,1);            // Set Fibo Line Width
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,false);         // Set Fibo To Front
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,false);   // Set Fibo Not Selectable
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,false);     // Set Fibo Not Selected
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,inpRay);   // Set Fibo Ray
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,false);       // Set Fibo Hidden in Object List
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);

// Set Fibonacci Levels
   FiboSetLevels(name,price,clrLevels);

//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| FiboSetLevels function                                           | 
//+------------------------------------------------------------------+ 
bool FiboSetLevels( const string      name,                   // object name 
                   double            &price[],               // array price 
                   const color       clrLevels=clrYellow)    // levels color 
  {

   long chart_ID=0;
   int sub_window=0;
   int N=ArraySize(levels);
   string str="";

   ResetLastError();

// Define number of levels
   ObjectSetInteger(chart_ID,name,OBJPROP_LEVELS,N);

// Set Levels Properties
   for(int i=0;i<N;i++)
     {
      ObjectSetDouble(chart_ID,name,OBJPROP_LEVELVALUE,i,levels[i]/100.0);    // Set Level Value
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELCOLOR,i,clrLevels);         // Set Level Color
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELSTYLE,i,STYLE_DOT);         // Set Level Line Style
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELWIDTH,i,1);                 // Set Level Line Width
     }

// Set Levels descriptions
   for(int i=0;i<N;i++)
     {
      str = DoubleToString(levels[i],1) + "% = ";                                            // Set % levels value
      str += DoubleToString(price[0]+(levels[i]/100.0)*(price[1]-price[0]),_Digits) + "  ";  // Set price level value
      levels_price[i]=price[0]+(levels[i]/100.0)*(price[1]-price[0]);
      ObjectSetString(chart_ID,name,OBJPROP_LEVELTEXT,i,str);                                // Set Description Text
     }
     
     shift_ref5_fibo=ObjectGetShiftByValue(inpName,levels_price[5]);
     shift_ref0_fibo=ObjectGetShiftByValue(inpName,levels_price[0]);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
//| GetZZ function                                                   |
//+------------------------------------------------------------------+
bool GetZZ(datetime &time[],double &price[])
  {
   bool ret= false;
   int leg = (int)MathMax(1,inpLeg);
   int cnt = 0;
   int idx = 0;
   double zz=0.0;

   for(int i=0; i<Bars-1; i++)
     {
      zz=iCustom(_Symbol,0,"ZigZag",inpDepth,inpDeviation,inpBackStep,0,i);
      if(zz<=0.0 || zz==EMPTY_VALUE || zz>1000000.0) continue;
      cnt++;
      if(cnt<leg) continue;
      time[idx]=Time[i];
      price[idx]=zz;
      idx++;
      if(idx>1) { ret=true; break; }
     }

   return ret;
  }
//+------------------------------------------------------------------+

void SalvarSinal(datetime time, string status_sinal){
   int fp = FileOpen(orders_extreme, FILE_WRITE|FILE_READ|FILE_TXT );
   string line = TimeToStr(time)+";"+status_sinal+";"+ChartID();
   FileWrite( fp, line );
   FileClose(fp);
}

string ultimo_resultado_qtd(){
   string result[];
   ushort u_sep = StringGetCharacter(";",0);
   
   string ultimo_resultado_global = fnReadFileValue();
   
   if(StringLen(ultimo_resultado_global)>0){
      int k = StringSplit(ultimo_resultado_global,u_sep,result);
      return result[3];
   }
   
   return "0";
}

string ultimo_resultado_global(){
   string result[];
   ushort u_sep = StringGetCharacter(";",0);
   
   string ultimo_resultado_global = fnReadFileValue();
   
   if(StringLen(ultimo_resultado_global)>0){
      int k = StringSplit(ultimo_resultado_global,u_sep,result);
      if(result[1]=="loss") return "loss";
      else if(result[1]=="nda"||result[1]=="ndas") return "nda";
   }
   
   return "win";
}

string get_chart_id(){
   string result[];
   ushort u_sep = StringGetCharacter(";",0);
   
   string ultimo_resultado_global = fnReadFileValue();
   
   if(StringLen(ultimo_resultado_global)>0){
      int k = StringSplit(ultimo_resultado_global,u_sep,result);
      return result[2];
   }
   
   return "";
}

datetime ultimo_resultado_global_time(){
   string result[];
   ushort u_sep = StringGetCharacter(";",0);
   
   string ultimo_resultado_global = fnReadFileValue();
   
   if(StringLen(ultimo_resultado_global)>0){
      int k = StringSplit(ultimo_resultado_global,u_sep,result);
      return StrToTime(result[0]);
   }
   
   return iTime(NULL,0,1);
}

string fnReadFileValue()
{
   int    str_size;
   string str="";
   string result[];
   ushort u_sep = StringGetCharacter(";",0);
   
   ResetLastError();
   int file_handle=FileOpen(orders_extreme,FILE_READ|FILE_TXT);
   
   //--- read data from the file
   //--- find out how many symbols are used for writing the time
   str_size=FileReadInteger(file_handle,INT_VALUE);
   //--- read the string
   str=FileReadString(file_handle,str_size);    

   FileClose(file_handle);
   
   if(StringLen(str)!=0){
      StringSplit(str,u_sep,result);
      if(StringLen(ChartSymbol(result[2]))==0){
         str=StringConcatenate(result[0],";loss;",result[2]);
      }
      
      else if(StringLen(ChartSymbol(result[2]))>0 && (result[0]=="nda"||result[0]=="ndas") &&
      ((PossibleUpBf[1]==EMPTY_VALUE && Up[0]==EMPTY_VALUE && PossibleDwBf[1]==EMPTY_VALUE && Dw[0]==EMPTY_VALUE) || 
      (PossibleUpBf[0]==EMPTY_VALUE && Up[0]==EMPTY_VALUE && PossibleDwBf[0]==EMPTY_VALUE && Dw[0]==EMPTY_VALUE)))
      {
         str=StringConcatenate(result[0],";loss;",result[2]);
      }
   }
   
   return str;
}

void GravarResultado(string par, string horario, string operacao, string resultado){
   bool registrar=true;
   string registro = StringConcatenate(par,";",horario,";",operacao,";",resultado,"\n");
   int file_handle=FileOpen(arquivo_estatisticas,FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_WRITE|FILE_TXT);
   
   if(block_registros_duplicados==true){
      int    str_size;
      string str;
      ushort u_sep = StringGetCharacter(";",0);
      
      while(!FileIsEnding(file_handle)){
         string result[];
         str_size=FileReadInteger(file_handle,INT_VALUE);
         str=FileReadString(file_handle,str_size);
         StringSplit(str,u_sep,result);
         
         if(result[0]==par && result[1]==horario && result[2]==operacao && result[3]==resultado)
            registrar=false;
      }
   }
   
   if(registrar==true){
      FileSeek(file_handle,0,SEEK_END);
      FileWriteString(file_handle,registro);
   }
   
   FileClose(file_handle);
}

int CountSeconds(){
    int m, s;
    m = Time[0] + Period()*60 - CurTime();
    s = m % 60;
    m = (m - m % 60) / 60;
    int segundos = m*60+s;
    return segundos;
}

void AtualizarEstatisticas(estatisticas &estatistica, string arquivo){
   int file_handle=FileOpen(arquivo,FILE_READ|FILE_SHARE_READ|FILE_TXT);
   if(file_handle!=INVALID_HANDLE){
      int    str_size;
      string str;
      ushort u_sep = StringGetCharacter(";",0);
      
      while(!FileIsEnding(file_handle)){
         string result[];
         str_size=FileReadInteger(file_handle,INT_VALUE);
         str=FileReadString(file_handle,str_size);
         StringSplit(str,u_sep,result);
         
         if(result[3]=="win"||result[3]=="wing1"||result[3]=="wing2")
            estatistica.win_global++;
         else if(result[3]=="loss"||result[3]=="lossg1"||result[3]=="lossg2")
            estatistica.loss_global++;
         if(result[0]==Symbol() && (result[3]=="win"||result[3]=="wing1"||result[3]=="wing2"))
            estatistica.win_restrito++;
         else if(result[0]==Symbol() && (result[3]=="loss"||result[3]=="lossg1"||result[3]=="lossg2"))
            estatistica.loss_restrito++;
      }
      
      estatistica.assertividade_global_valor = estatistica.win_global>0 ? DoubleToString(((double)estatistica.win_global/((double)estatistica.win_global+(double)estatistica.loss_global))*100,0)+"%" : "0%";
      estatistica.assertividade_restrita_valor = estatistica.win_restrito>0 ? DoubleToString(((double)estatistica.win_restrito/((double)estatistica.win_restrito+(double)estatistica.loss_restrito)*100),0)+"%" : "0%";
   }
   
   FileClose(file_handle);
}

string filtro_contar_cores(int pos){
    int green=0, red=0;
    for(int i=pos; i<=pos+qtd_candles_map_cores;i++){
      if(Close[i]>Open[i]) green++;
      else if(Close[i]<Open[i]) red++;
    }
    
    return(IntegerToString(green)+";"+IntegerToString(red));
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if(id==CHARTEVENT_KEYDOWN){
      if((int)lparam==KEY_DELETE){
         Alert("As estatísticas foram resetadas.");
         FileDelete(arquivo_estatisticas);
      }
    }
   
}

datetime Offset(datetime expiracao_inicial, datetime expiracao_final){
   MqlDateTime expiracao_convert, local_convert;
   TimeToStruct(expiracao_inicial,expiracao_convert);
   TimeLocal(local_convert);
   
   string expiracao_inicial_convert_str = expiracao_convert.year+"."+expiracao_convert.mon+"."+expiracao_convert.day+" "+expiracao_convert.hour+":"+local_convert.min+":"+TimeSeconds(TimeGMT());
   datetime expiracao_inicial_convert_dt = StringToTime(expiracao_inicial_convert_str);
   
   return expiracao_inicial_convert_dt;
}

bool DonForex(double price, double open, double close, bool trendUp, bool Rompimento=false){
   for(int i=0; i<ObjectsTotal(); i++){
      if(ObjectType(ObjectName(i))==OBJ_RECTANGLE && StringFind(ObjectName(i),"PERFZONES_SRZ",0)!=-1){
         double value_min = ObjectGetDouble(0, ObjectName(i), OBJPROP_PRICE1);
         double value_max = ObjectGetDouble(0, ObjectName(i), OBJPROP_PRICE2);
         string rectangle_size = DoubleToStr((value_max-value_min)/Point,0);
         
         if(trendUp && !Rompimento && price < value_max && price > value_min && open > value_max && close < open && StrToInteger(rectangle_size)>=min_rectangle_size) return true;
         else if(!trendUp && !Rompimento && price > value_min && price < value_max && open < value_min && close > open && StrToInteger(rectangle_size)>=min_rectangle_size) return true;
         
         else if(trendUp && price < value_max && price < value_min && open > value_max && close < open && StrToInteger(rectangle_size)>=min_rectangle_size) return true;
         else if(!trendUp && price > value_min && price > value_max && open < value_min && close > open && StrToInteger(rectangle_size)>=min_rectangle_size) return true;
         
      }
   }
   
   return false;
}

bool OsciladorBef(int indice, bool trendUp){
   int count=0;
  
   for(int i=1; i<=qtd_candles_oscilador; i++){
      
      double oscilador_bef=iCustom(NULL,0,combiner_filename_oscilador,combiner_buff_oscilador,indice+indice_buffers_3+i);
      
      if(oscilador_bef < combiner_nivel_sobrecompra_oscilador && !trendUp){
         count++;
      }
      else if(oscilador_bef > combiner_nivel_sobrevenda_oscilador && trendUp){
         count++;
      }
   }
   if(count==qtd_candles_oscilador){
      return true;
   }
   return false;
}

int CountWinsAndLosses(string filename)
{
    int fileHandle = FileOpen(filename, FILE_READ|FILE_SHARE_READ|FILE_TXT);
    
    if (fileHandle == INVALID_HANDLE)
    {
        //Print("Erro ao abrir o arquivo: ", filename);
        return 1;
    }

    // Inicializa as contagens
    stop_win_atual = 0;
    stop_loss_atual = 0;
    
    // Lê o arquivo linha por linha
    while (!FileIsEnding(fileHandle))
    {
        string line = FileReadString(fileHandle);
        if (StringLen(line) > 0)
        {
            // Divide a linha em partes usando o delimitador ";"
            string parts[];
            int partsCount = StringSplit(line, ';', parts);
            
            // Verifica se a última parte da linha é "win" ou "loss"
            if (partsCount > 3)
            {
                string result = parts[3];
                if (StringCompare(result, "win") == 0)
                {
                    stop_win_atual++;
                }
                else if (StringCompare(result, "loss") == 0)
                {
                    stop_loss_atual++;
                }
            }
        }
    }
    
    // Fecha o arquivo
    FileClose(fileHandle);
    return 1;
}

void SendMessageTelegram(){
   static int count = 0;
   
   //---------Manhã
   //Print(sessao_manha+" "+horario_inicio_manha+" "+horario_fim_manha+" "+TimeLocal()+" "+first_message_telegram_manha);
   if(sessao_manha && TimeLocal()>=horario_inicio_manha&&TimeLocal()<horario_fim_manha){
      if(!first_message_telegram_manha){
         stop_win_atual = 0;
         stop_loss_atual = 0;
         
         TelegramSendText(apikey, chatid, WppConverterSymbol(MSG_INICIO_MANHA));
         sendwhats(MSG_INICIO_MANHA);
         Print("=> "+MSG_INICIO_MANHA);
          
         first_message_telegram_manha=true;
      }
      end_message_telegram_manha=false;
   }
   
   else if(sessao_manha && (TimeLocal()>horario_fim_manha  || (ativar_stop_win && stop_win_atual >= qtd_stop_win) || (ativar_stop_loss && stop_loss_atual >= qtd_stop_loss)) && FileIsExist(arquivo_estatisticas)){
      if(!end_message_telegram_manha){
         TelegramSendText(apikey, chatid, WppConverterSymbol(MSG_FIM_MANHA));
         Print("=> "+MSG_FIM_MANHA);
         sendwhats(MSG_FIM_MANHA);
               
         //take
         if(stop_win_atual >= qtd_stop_win && ativar_stop_win
            ){
               TelegramSendText(apikey, chatid, WppConverterSymbol(TAKE_ATINGIDO_MANHA));
               Print("=> "+TAKE_ATINGIDO_MANHA);
               sendwhats(TAKE_ATINGIDO_MANHA);
            }
         
         //stop
         else if(stop_loss_atual >= qtd_stop_loss && ativar_stop_loss
            ){
               TelegramSendText(apikey, chatid, WppConverterSymbol(STOP_ATINGIDO_MANHA));
               Print("=> "+STOP_ATINGIDO_MANHA);
               sendwhats(STOP_ATINGIDO_MANHA);
            }
         
         estatisticas estatistica;
         estatistica.Reset();
         AtualizarEstatisticas(estatistica, arquivo_estatisticas);
   
         string resultado = msg_personalizada_ao_vivo+"E110E110";
         resultado+=ExibirResultadoParcialAoVivo(arquivo_estatisticas);
         resultado+="E110E110Win: "+estatistica.win_global+" | Loss: "+estatistica.loss_global+" ("+estatistica.assertividade_global_valor+")E110";
         TelegramSendText(apikey,chatid,WppConverterSymbol(resultado));
         sendwhats(resultado);
         if(ativar_msg_geral){
            CopiarArquivo(arquivo_estatisticas, arquivo_estatisticas2);
            count++;
         }
         FileDelete(arquivo_estatisticas);
         
         end_message_telegram_manha=true;
      }
      
      first_message_telegram_manha=false;
   }
   
   //---------Tarde
   if(sessao_tarde && TimeLocal()>=horario_inicio_tarde&&TimeLocal()<horario_fim_tarde){
      if(!first_message_telegram_tarde){
         stop_win_atual = 0;
         stop_loss_atual = 0;
         
         TelegramSendText(apikey, chatid, WppConverterSymbol(MSG_INICIO_TARDE));
         Print("=> "+MSG_INICIO_TARDE);
         sendwhats(MSG_INICIO_TARDE);
         
         first_message_telegram_tarde=true;
      }
      end_message_telegram_tarde=false;
   }
   
   else if(sessao_tarde && (TimeLocal()>horario_fim_tarde || (ativar_stop_win && stop_win_atual >= qtd_stop_win) || (ativar_stop_loss && stop_loss_atual >= qtd_stop_loss)) && FileIsExist(arquivo_estatisticas)){
      if(!end_message_telegram_tarde){
         TelegramSendText(apikey, chatid, WppConverterSymbol(MSG_FIM_TARDE));
         Print("=> "+MSG_FIM_TARDE);
         sendwhats(MSG_FIM_TARDE);
          
         //take
         if(stop_win_atual >= qtd_stop_win && ativar_stop_win
            ){
               TelegramSendText(apikey, chatid, WppConverterSymbol(TAKE_ATINGIDO_TARDE));
               Print("=> "+TAKE_ATINGIDO_TARDE);
               sendwhats(TAKE_ATINGIDO_TARDE);
            }
         
         //stop
         else if(stop_loss_atual >= qtd_stop_loss && ativar_stop_loss
            ){
               TelegramSendText(apikey, chatid, WppConverterSymbol(STOP_ATINGIDO_TARDE));
               Print("=> "+STOP_ATINGIDO_TARDE);
               sendwhats(STOP_ATINGIDO_TARDE);
            }
         
         estatisticas estatistica;
         estatistica.Reset();
         AtualizarEstatisticas(estatistica, arquivo_estatisticas);
         
         string resultado = msg_personalizada_ao_vivo+"E110E110";
         resultado+=ExibirResultadoParcialAoVivo(arquivo_estatisticas);
         resultado+="E110E110Win: "+estatistica.win_global+" | Loss: "+estatistica.loss_global+" ("+estatistica.assertividade_global_valor+")E110";
         TelegramSendText(apikey,chatid,WppConverterSymbol(resultado));
         sendwhats(resultado);
         if(ativar_msg_geral){
            CopiarArquivo(arquivo_estatisticas, arquivo_estatisticas2);
            count++;
         }
         FileDelete(arquivo_estatisticas);
         
         end_message_telegram_tarde=true;
      }
      
      first_message_telegram_tarde=false;
   }
   
   //---------Noite
   if(sessao_noite && TimeLocal()>=horario_inicio_noite&&TimeLocal()<horario_fim_noite){
      if(!first_message_telegram_noite){
         stop_win_atual = 0;
         stop_loss_atual = 0;
                 
         TelegramSendText(apikey, chatid, WppConverterSymbol(MSG_INICIO_NOITE));
         Print("=> "+MSG_INICIO_NOITE);
         sendwhats(MSG_INICIO_NOITE);
         
         first_message_telegram_noite=true;
      }
      end_message_telegram_noite=false;
   }
   
   else if(sessao_noite && (TimeLocal()>horario_fim_noite || (ativar_stop_win && stop_win_atual >= qtd_stop_win) || (ativar_stop_loss && stop_loss_atual >= qtd_stop_loss)) && FileIsExist(arquivo_estatisticas)){
      if(!end_message_telegram_noite){
            TelegramSendText(apikey, chatid, WppConverterSymbol(MSG_FIM_NOITE));
            Print("=> "+MSG_FIM_NOITE);
            sendwhats(MSG_FIM_NOITE);
          
         //take
         if(stop_win_atual >= qtd_stop_win && ativar_stop_win
            ){
               TelegramSendText(apikey, chatid, WppConverterSymbol(TAKE_ATINGIDO_NOITE));
               Print("=> "+TAKE_ATINGIDO_NOITE);
               sendwhats(TAKE_ATINGIDO_NOITE);
            }
         
         //stop
         else if(stop_loss_atual >= qtd_stop_loss && ativar_stop_loss
            ){
               TelegramSendText(apikey, chatid, WppConverterSymbol(STOP_ATINGIDO_NOITE));
               Print("=> "+STOP_ATINGIDO_NOITE);
               sendwhats(STOP_ATINGIDO_NOITE);
            }
         
         estatisticas estatistica;
         estatistica.Reset();
         AtualizarEstatisticas(estatistica, arquivo_estatisticas);
         
         string resultado = msg_personalizada_ao_vivo+"E110E110";
         resultado+=ExibirResultadoParcialAoVivo(arquivo_estatisticas);
         resultado+="E110E110Win: "+estatistica.win_global+" | Loss: "+estatistica.loss_global+" ("+estatistica.assertividade_global_valor+")E110";
         TelegramSendText(apikey,chatid,WppConverterSymbol(resultado));
         sendwhats(resultado);
         if(ativar_msg_geral){
            CopiarArquivo(arquivo_estatisticas, arquivo_estatisticas2);
            count++;
         }
         FileDelete(arquivo_estatisticas);
         
         end_message_telegram_noite=true;
      }
      
      first_message_telegram_noite=false;
   }
   
   int sum = int(sessao_manha) + int(sessao_tarde) + int(sessao_noite);
   if(ativar_msg_geral && count == sum && FileIsExist(arquivo_estatisticas2)){
      estatisticas estatistica;
      estatistica.Reset();
      AtualizarEstatisticas(estatistica, arquivo_estatisticas2);
      
      string resultado = msg_personalizada_ao_vivo_geral+"E110E110";
      resultado+=ExibirResultadoParcialAoVivo(arquivo_estatisticas2);
      resultado+="E110E110Win: "+estatistica.win_global+" | Loss: "+estatistica.loss_global+" ("+estatistica.assertividade_global_valor+")E110";
      TelegramSendText(apikey,chatid,WppConverterSymbol(resultado));
      sendwhats(resultado);
      FileDelete(arquivo_estatisticas2);
      count=0;
   }
}

// Função para copiar conteúdo de um arquivo para outro sem apagar o que já está no arquivo de destino
void CopiarArquivo(string arquivoOrigem, string arquivoDestino)
{
   // Abrir o arquivo de origem para leitura
   int arquivoOrigemHandle = FileOpen(arquivoOrigem, FILE_READ | FILE_TXT);
   if (arquivoOrigemHandle == INVALID_HANDLE)
   {
      Print("Erro ao abrir o arquivo de origem: ", arquivoOrigem);
      return;
   }
   
   // Abrir o arquivo de destino para append (adicionar ao final, sem apagar o conteúdo existente)
   int arquivoDestinoHandle = FileOpen(arquivoDestino, FILE_WRITE | FILE_TXT);
   if (arquivoDestinoHandle == INVALID_HANDLE)
   {
      Print("Erro ao abrir o arquivo de destino: ", arquivoDestino);
      FileClose(arquivoOrigemHandle);
      return;
   }
   
   // Ler o conteúdo do arquivo de origem e adicionar ao arquivo de destino
   string linha;
   while (!FileIsEnding(arquivoOrigemHandle))
   {
      linha = FileReadString(arquivoOrigemHandle);
      FileSeek(arquivoDestinoHandle,0,SEEK_END);
      FileWriteString(arquivoDestinoHandle, linha + "\n"); // Adiciona a linha ao arquivo de destino com uma nova linha
   }
   
   // Fechar os arquivos
   FileClose(arquivoOrigemHandle);
   FileClose(arquivoDestinoHandle);
}

string ExibirResultadoParcialAoVivo(string arquivo){
   ushort u_sep = StringGetCharacter(";",0);
   int str_size;
   string str="",str_tratada="";
   
   int file_handle=FileOpen(arquivo,FILE_READ|FILE_SHARE_READ|FILE_TXT);
   while(!FileIsEnding(file_handle)){
      str_size=FileReadInteger(file_handle,INT_VALUE);
      str=FileReadString(file_handle,str_size);  
    
      if(str!=""){
         string result[];
         StringSplit(str,u_sep,result);
         //0-symbol,1-hour,2-operation,3-result
         
         if(result[2]=="put") result[2] = "E106️";
         else result[2] = "E107️";
         
         if(result[3]=="win" || result[3]=="win#")
            str_tratada+="E102 E108 "+result[0]+" "+result[1]+" "+result[2]+"E110";
         if(result[3]=="wing1" || result[3]=="wing1#")
            str_tratada+="E1021G E108 "+result[0]+" "+result[1]+" "+result[2]+"E110";
         if(result[3]=="wing2" || result[3]=="wing2#")
            str_tratada+="E1022G E108 "+result[0]+" "+result[1]+" "+result[2]+"E110";
         if(result[3]=="loss" || result[3]=="loss#")
            str_tratada+="loss E108 "+result[0]+" "+result[1]+" "+result[2]+"E110";
         if(result[3]=="lossg1" || result[3]=="lossg1#")
            str_tratada+="lossE102G1 E108 "+result[0]+" "+result[1]+" "+result[2]+"E110";
         if(result[3]=="lossg2" || result[3]=="lossg2#")
            str_tratada+="lossE102G2 E108 "+result[0]+" "+result[1]+" "+result[2]+"E110";
         
      }
   }
   
   FileClose(file_handle);
   
   return str_tratada;
}
