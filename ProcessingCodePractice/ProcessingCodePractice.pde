// ----- последовательный порт
import processing.serial.*;                      //Импорт последовательной библиотеки
Serial myPort;                                   //Объект последовательного порта
final int Baud_rate = 115200;                    //Скорость связи
String Input_string;                             //Используется для входящих данных

// ----- пользовательская фигура
PShape Object;                                   //Дать фигуре имя
int Frame_count = 0;                             //Счетчик кадров
boolean Frame_visible = true;                    //true=visible; false=invisible

// ----- отображение графики
PGraphics Canvas;                                //Название создаваемой области рисования
PFont myFont;                                    //Название создаваемого шрифта
float Baseline = 100;                            //базовая линия треугольника (cm)
float X;                                         //X координата в (cm)
float Y;                                         //Y координата в (cm)

// ----- расстояние датчика НИЖЕ базовой линии (cm)
float Offset = 50;                               //Предполагает квадратный дисплей

// ----- файл
PrintWriter output;
// =========================
// установка
// ==========================
void setup() {

  // ----- экран настройки
  size(800, 800, P3D);                           //Определение размера окна, 3D   
  background(0);                                 //Черный
  frameRate(60);                                 //60 кадров в секунду

  // ----- создание области рисования для затухания луча 
  Canvas = createGraphics(width, height);                          

  // ------ создание экранного шрифта
  myFont = createFont("Arial Black", 20);

  // ----- настройка объект
  Object = createShape(ELLIPSE, 0, 0, 30, 30);   //Создание объекта
  Object.setFill(color(255, 0, 0, 255));         //красный, непрозрачный
  Object.setStroke(color(255, 0, 0, 255));       //красный, непрозрачный

  // ----- инициализация последовательного порта
  /*
    ВАЖНО:
   Если на дисплее не отображается arduino, следует попробовать
   изменить [номер], связанный с COM-портом.
   
   Строка кода "printArray(Serial.list());" генерирует список
   [номеров] в квадратных скобках. например: [0] "COM5"
   
   [Номер] внутри квадратной скобки ДОЛЖЕН совпадать с [номером] в строке
   кода "myPort = new Serial(this, Serial.list()[0], Baud_rate);"    
   */
  printArray(Serial.list());                     //Вывод имеющихся COM-портов на экране
  myPort = new Serial(this, Serial.list()[1], Baud_rate);
  myPort.bufferUntil('\n');
  
  //файл
  output = createWriter("positions.txt");
}

// ==========================
// рисование
// ==========================
void draw()
{
  // ----- обновить экран
  background(0);                      //Черный экран
  textFont(myFont, 20);               //Указание шрифта, который будет использоваться
  draw_grid();                        //Рисование сетки
  draw_object();
  
  // ----- файл
  point(X, Y);
  output.println("Coordinate X: " + X + " Coordinate Y: " + Y);
}

// =======================
// последовательное событие (вызывается с каждой строкой данных Arduino)
// =======================
void serialEvent(Serial myPort)
{
  // ----- дождитесь перевода строки
  Input_string = myPort.readStringUntil('\n');
  println(Input_string);                              //Визуальная обратная связь

  // ----- утверждение
  if (Input_string != null) 
  {
    // ----- обрезать пробелы
    Input_string = trim(Input_string);
    String[] values = split(Input_string, ',');

    // ----- сбор переменных Герона
    float a = float(values[1]) - float(values[0]);    //d2 (vertex -> sensor B)
    float b = float(values[0]);                       //d1 (vertex -> sensor A)
    float c = Baseline;                               //Базовая линия
    //float d = c*1.414;                              //диагональ дисплея (квадратная)
    float d = sqrt(150*150 + 100*100);                //диагональ (дисплей + смещение)
    float s = (a + b + c)/2;                          //Полупериметр

    // ----- проверка расстояний
    /* устранение фиктивныч ошибок */
    boolean distances_valid = true;
    if 
      (
      (a < 0) ||          //d1 должно быть меньше, чем d2
      (b > d) ||          //d1 вне зоны действия
      (a > d) ||          //d2 вне зоны действия
      ((s - a) < 0) ||    //Эти значения должны быть положительными
      ((s - b) < 0) || 
      ((s - c) < 0)
      ) 
    {
      distances_valid=false;
      X=1000;             //Переместить мигающую точку за пределы экрана
      Y=1000;             //Переместить мигающую точку за пределы экрана
    }

    // ----- применение формулы Герона
    if (distances_valid)
    {
      float area = sqrt(s * (s - a) * (s - b) * (s - c));
      Y = area * 2 / c;
      X = sqrt(b * b - Y * Y);
      
      // ----- отображение данных для действительных эхо-сигналов
      print("    d1: "); 
      println(b);
      print("    d2: "); 
      println(a);
      print("  base: "); 
      println(c);      
      print("offset: "); 
      println(Offset);
      print("     s: "); 
      println(s);
      print("  area: "); 
      println(area);
      print("     X: "); 
      println(X);
      print("     Y: "); 
      println(Y);
      println("");
    }
    myPort.clear();                                //Очистка буфера приема
  }
}

