`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.05.2024 14:44:53
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


class transaction;
randc bit [7:0] din1;         
randc bit [7:0] din2;             
randc bit [7:0] addr;
bit [8:0] dout;
bit we;
endclass



interface ram_intf();
logic clk, rst, we;
logic [7:0] din1;         
logic [7:0] din2;             
logic [7:0] addr;
logic [8:0] dout;
endinterface



class generator;
mailbox mbx;
integer i;
transaction t;
event done;

function new (mailbox mbx);
this.mbx = mbx;
endfunction

task run();
t=new();
for(i=0 ; i<20; i++)
t.randomize();
mbx.put(t);
@(done);
endtask
endclass



class driver;
virtual ram_intf vif;
event done;
mailbox mbx;
transaction t;



function new (mailbox mbx);
this.mbx= mbx;
endfunction



task run();
t=new();
forever begin
mbx.get(t);
vif.din1 = t.din1;
vif.din2 = t.din2;
vif.addr = t.addr;
-> done;
@(posedge vif.clk);
end
endtask
endclass


class monitor;
virtual ram_intf vif;
transaction t;
mailbox mbx;


function new(mailbox mbx);
this.mbx= mbx;
endfunction



task run();
t=new();
forever begin
t.din1 = vif.din1;
t.din2 = vif.din2;
t.addr = vif.addr;
t.dout = vif.dout;
t.we=vif.we;
mbx.put(t);
$display("[MON] : Data send to scoreboard ");
@(posedge vif.clk);
end
endtask
endclass



class scoreboard;
mailbox mbx;
transaction t;
transaction tarr[256];
bit [8:0] temp;

function new(mailbox mbx);
this.mbx= mbx;
endfunction


task run();
forever begin
mbx.get(t);
if(t.we == 1'b1) begin
  if(tarr[t.addr] == null) begin
     tarr[t.addr] = new();
     tarr[t.addr] = t;
     $display("[SCO] : Data stored");
     end
    end
 else begin
   if(tarr[t.addr] == null) begin
     if(t.dout == 0) 
       $display("[SCO] : Data read Test Passed");
     else
       $display("[SCO] : Data read Test Failed"); 
    end
    else begin
      if(t.dout == tarr[t.addr].din1+tarr[t.addr].din2)
       $display("[SCO] : Data read Test Passed");
       else
       $display("[SCO] : Data read Test Failed"); 
    end
    end
end
endtask
endclass


class environment;
generator gen;
driver drv;
monitor mon;
scoreboard sco;
event gddone;
mailbox gdmbx, msmbx;
virtual ram_intf vif;


function new(mailbox gdmbx, mailbox msmbx);
this.gdmbx = gdmbx;
this.msmbx = msmbx;

gen = new(gdmbx);
drv = new(gdmbx);
mon = new(msmbx);
sco = new(msmbx);
endfunction



task run();
gen.done = gddone;
drv.done = gddone;

drv.vif = vif;
mon.vif = vif;

fork 
gen.run();
drv.run();
mon.run();
sco.run();


join_any

endtask
endclass


module tb;

environment env;
ram_intf vif();
mailbox gdmbx, msmbx;
 
dual_ram dut (vif.clk, vif.rst, vif.we, vif.din1, vif.din2, vif.addr, vif.dout);
 
always #5 vif.clk = ~vif.clk;
 
 
initial begin
vif.clk = 0;
vif.rst = 1;
vif.we = 1;
#50;
vif.we = 1;
vif.rst = 0;
#300;
vif.we = 0;
#200
vif.rst = 0;
#50;
 
end
 
initial begin
gdmbx = new();
msmbx = new();
 
env = new(gdmbx,msmbx);
env.vif = vif;
env.run();
#600;
$finish;
end
endmodule
