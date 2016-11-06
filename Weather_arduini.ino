
//***** BLABLA ENTETE ****//


#include <Wire.h>


#define PIN_DHT11       5
#define PIN_TEMT6000X01 0

#define VCC_TEMT6000X01 10
#define VCC_DHT11       11
//****** MPL115A2 variable ******//

#define MPL115A2_PRESSURE_MSB               (0x00)
#define MPL115A2_A0_MSB                     (0x04)
#define MPL115A2_CONVERT                    (0x12)
#define MPL115A2_ADDRESS                    (0x60)

float MPL115A2_a0 = 0.0F;
float MPL115A2_b1 = 0.0F;
float MPL115A2_b2 = 0.0F;
float MPL115A2_c12 = 0.0F;


float humi=0.0F;
float temp=0.0F;
float pressure=0.0F;
float luminosity=0.0F;





void setup(void) {
  
  Serial.begin(9600);
  pinMode(VCC_DHT11, OUTPUT);
  digitalWrite(VCC_DHT11, HIGH);
  pinMode(VCC_TEMT6000X01, OUTPUT);
  digitalWrite(VCC_TEMT6000X01, HIGH);
  pinMode(PIN_DHT11, OUTPUT);
  digitalWrite(PIN_DHT11, HIGH);
  //Serial.println("Init pressure & temp sensor MPL115A2");
  mpl115a2_init();
}



void loop(void) {

  pressure=getPressure_mpl115a2();
  luminosity=getLumi_TEMT6000X01();
  getHumidity();
  XbeesendMess();
  /*
  Serial.print("Pressure      = "); Serial.print(pressure);Serial.println("  KPA");
  Serial.print("Luminosity    = "); Serial.print(luminosity);Serial.println("  Lux");
  Serial.print("Humidity      = "); Serial.print(humi);Serial.println("  %");
  Serial.print("Temperature   = "); Serial.print(temp);Serial.println("  °C");*/
  delay(1000);
}





/******************************** FUNCTION OF MPL115A2 (Pressure) ********************************/

/***** Init sensor for first use, save the coeff *****/
void mpl115a2_init(void){
  
  Wire.begin(); //join i2c bus
  
  Wire.beginTransmission(MPL115A2_ADDRESS); //transmit to MPL115A2 sensor address
  Wire.write(MPL115A2_A0_MSB);
  Wire.endTransmission();
  Wire.requestFrom(MPL115A2_ADDRESS, 8);

  
  int a0coeff = ((Wire.read() << 8) | Wire.read());
  int b1coeff = ((Wire.read() << 8) | Wire.read());
  int b2coeff = ((Wire.read() << 8) | Wire.read());
  int c12coeff = (((Wire.read() << 8) | Wire.read())) >> 2;


  MPL115A2_a0 = a0coeff / 8.0F; 
  MPL115A2_b1 = b1coeff / 8192.0F;
  MPL115A2_b2 = b2coeff / 16384.0F;
  MPL115A2_c12 = c12coeff / 4194304.0F;
  
  /*
  Serial.print("A0 = "); Serial.println(MPL115A2_a0);
  Serial.print("B1 = "); Serial.println(MPL115A2_b1);
  Serial.print("B2 = "); Serial.println(MPL115A2_b2);
  Serial.print("C12 = "); Serial.println(MPL115A2_c12);
  */
}



float getPressure_mpl115a2() {
  int pressureADC;
  int tempADC;
  float Pcomp;

  // Get raw pressure and temperature settings
  Wire.beginTransmission(MPL115A2_ADDRESS);
  Wire.write(MPL115A2_CONVERT);
  Wire.write(0x00);
  Wire.endTransmission();

  delay(5); //wait for conversion
  

  Wire.beginTransmission(MPL115A2_ADDRESS);
  Wire.write(MPL115A2_PRESSURE_MSB);
  Wire.endTransmission();

  Wire.requestFrom(MPL115A2_ADDRESS, 4);
  pressureADC = (( Wire.read() << 8) | Wire.read()) >> 6;
  tempADC = ( ( Wire.read() << 8) | Wire.read()) >> 6;

  
  Pcomp = MPL115A2_a0 + (MPL115A2_b1 + MPL115A2_c12 * tempADC ) * pressureADC + MPL115A2_b2 * tempADC;  //Compensation
  
  float pressureCompensed = (((115.0F-50.0F) / 1023.0F) * Pcomp) + 50.0F; //real value (see datasheet)
  
  return pressureCompensed;
}


/******************************** FUNCTION OF TEMT6000X01 (Luminosity) ********************************/
float getLumi_TEMT6000X01(){
  int sensorValue = analogRead(A0);
  float voltage = sensorValue  * 5.0 / 1024.0;
  float microamps = voltage*1000000 / 10000.0;  // across 10,000 Ohms
  float lux = microamps * 2.0;
  return lux;
}





void getHumidity(){

  float data_DHT11[3];
  int DHTpinState;
  int buffer[41];
  int buffer_data[5];
  unsigned long time1;
  unsigned long time2;
  unsigned long timeTest1; 
  unsigned long timeTest2; 
  unsigned long timeDecision;
  
  // loop increments
  
  // Sensor data
  int humidity_data;
  int temperature_data;
  int checksum_state;

   
  //Send the Start signal
  pinMode(PIN_DHT11, OUTPUT);
  digitalWrite(PIN_DHT11, LOW);
  delay(20);
  digitalWrite(PIN_DHT11, HIGH);
  delayMicroseconds(40);
  
  pinMode(PIN_DHT11, INPUT); //Change Pin mode to receive

  for(int i=0;i<41;i++){

    timeTest1 = micros();
    while(DHTpinState == 0){
      
      timeTest2 = micros();
      if((timeTest2-timeTest1)>150){
        return;
      }
      DHTpinState = digitalRead(PIN_DHT11);
    }
    
    time1 = micros();
    timeTest1 = micros();
    while(DHTpinState == 1){
      timeTest2 = micros();
      if((timeTest2-timeTest1)>150){
        return;
      }
      DHTpinState = digitalRead(PIN_DHT11);
    }
    
    time2 = micros();
    
    //Decide if '0' or '1'
    timeDecision = time2 - time1;
  
    if(timeDecision < 40){
      buffer[i] = 0;
    }
    else{
      buffer[i] = 1;
    }
  }

  for(int i=0; i<5; i++){
    int val_tmp=0;
    for(int j=0; j<5; j++){
      val_tmp |= ( buffer[8*i+j+1] << (7-j) ); 
    }
    buffer_data[i] = val_tmp;
  }


  
    // Checksum verification
   char checksum = (char)buffer_data[0]+(char)buffer_data[1]+(char)buffer_data[2]+(char)buffer_data[3];

   
   
   if (checksum == (char)buffer_data[4]){
    
    humi=buffer_data[0]+buffer_data[1]/256.0F;
    temp = buffer_data[2]+buffer_data[3]/256.0F;
    
   }

}


void XbeesendMess(){

  Serial.print('P');
  Serial.println(pressure);
  Serial.print('L');
  Serial.println(luminosity);
  Serial.print('H');
  Serial.println(humi);
  Serial.print('T');
  Serial.println(temp);
  
  
}