// ==========================
// рисование сетки
// ==========================
void draw_grid()
{
  pushMatrix();

  scale(0.8);
  translate(width*0.1, height*0.10);  
  fill(0);
  stroke(255);

  // ----- граница
  strokeWeight(4);
  rect(0, 0, width, height, 20, 20, 20, 20);

  // ----- горизонтальные линии
  strokeWeight(1);
  line(0, height*0.1, width, height*0.1);
  line(0, height*0.2, width, height*0.2);
  line(0, height*0.3, width, height*0.3);
  line(0, height*0.4, width, height*0.4);
  line(0, height*0.5, width, height*0.5);
  line(0, height*0.6, width, height*0.6);
  line(0, height*0.7, width, height*0.7);
  line(0, height*0.8, width, height*0.8);
  line(0, height*0.9, width, height*0.9);

  // ----- вертикальные линии
  line(width*0.1, 0, width*0.1, height);
  line(width*0.2, 0, width*0.2, height);
  line(width*0.3, 0, width*0.3, height);
  line(width*0.4, 0, width*0.4, height);
  line(width*0.5, 0, width*0.5, height);
  line(width*0.6, 0, width*0.6, height);
  line(width*0.7, 0, width*0.7, height);
  line(width*0.8, 0, width*0.8, height);
  line(width*0.9, 0, width*0.9, height);

  // ----- обозначение оси X
  fill(255);                                    //Белый текст
  textAlign(LEFT, TOP);
  text("0", -20, height+10);                    //0cm
  text("50", width*0.5-20, height+10);          //50cm
  text("100cm", width-20, height+10);           //100cm

  // ----- обозначение оси Y
  textAlign(RIGHT, BOTTOM);
  text("100cm", 10, -10);                      //100cm
  textAlign(RIGHT, CENTER);
  text("50", -10, height/2);                   //100cm

  popMatrix();
}

// ==========================
// рисование объекта
// ==========================
void draw_object()
{
  pushMatrix();
  scale(0.8);
  stroke(0, 255, 0);
  strokeWeight(1);
  translate(width*0.1, height*1.1);              //(0,0) теперь нижний левый угол

  // ----- сделать так, чтобы объект мигал
  if ((frameCount-Frame_count)>4)
  {
    Frame_visible = !Frame_visible;
    Frame_count = frameCount;
  }

  // ----- цветовая схема объекта
  if (Frame_visible)
  {
    // ----- сделать объект видимым
    Object.setFill(color(255, 0, 0, 255));      //непрозрачный
    Object.setStroke(color(255, 0, 0, 255));    //непрозрачный
  } else
  {
    // ----- скрыть объект
    Object.setFill(color(255, 0, 0, 0));        //Прозрачный
    Object.setStroke(color(255, 0, 0, 0));      //Прозрачный
  }

  // ----- нарисуйте объект
  pushMatrix();
  translate(X/100*width, -(Y-Offset)/100*height);
  shape(Object);
  popMatrix();
  popMatrix();
}
// ----- файл
void keyPressed() {
  output.flush();  //  записываем в файл оставшиеся данные
  output.close();  //  закрываем файл
  exit();  //  останавливаем программу
}
