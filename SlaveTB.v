module SlaveTB();

reg reset;
reg SCLK;
reg CS;
wire [7:0] slaveDataReceived;
reg [7:0] slaveDataToSend;
reg MOSI;
wire MISO;


reg [7:0] data = 8'b1010_0101; // the data that will be sent to the slave
reg [7:0] dataRecieved ; // the data recieved from the slave

integer i;  // counter used to store data inside dataRecieved

Slave S(
    reset,
    slaveDataToSend, slaveDataReceived,
    SCLK, CS, MOSI, MISO
);

initial begin
  SCLK = 1;
  reset = 1;
  #5 reset = 0;

  slaveDataToSend = 8'b0010_0111;
  dataRecieved = 8'b0;
  CS=0;
  // loop to send 8-bits to the slave and get another 8-bits from it
  for(i=0 ; i<=7 ; i=i+1)
      begin
      if(i==0) begin
          MOSI = data[0];
          #5 dataRecieved[0] = MISO;
      end

      else begin
          #20 MOSI = data[i];
          dataRecieved[i] = MISO;
      end

      end
  #20;
  if(dataRecieved == slaveDataToSend) 
      $display("From Slave to Master: Success");
  else 
      $display("From Slave to Master: Failure (Expected: %b, Received: %b)",  slaveDataToSend, dataRecieved);
  if(slaveDataReceived == data)
      $display("From Master to Slave: Success");
  else 
      $display("From Master to Slave: Failure (Expected: %b, Received: %b)", data, slaveDataReceived);
  #10 $finish;

end


always #10 SCLK =~SCLK;

endmodule
