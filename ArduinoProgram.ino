 #include <PID_v1.h>

#include <TimerOne.h>
#define MAX_ARRAY_SIZE 10
int t0;
int g=0;

/*case value 
 0 - pwm_value
 1 - mode auto/manual
 2 - fan_pwm_val[0]
 3 - bulb pwm_val[0]
 4 - fan_pwm_val[1]
 5 - bulb_pwm_val[1]
 6 - fan_pwm_val[2]
 7 - bulb_pwm_val[2]
 8 - referinta
 
 */
int fan_pwm_val[3]={0},bulb_pwm_val[3]={0,0,0};
char  buf_send[60];
//---------------param PID------------------------------/
float temp[3],temp_f[3],temp_med_init;
double input[3];
double ref[3]={0};
double uk[3]={0};
double kp[3]={8.574,8.574,8.574},ki[3]={0.0434,0.0434,0.0434},kd[3]={0};
//--------------------
double alpha=0.9;
int bulbPin[3]={3,5,7},fanPin[3]={2,4,6},tempPin[3]={0,1,2};
//---------Param  identificare date + parsare ---------------/ 
unsigned long  rec_com[MAX_ARRAY_SIZE]={0};
int index=0;
char indata[30];
int flag=0;
int flag_sample=0;
//-------------param mode------------------------------------/

int mode=0,prev_mode=0;
int manual_off=0;
PID myPID (&input[0], &uk[0], &ref[0], kp[0], ki[0],kd[0], DIRECT);
PID myPID_2(&input[1], &uk[1], &ref[1], kp[1], ki[1],kd[1], DIRECT);
PID myPID_3(&input[2], &uk[2], &ref[2], kp[2], ki[2],kd[2], DIRECT);
int enable_auto=0;

void setup()
{
     pinMode(bulbPin[0],OUTPUT);
     pinMode(bulbPin[1],OUTPUT);
     pinMode(bulbPin[2],OUTPUT);
     pinMode(fanPin[0],OUTPUT);
     pinMode(fanPin[1],OUTPUT);
     pinMode(fanPin[2],OUTPUT);
     pinMode(tempPin[0],INPUT);
     pinMode(tempPin[1],INPUT);
     pinMode(tempPin[2],INPUT);
  Serial.begin(9600);
     temp_med_init+=(500.0*analogRead(tempPin[0]))/1023;
     temp_med_init+=(500.0*analogRead(tempPin[0]))/1023;
     temp_med_init+=(500.0*analogRead(tempPin[0]))/1023;
     temp_med_init+=(500.0*analogRead(tempPin[0]))/1023;
     temp_med_init+=(500.0*analogRead(tempPin[0]))/1023;
     temp_med_init+=(500.0*analogRead(tempPin[0]))/1023;
     temp_med_init+=(500.0*analogRead(tempPin[0]))/1023;
     temp_f[0]=temp_med_init/7;
     temp_f[1]=temp_f[0];
     temp_f[2]=temp_f[0];
     ref[0]=temp_f[0];
     ref[1]=temp_f[0];
     ref[2]=temp_f[0];
  Timer1.initialize(1000000);
  Timer1.attachInterrupt(readsensor);
     myPID.SetMode(AUTOMATIC);
     myPID.SetSampleTime(1000);
    myPID_2.SetMode(AUTOMATIC);
     myPID_2.SetSampleTime(1000);
     myPID_3.SetMode(AUTOMATIC);
     myPID_3.SetSampleTime(1000);
}
void loop()
{
  int i;
  receive_data(MAX_ARRAY_SIZE);
  iddata(MAX_ARRAY_SIZE);

 if(mode==0)
 {
    for(i=0;i<3;i++)
      {
        analogWrite(fanPin[i],fan_pwm_val[i]);
        analogWrite(bulbPin[i],bulb_pwm_val[i]);
      }
 }

}
   
  
  

