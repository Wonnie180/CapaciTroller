import processing.serial.*;

Serial serial_port = null;         // the serial port
Button btn_serial_up;              // move up through the serial port list
Button btn_serial_dn;              // move down through the serial port list
Button btn_serial_connect;         // connect to the selected serial port
Button btn_serial_disconnect;      // disconnect from the serial port
Button btn_serial_list_refresh;    // refresh the serial port list
String serial_list;                // list of serial ports
int serial_list_index = 0;         // currently selected serial port 
int num_serial_ports = 0;          // number of serial ports in the list



void setupBtn() {
  // create the buttons
  btn_serial_up = new Button("^", 140, 10, 40, 20);
  btn_serial_dn = new Button("v", 140, 50, 40, 20);
  btn_serial_connect = new Button("Connect", 190, 10, 100, 25);
  btn_serial_disconnect = new Button("Disconnect", 190, 45, 100, 25);
  btn_serial_list_refresh = new Button("Refresh", 190, 80, 100, 25);


  num_serial_ports = Serial.list().length;
  // get the list of serial ports on the computer
  if (num_serial_ports > 0) {
    serial_list = Serial.list()[serial_list_index];
  } else { 
    serial_list = "";
  }
}

void mousePressed() {
  // up button clicked
  if (btn_serial_up.MouseIsOver()) {
    if (serial_list_index > 0) {
      // move one position up in the list of serial ports
      serial_list_index--;
      serial_list = Serial.list()[serial_list_index];
    }
  }
  // down button clicked
  if (btn_serial_dn.MouseIsOver()) {
    if (serial_list_index < (num_serial_ports - 1)) {
      // move one position down in the list of serial ports
      serial_list_index++;
      serial_list = Serial.list()[serial_list_index];
    }
  }
  // Connect button clicked
  if (btn_serial_connect.MouseIsOver()) {
    if (serial_port == null) {
      // connect to the selected serial port
      serial_port = new Serial(this, Serial.list()[serial_list_index], 9600);
      mando.setPort(serial_port);
    }
  }
  // Disconnect button clicked
  if (btn_serial_disconnect.MouseIsOver()) {
    if (serial_port != null) {
      // disconnect from the serial port
      serial_port.stop();
      serial_port = null;
      mando.setPort(serial_port);
    }
  }
  // Refresh button clicked
  if (btn_serial_list_refresh.MouseIsOver()) {
    num_serial_ports = Serial.list().length;
    // get the list of serial ports on the computer
    if (num_serial_ports > 0) {
      serial_list = Serial.list()[serial_list_index];
    } else { 
      serial_list = "";
    }
  }
}

void drawButtons() {
  btn_serial_up.Draw();
  btn_serial_dn.Draw();
  btn_serial_connect.Draw();
  btn_serial_disconnect.Draw();
  btn_serial_list_refresh.Draw();
  // draw the text box containing the selected serial port

  DrawTextBox("Select Port", serial_list, 10, 10, 120, 60);
}

void DrawTextBox(String title, String str, int x, int y, int w, int h)
{
  fill(255);
  rect(x, y, w, h);
  fill(0);
  textAlign(LEFT);
  textSize(14);
  text(title, x + 10, y + 10, w - 20, 20);
  textSize(12);  
  text(str, x + 10, y + 40, w - 20, h - 10);
}
