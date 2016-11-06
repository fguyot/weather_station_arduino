import org.gicentre.utils.stat.*; // Import the gicentre utils stat library for chart classes.
import processing.serial.*;
import java.util.*;

Serial myPort;  // Create object from Serial class

String val;  

int serialCount = 0;  


int[] colorText={255,255,255};
int[] colorLine={122,23,255};

float[] LuminositeIn = new float[60];
float[] PressionIn = new float [60];
float[] HumiditeIn = new float [60];
float[] TemperatureIn = new float [60];

float[] MinVal=new float [4];
float[] MaxVal=new float [4];
boolean firstReceive=true;


XYChart myXYchart_lum;         // Declare an XYChart object. 
float[] xData_lum = new float[60];      // x data table.
float[] yData_lum = new float[60];      // y data table.

XYChart myXYchart_temp;         // Declare an XYChart object. 
float[] xData_temp = new float[60];      // x data table.
float[] yData_temp = new float[60];      // y data table.

XYChart myXYchart_pre;         // Declare an XYChart object. 
float[] xData_pre = new float[60];      // x data table.
float[] yData_pre = new float[60];      // y data table.

XYChart myXYchart_hum;         // Declare an XYChart object. 
float[] xData_hum = new float[60];      // x data table.
float[] yData_hum = new float[60];      // y data table.


/* Execute at the begining t osetup objects and variable */
void setup() {
  
  size(1280, 900);  //size of the window

  String portName = Serial.list()[0];   //change the 0 to a 1 or 2 etc. to match your port
   myPort = new Serial(this, portName, 9600);  //create the serial communication


  // XY chart data initialisation. 
  for(int i=0; i<yData_hum.length; i++) {
  xData_pre[i]=i;
  xData_lum[i]=i;
  xData_temp[i]=i;
  xData_hum[i]=i;
  yData_lum[i]=0;  
  yData_temp[i]=0;  
  yData_pre[i]=0;  
  yData_hum[i]=0;  
  }
  
  // Luminosity  Chart init
  myXYchart_lum = new XYChart(this);      // Create an XYChart object.
  myXYchart_lum.setData(xData_lum, yData_lum);    // Assign data to the XYChart object.
  
  // Chart parameters settings 
  myXYchart_lum.setPointSize(0); 
  myXYchart_lum.setLineWidth(2); 
  myXYchart_lum.setLineColour(color(colorLine[0],colorLine[1],colorLine[2]));
  
  myXYchart_lum.showXAxis(true); 
  myXYchart_lum.setXAxisLabel("Time(s)"); 
  myXYchart_lum.showYAxis(true); 
  myXYchart_lum.setYAxisLabel("Light (lux)"); 
  myXYchart_lum.setMaxY(1200); 
  myXYchart_lum.setMinY(0);
  myXYchart_lum.setAxisColour(color(colorText[0],colorText[1],colorText[2]));
  myXYchart_lum.setAxisLabelColour(color(colorText[0],colorText[1],colorText[2]));
  myXYchart_lum.setAxisValuesColour(color(colorText[0],colorText[1],colorText[2]));
  
  
  //Temperature Char Init
  myXYchart_temp = new XYChart(this);      // Create an XYChart object.
  myXYchart_temp.setData(xData_temp, yData_temp);    // Assign data to the XYChart object.
  
  // Chart parameters settings 
  myXYchart_temp.setPointSize(0); 
  myXYchart_temp.setLineWidth(2); 
  myXYchart_temp.setLineColour(color(colorLine[0],colorLine[1],colorLine[2]));
  
  myXYchart_temp.showXAxis(true); 
  myXYchart_temp.setXAxisLabel("Time(s)"); 
  myXYchart_temp.showYAxis(true); 
  myXYchart_temp.setYAxisLabel("Temperature (C)"); 
  myXYchart_temp.setMaxY(45); 
  myXYchart_temp.setMinY(-15);
  myXYchart_temp.setAxisColour(color(colorText[0],colorText[1],colorText[2]));
  myXYchart_temp.setAxisLabelColour(color(colorText[0],colorText[1],colorText[2]));
  myXYchart_temp.setAxisValuesColour(color(colorText[0],colorText[1],colorText[2]));
  
  
  //Pression char Init
  myXYchart_pre = new XYChart(this);      // Create an XYChart object.
    myXYchart_pre.setData(xData_pre, yData_pre);    // Assign data to the XYChart object.
  
  // Chart parameters settings 
  myXYchart_pre.setPointSize(0); 
  myXYchart_pre.setLineWidth(2); 
  myXYchart_pre.setLineColour(color(colorLine[0],colorLine[1],colorLine[2]));
  
  myXYchart_pre.showXAxis(true); 
  myXYchart_pre.setXAxisLabel("Time(s)"); 
  myXYchart_pre.showYAxis(true); 
  myXYchart_pre.setYAxisLabel("Pressure (hPa)"); 
  myXYchart_pre.setMaxY(120); 
  myXYchart_pre.setMinY(80);
  myXYchart_pre.setAxisColour(color(colorText[0],colorText[1],colorText[2]));
  myXYchart_pre.setAxisLabelColour(color(colorText[0],colorText[1],colorText[2]));
  myXYchart_pre.setAxisValuesColour(color(colorText[0],colorText[1],colorText[2]));
  
  
  
  //Humidity Char Init 
  myXYchart_hum = new XYChart(this);      // Create an XYChart object.
  myXYchart_hum.setData(xData_hum, yData_hum);    // Assign data to the XYChart object.
  
  // Chart parameters settings 
  myXYchart_hum.setPointSize(0); 
  myXYchart_hum.setLineWidth(2); 
  myXYchart_hum.setLineColour(color(colorLine[0],colorLine[1],colorLine[2]));
  
  myXYchart_hum.showXAxis(true); 
  myXYchart_hum.setXAxisLabel("Time(s)"); 
  myXYchart_hum.showYAxis(true); 
  myXYchart_hum.setYAxisLabel("Humidity (%)"); 
  myXYchart_hum.setMaxY(100); 
  myXYchart_hum.setMinY(0);
  myXYchart_hum.setAxisColour(color(colorText[0],colorText[1],colorText[2]));
  myXYchart_hum.setAxisLabelColour(color(colorText[0],colorText[1],colorText[2]));
  myXYchart_hum.setAxisValuesColour(color(colorText[0],colorText[1],colorText[2]));
   

    
  //new SimpleDateFormat ("E yyyy.MM.dd 'at' hh:mm:ss a zzz");

  //System.out.println("Current Date: " + ft.format(dNow));
        // Draw a title over the top of the chart.


}
void draw() { 
  background(30); //Backgroud color
  
  //Draw the chart
  myXYchart_lum.draw(200,200,width-200, height/5); 
  myXYchart_temp.draw(200,375,width-200, height/5);  
  myXYchart_pre.draw(200,550,width-200, height/5);  
  myXYchart_hum.draw(200,725,width-200, height/5);


  // Information text 
  fill(colorText[0],colorText[1],colorText[2]);
  textSize(20);
  text("Simon ROBARD Florian GUYOT                           STATION METEO SANS FIL", 70,30); 
  textSize(11);//Color(0);
  text("Capteurs pour l'embarqué", 70,45); 
  int y=200;
  int pas=175;
  
  
  for(int k=0;k<4;k++){
    textSize(15);
    text("Min",45,y+k*pas+50);
    text("Max",45,y+k*pas+70);
    text("Current",45,y+k*pas+90);
  }

  
  textSize(15);
  text("Luminosity",45,220);
  text("Temperature",45,395);
  text("Pressure",45,570);
  text("Humidity",45,745);
  
  /*
    text("1000",120,y+0*pas+50); // write lum min value 
    text("1000",120,y+0*pas+70); // write lum max value 
  
    text("1000",120,y+1*pas+50); // write temp min value 
    text("1000",120,y+1*pas+70); // write temp max value 
    
    text("1000",120,y+2*pas+50); // write pressure min value 
    text("1000",120,y+2*pas+70); // write pressure max value 
    
    text("1000",120,y+3*pas+50); // write humidity min value 
    text("1000",120,y+3*pas+70); // write humidity max value 
  
  */
  
  
  text(Float.toString(yData_lum[0]),120,200+90);
  text(Float.toString(yData_temp[0]),120,200+175+90);
  text(Float.toString(yData_pre[0]),120,200+2*175+90);
  text(Float.toString(yData_hum[0]),120,200+3*175+90);
  textSize(11);
  
  
  //println("loop");
  /*if ( myPort.available() > 0) {  // If data is available,
    val = myPort.readStringUntil('\n');         // read it and store it in val
  if (val != null)
      decodeval(val);
      //println(val); //print it out in the console
  } */
}