void send_data()
{
  int k;
  int t[3],f[3],b[3];
 int ref_[3],uk_[3], kp_,ki_,kd_;
   for(k=0;k<3;k++)
   {
     t[k]=temp_f[k]*100;
     f[k]=(fan_pwm_val[k]+1)*100/255;
     b[k]=(bulb_pwm_val[k]+1)*100/255;
   }
    ref_[0]=(int)ref[0];
    ref_[1]=(int)ref[1];
    ref_[2]=(int)ref[2];
 
    uk_[0]=(int)uk[0]*100/255;
    uk_[1]=(int)uk[1]*100/255;
     uk_[2]=(int)uk[2]*100/255;
    
    sprintf(buf_send,"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",//%d,%d,%d,%d,%d",
     t[0],f[0],b[0],t[1],f[1],b[1],t[2],f[2],b[2],ref_[0],uk_[0],ref_[1],uk_[1],ref_[2],uk_[2],g,mode);
     Serial.print(buf_send);
 }
 
 
void readsensor()
{
  g=g+1;
  int i;
  for(i=0;i<3;i++)
  {
  temp[i]=(500.0*analogRead(tempPin[i]))/1023;
  temp_f[i]=temp_f[i]*alpha+temp[i]*(1-alpha);
  }
  input[0]=temp_f[0];
  input[1]=temp_f[1];
  input[2]=temp_f[2];
  if(mode==1)
  {
       if(enable_auto==1)
        {
          
           myPID.Compute();
           myPID_2.Compute();
           myPID_3.Compute();
         analogWrite(bulbPin[0],uk[0]);
        analogWrite(bulbPin[1],uk[1]);
         analogWrite(bulbPin[2],uk[2]);
        }
  }
  send_data();
  
}

void receive_data(int maxSize)
{
  int nr=0;
  char *token;
  char inChar;
  int i=0;
  while(Serial.available()>0)
  {
    inChar=Serial.read();
    if(inChar!='\n')
    {
      indata[index]=inChar;
      index++;
      indata[index]='\0';
    }
    if(inChar=='\n')
    {
      index=0;
      token=strtok(indata,",");
      while(token!=NULL)
      {
        sscanf(token,"%d",&rec_com[i]);
        token = strtok(NULL, ",");
        i++;
        if (i == maxSize) 
        {
          break;
        }
      }
    }
  }

}
void iddata(int maxSize)
{
   int enable=0;
  int instant=0;
  int k;
  int value=0;
  value=rec_com[0];
  switch(value)
  {
  case 0:
 for(k=0;k<3;k++)
  {
   fan_pwm_val[k]=0;
   bulb_pwm_val[k]=0;
  }
    break;
  case 1:
  mode=rec_com[1];
  if(mode==1 && enable_auto==0)
  {
    for(k=0;k<3;k++)
    {
    fan_pwm_val[k]=0;
    bulb_pwm_val[k]=0;
    analogWrite(bulbPin[k],fan_pwm_val[k]);
    analogWrite(fanPin[k],bulb_pwm_val[k]);
    enable_auto=1;
    }
  }
  else if(mode==0)
  enable_auto=0;
  break;
  case 2:
    fan_pwm_val[0]=rec_com[1]*255/100; break;
   case 3:
     bulb_pwm_val[0]=rec_com[1]*255/100; break;
    case 4:
     fan_pwm_val[1]=rec_com[1]*255/100; break;
    case 5:
     bulb_pwm_val[1]=rec_com[1]*255/100; break;
     case 6:
     fan_pwm_val[2]=rec_com[1]*255/100; break;
    case 7:
     bulb_pwm_val[2]=rec_com[1]*255/100; break;
     case 8:
      ref[0]=rec_com[1];break;
     case 9:
      ref[1]=rec_com[1];
       break;
      case 10:
      ref[2]=rec_com[1];
      break;
  default:
    break;
  }
}



