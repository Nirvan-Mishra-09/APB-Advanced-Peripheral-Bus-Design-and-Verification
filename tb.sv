class transaction;
  rand bit [31:0] paddr;
  rand bit psel;
  rand bit penable;
  rand bit [7:0] pwdata;
  rand bit pwrite;
  bit [7:0] prdata;
  bit pready;
  bit pslverr;
  
  constraint addr_c{paddr >= 0; paddr <= 15;}
  constraint data_c{pwdata >= 0; pwdata <= 255;}
  function void display(input string tag);
    $display("[%0s] :  paddr:%0d  pwdata:%0d pwrite:%0b  prdata:%0d pslverr:%0b @ %0t",tag,paddr,pwdata, pwrite, prdata, pslverr,$time);
  endfunction
endclass
 
class generator;
  transaction tr;
  mailbox #(transaction) mbx;
  event nextdrv;
  event nextsco;
  event done;
  int count = 0;
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    tr = new();
  endfunction
  
  task run();
    repeat(count) begin
      assert(tr.randomize) else $error("[GEN]: Randomization Failed");
      mbx.put(tr);
      tr.display("GEN");
      @(nextdrv);
      @(nextsco);
    end
    ->done;
  endtask
endclass

class driver;
  
  virtual apb_if vif;
  transaction dc;
  
  mailbox #(transaction) mbx;
  event nextdrv;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  task reset();
    vif.presetn <= 1'b0; //active low reset
    vif.psel <= 1'b0;
    vif.paddr <= 0;
    vif.penable <= 1'b0;
    vif.pwdata <= 0;
    vif.pwrite <= 1'b0;
    
    repeat (5) @(posedge vif.pclk);
    vif.presetn <= 1'b1; // removing the reset
    $display("[DRV] : RESET DONE");
    $display("----------------------------------------------------------------------------");
  endtask
  
  task run();
    forever begin
      
      mbx.get(dc); // getting the data from gen class using mailbox
      @(posedge vif.pclk);
      if(dc.pwrite == 1'b1) begin //write operation
        // setup phase
        vif.psel <= 1'b1;
        vif.penable <= 1'b0;
        vif.paddr <= dc.paddr;
        vif.pwdata <= dc.pwdata;
        vif.pwrite <= 1'b1;
        @(posedge vif.pclk);
        // access phase
        vif.penable <= 1'b1;
        @(posedge vif.pclk);
        vif.psel <= 1'b0;
        vif.penable <= 1'b0;
        vif.pwrite <= 1'b0;
        dc.display("DRV");
        ->nextdrv;
      end
      
      else if(dc.pwrite == 1'b0) begin //read operation
        // setup phase
        vif.psel <= 1'b1;
        vif.penable <= 1'b0;
        vif.paddr <= dc.paddr;
        vif.pwdata <= 0;
        vif.pwrite <= 1'b0;
        @(posedge vif.pclk);
        // access phase
        vif.penable <= 1'b1;
        @(posedge vif.pclk);
        vif.psel <= 1'b0;
        vif.penable <= 1'b0;
        vif.pwrite <= 1'b0;
        dc.display("DRV");
        ->nextdrv;
      end
    end
  endtask
endclass
 
class monitor;
  virtual apb_if vif;
  transaction tr;
  mailbox #(transaction) mbx;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  task run();
    tr = new();
    forever begin
      @(posedge vif.pclk);
      if(vif.pready) begin
        tr.pwdata <= vif.pwdata;
        tr.paddr <= vif.paddr;
        tr.pwrite <= vif.pwrite;
        tr.prdata <= vif.prdata;
        tr.pslverr <= vif.pslverr;
        @(posedge vif.pclk);
        tr.display("MON");
        mbx.put(tr); 
      end
    end
  endtask
endclass
 
class scoreboard;
  transaction tr;
  mailbox #(transaction) mbx;
  
  event nextsco;
  
  reg [7:0] mem [15:0] = '{default:0};
  reg [7:0] rdata;
  int err;
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
  task run();
    forever begin
      mbx.get(tr);
      tr.display("SCO");
      
      if(tr.pwrite == 1'b1 && tr.penable == 1'b0) begin
        mem[tr.paddr] = tr.pwdata;
        $display("[SCO] : DATA STORED DATA : %0d ADDR: %0d",tr.pwdata, tr.paddr);
      end
      
      else if(tr.pwrite == 1'b0 && tr.penable == 1'b0) begin
        rdata = mem[tr.paddr];
        if(tr.prdata == rdata) $display("[SCO] : DATA MATCHED");
        else begin
          err++;
          $display("[SCO] : DATA MISMATCHED");
        end
      end
      
      else if(tr.pslverr) $display("SLV ERROR DETECTED");
      $display("---------------------------------------------------------------------------------------------------");
      ->nextsco;
    end
  endtask
endclass
 
//////////////////////////////////////////////////////////
 
class environment;
 
    generator gen;
    driver drv;
    monitor mon;
    scoreboard sco; 
  
    
  
    event nextgd; ///gen -> drv
    event nextgs;  /// gen -> sco
  
    mailbox #(transaction) gdmbx; ///gen - drv

    mailbox #(transaction) msmbx;  /// mon - sco

    virtual apb_if vif;
 
  
  function new(virtual apb_if vif);
       
    gdmbx = new();
    gen = new(gdmbx);
    drv = new(gdmbx);
    
    
    msmbx = new();
    mon = new(msmbx);
    sco = new(msmbx);
    
    this.vif = vif;
    drv.vif = this.vif;
    mon.vif = this.vif;
    
    gen.nextsco = nextgs;
    sco.nextsco = nextgs;
    
    gen.nextdrv = nextgd;
    drv.nextdrv = nextgd;
 
  endfunction
  
  task pre_test();
    drv.reset();
  endtask
  
  task test();
  fork
    gen.run();
    drv.run();
    mon.run();
    sco.run();
  join_any
  endtask
  
  task post_test();
    wait(gen.done.triggered);  
    $display("----Total number of Mismatch : %0d------",sco.err);
    $finish();
  endtask
  
  task run();
    pre_test();
    test();
    post_test();  
  endtask
  
  
  
endclass
 
 
//////////////////////////////////////////////////
 module tb;
    
   apb_if vif();
 
   
   apb_s dut (
   vif.pclk,
   vif.presetn,
   vif.paddr,
   vif.psel,
   vif.penable,
   vif.pwdata,
   vif.pwrite,
   vif.prdata,
   vif.pready,
   vif.pslverr
   );
   
    initial begin
      vif.pclk <= 0;
    end
    
    always #10 vif.pclk <= ~vif.pclk;
    
    environment env;
    
    
    
    initial begin
      env = new(vif);
      env.gen.count = 20;
      env.run();
    end
   
   initial begin
     $dumpfile("dump.vcd");
     $dumpvars;
   end
          
  endmodule