void serialEvent(Serial myPort) {
  // read a byte from the serial port:
  val = myPort.readStringUntil('\n');
  int inByte = myPort.read();  //read value of the port
  decodeval(val);
}
    
void decodeval (String mess){
  //Message type "L1222" so firt is a cara the other is value
  char[] c_arr = val.toCharArray();
  String s_value="";
  for(int i=1; i<c_arr.length;i++){
     s_value=s_value+c_arr[i];  //convert char array into string value
  }
  
  float value = Float.parseFloat(s_value);
  
  if(c_arr[0]=='L'){
    decal(yData_lum,value);  //insert value into the array
    println("lum");
  }
  else if(c_arr[0]=='P'){
    decal(yData_pre,value);  //insert value into the array
    println("pressure");
  }
  else if(c_arr[0]=='T'){
    decal(yData_temp,value);  //insert value into the array
    println("temperature");
  }
  else if(c_arr[0]=='H'){
    decal(yData_hum,value);  //insert value into the array
    println("humidity");
  }
  
  /*
  if(!firstReceive){
    if(yData_temp[0]!=0 && yData_temp[0]!=0 && yData_temp[0]!=0 && yData_temp[0]!=0){
      firstReceive=false;
    }
  }
  else{
    //minmax
  }
  */
}
// insert value into the array
void decal(float tab[],float value){
  float[] tab_tmp = new float[61];
  
  for(int i=0;i<59;i++){
    tab_tmp[i+1]=tab[i];
  }
  tab_tmp[0]=value;
  for(int i=0;i<60;i++){
    tab[i]=tab_tmp[i];
  }
}