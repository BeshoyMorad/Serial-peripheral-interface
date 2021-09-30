module Slave(
input reset,
input [7:0] slaveDataToSend,
output reg [7:0] slaveDataReceived,
input SCLK,
input CS,
input MOSI,
output reg MISO
);

reg [7:0] Data; // the data inside the slave
reg [7:0] Received; // the data received in the slave from the master
reg enable = 0; // like a switch to the slave (if = 1) the slave is on (else) the slave is off

integer i = 0; // counter

// if new data arrives set it in Data
always @ (slaveDataToSend) Data = slaveDataToSend;
always @ (posedge SCLK or reset)
  begin
    if (reset == 1)
    begin    
    Data = 8'b0;  // reset the data inside the master to zeros
    Received = 8'b0; // reset the received data to zeros
    end
    
    else if (CS == 0) enable = 1;

    else if (CS == 1) MISO = 1'bz;

    if (enable == 1)
    begin

         MISO = Data[0]; // writing data to MISO
         Data = Data >> 1; // shifting the data inside the master on bit right

    end

  end

always @ (negedge SCLK)
  begin 
    if (enable == 1)
     begin

         Data[7] = MOSI; // reading data from MOSi

         Received[i] = MOSI; // edit the received data (after 8 bits the masterDataReceived should get slave data)
         i = i + 1;  // increasing the counetr until it reaches 7

	 // when (i) becomes 8 this mean that we finished 
         if(i == 8)
           begin
             i=0;  // reset the counter 
             enable=0;  // turn of the slave
           end
     end

  end

assign slaveDataReceived = Received;

endmodule
