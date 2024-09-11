`timescale 1ns / 1ps
module apb_s(
    input pclk, presetn,
    input [31:0] paddr,
    input psel,
    input penable,
    input [7:0] pwdata,
    input pwrite,
    output reg [7:0] prdata,
    output reg pready,
    output pslverr
    );
    
    localparam [1:0] idle = 0, write = 1, read = 2;
    reg [7:0] mem[15:0];
    reg [1:0] state, nstate;
    bit addr_err, addv_err, data_err;
    always @ (posedge pclk or negedge presetn) begin
        if(presetn == 1'b0) begin
            state <= idle;
        end
        else begin
            state <= nstate;
        end
    end
    
    always @ (*) begin
        case(state)
            idle: begin
                prdata = 0;
                pready = 1'b0;
                
                if(psel == 1'b1 && pwrite == 1'b1) begin
                    nstate = write;
                end
                else if(psel == 1'b1 && pwrite == 1'b0) begin
                    nstate = read;
                end
                else begin
                    nstate = idle;
                end
            end
            
            write: begin
                if(psel == 1'b1 && penable == 1'b1) begin
                    if(!addr_err && !addv_err && !data_err) begin
                        pready = 1'b1;
                        mem[paddr] = pwdata;
                        nstate = idle;
                    end
                    else begin
                        pready = 1'b1;
                        nstate = idle;
                    end
                end
            end
            
            read: begin
                if(psel == 1'b1 && penable == 1'b1) begin
                    if(!addr_err && !addv_err && !data_err) begin
                        pready = 1'b1;
                        prdata = mem[paddr];
                        nstate = idle;
                    end
                    else begin
                        pready = 1'b1;
                        nstate = idle;
                    end
                end
            end
            
            default: begin
                pready = 1'b0;
                prdata = 0;
                nstate = idle;
            end
        endcase
    end
    reg av_t = 0;
    reg dv_t = 0;
    
    always @ (*) begin
        if(paddr >= 0) begin
            av_t = 1'b0;
        end
        else begin
            av_t = 1'b1;
        end
    end 
    always @ (*) begin
        if(pwdata >= 0) begin
            dv_t = 1'b0;
        end
        else begin
            dv_t = 1'b1;
        end
    end
    
assign addr_err = (nstate == write || read) && (paddr > 15) ? 1'b1 : 1'b0;
assign addv_err = (nstate == write || read) ? av_t : 1'b0;
assign data_err = (nstate == write || read) ? dv_t : 1'b0;
assign pslverr = (psel == 1'b1 && penable == 1'b1) ? (addr_err || data_err || addv_err) : 1'b0;
endmodule

interface apb_if;
    logic pclk;
    logic presetn;
    logic [31:0]paddr;
    logic psel;
    logic penable;
    logic [7:0]pwdata;
    logic pwrite;
    logic [7:0]prdata;
    logic pready;
    logic pslverr; 
endinterface
