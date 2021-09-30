module Master(
input clk, reset, start,
input [1:0] slaveSelect, [7:0] masterDataToSend,
output [7:0] masterDataReceived,
output SCLK,
output reg [0:2] CS,
output reg MOSI,
input MISO
);

reg [7:0] Data; // the data inside the master
reg [7:0] Received; // the data received in the master from the slave
reg enable = 0; // like a switch to the master (if = 1) the master is on (else) the master is off
reg cl; // SCLK temp
integer i = 0; // counter

always @ (posedge clk or posedge reset)
  begin

    // for the SCLK generator
    if (CS !=3'b111) cl = clk;
    else  cl = 1'b0;

    if (reset == 1)
    begin
    Data = 8'b0;  // reset the data inside the master to zeros
    CS = 3'b111;  // reset the chip select signal to high
    Received = 8'b0; // reset the received data to zeros
    end

    else if (start == 1)
    begin
         Data = masterDataToSend; // assign the data inside the master to the data that we want to send to slave

         // choose the slave that we want to send the data to
         case (slaveSelect)
         2 : CS = 3'b110;   // will be choice just in case
         1 : CS = 3'b101;
         0 : CS = 3'b011;
         endcase
         #15 enable = 1;

    end

    else if (enable == 1)
    begin

         MOSI = Data[0]; // writing data to MOSI
         Data = Data >> 1; // shifting the data inside the master on bit right

     end

  end

always @ (negedge clk)
begin

    // for the SCLK generator
    if (CS !=3'b111) cl = clk;
    else  cl = 1'b0;

    if(enable == 1)
    begin

      Data[7] = MISO; // reading data from MISO

      Received[i] = MISO; // edit the received data (after 8 bits the masterDataReceived should get slave data)
      i = i + 1;  // increasing the counetr until it reaches 7

      // when (i) becomes 8 this mean that we finished 
      if(i == 8)
        begin
          i = 0;  // reset the counter 
          enable = 0;  // turn of the master
          CS = 3'b111;  // turn of all the slaves
        end
    end
end

assign SCLK = cl;
assign masterDataReceived = Received;

endmodule
