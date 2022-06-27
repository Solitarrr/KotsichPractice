// ===============================
// globals
// ===============================

// ----- arduino pinouts
#define Trig1 4                       //вывод датчика A "Trig"
#define Echo1 5                       //вывод датчика A "Echo"

#define Trig2 6                       //вывод датчика B "Trig"
#define Echo2 7                       //вывод датчика B "Echo"

// ----- results
float Baseline = 100;                  //расстояние между датчиками (cm)
float Distance1;                      //от активного отправителя (cm)
float Distance2;                      //от пассивного приемника (cm)

// ----- task scheduler
int TaskTimer1 = 0;                   //task 1 (see ISR(TIMER2_COMPA_vect)
bool TaskFlag1 = false;               //flag 1


// ===============================
// setup
// ===============================
void setup() {

  // ----- configure serial port
  Serial.begin(115200);

  // ----- configure arduino pinouts
  pinMode(Echo1, INPUT);              //сделать входы эхо-выводов
  pinMode(Echo2, INPUT);
  pinMode(Trig1, OUTPUT);             //сделать ВЫВОД триггерных выводов
  pinMode(Trig2, OUTPUT);
  digitalWrite(Trig1, LOW);           //установите триггерные контакты на LOW
  digitalWrite(Trig2, LOW);

  // ----- configure Timer 2 to generate a compare-match interrupt every 1mS
  noInterrupts();                     //отключение прерываний
  TCCR2A = 0;                         //очистить регистры управления
  TCCR2B = 0;
  TCCR2B |= (1 << CS22) |             //16MHz/128=8uS
            (1 << CS20) ;
  TCNT2 = 0;                          //очистить счетчик
  OCR2A = 125 - 1;                    //8uS*125=1mS (разрешить распространение тактовых импульсов)
  TIMSK2 |= (1 << OCIE2A);            //включить прерывание сравнения выходных данных
  interrupts();                       //включить прерывания
}

// ===============================
// loop()
// ===============================
void loop()
{
  // ----- measure object distances
  if (TaskFlag1)
  {
    TaskFlag1 = false;
    measure();

    // -----Distance1 and Distance2 readings to the display
    Serial.print(Distance1); Serial.print(","); Serial.println(Distance2);
  }
}

// ===============================
// task scheduler (1mS interrupt)
// ===============================
ISR(TIMER2_COMPA_vect)
{
  // ----- timers
  TaskTimer1++;                       //task 1 timer

  // ----- task1
  if (TaskTimer1 > 499)               //интервал между пингами (50mS=423cm)
  {
    TaskTimer1 = 0;                   //таймер сброса
    TaskFlag1 = true;                 //signal loop() to perform task
  }
}

// ===============================
// measure distances
// ===============================
void measure()
{
  // ----- locals
  unsigned long start_time;           //микросекунды
  unsigned long finish_time1;         //микросекунды
  unsigned long finish_time2;         //микросекунды
  unsigned long time_taken;           //микросекунды
  boolean echo_flag1;                 //флаги отражают состояние эхо-линии
  boolean echo_flag2;

 // ----- send 10uS trigger pulse
  digitalWrite(Trig1, HIGH);
  digitalWrite(Trig2, HIGH);
  delayMicroseconds(10);
  digitalWrite(Trig1, LOW);
  digitalWrite(Trig2, LOW);

  // ----- wait for both echo lines to go high
  while (!digitalRead(Echo1));
  while (!digitalRead(Echo2));

  // ----- record start time
  start_time = micros();

  // ----- reset the flags
  echo_flag1 = false;
  echo_flag2 = false;

  // ----- measure echo times
  while ((!echo_flag1) || (!echo_flag2))
  {
    // ----- Echo1
    if ((!echo_flag1) && (!digitalRead(Echo1)))    //получено Echo1
    {
      echo_flag1 = true;
      finish_time1 = micros();
      time_taken = finish_time1 - start_time;
      Distance1 = ((float)time_taken) / 59;        //использование 59, так как есть обратный путь
    }

    // ----- Echo2
    if ((!echo_flag2) && (!digitalRead(Echo2)))    //получено Echo2
    {
      echo_flag2 = true;
      finish_time2 = micros();
      time_taken = finish_time2 - start_time;
      Distance2 = ((float)time_taken) / 29.5;     //использование 29.5, так как обратного пути нет
    }
  }
}
