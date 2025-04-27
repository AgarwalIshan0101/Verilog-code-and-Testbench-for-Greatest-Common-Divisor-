// Verilog code for greatest commom divisor 
// using the data path , control signals and control path 

// defining the registers , multiplexers, subtractor and comparator used 

// Defining PIPO registor for 1st number 

module PIPO( data_out, data_in, load, clk);
    input [15:0] data_in; input load , clk;
    output  reg [15:0] data_out;
    always @(posedge clk)
        if (load) data_out <= data_in;
endmodule 

// Defining subtractor 

module sub( out , in_1, in_2);
    input [15:0] in_1, in_2;
    output reg [15:0] out;
    always @(*)
        out = in_1 - in_2;
endmodule

// defining comparator 

module comparator( less_than , greater_than, equal, data_1, data_2);
    input [15:0] data_1, data_2;
    output  less_than,greater_than,equal;
    assign less_than = data_1 < data_2;
    assign greater_than= data_1> data_2;
    assign equal = (data_1 == data_2);
endmodule

// defining multiplexer 

module mux( out , in_0, in_1 , sel);
    input [15:0] in_0, in_1; input  sel;
    output [15:0] out;
    assign out = sel ? in_1 : in_0;
endmodule

// defining control signal and control path 

module controller (  lda , ldb , sel1 ,sel2, sel_in, done , clk , less_than, greater_than, equal, start);
    input clk, less_than, greater_than, equal,start;
    output reg lda,ldb,sel1,sel2,sel_in,done;
    reg [2:0] state; 
    parameter s0= 3'b000, s1= 3'b001,s2= 3'b010,s3= 3'b011,s4= 3'b100,s5= 3'b101;
    always @ ( posedge clk)
        begin 
        case ( state )
        s0: if ( start) state <= s1;
        s1: state <=s2;
        s2: #2 if (equal) state <=s5;
                else if (less_than) state <= s3;
                else if (greater_than ) state <= s4;
        s3: #2 if (equal) state <=s5;
                else if (less_than) state <= s3;
                else if (greater_than ) state <= s4;
        s4: #2 if (equal) state <=s5;
                else if (less_than) state <= s3;
                else if (greater_than ) state <= s4;
        s5: state <= s5;
        default : state <= s0;
        endcase 
        end

// defining control signals 

    always @(state)
        begin 
        case (state)
        s0: begin sel_in = 1 ; lda = 1; ldb = 0 ; done = 0 ; end 
        s1: begin sel_in = 1 ; lda = 0 ; ldb = 1; done = 0 ; end 
        s2: if (equal ) done = 1; 
            else if ( less_than) begin sel1 = 1 ; sel2 = 0 ; sel_in= 0;
            #1 lda= 0; ldb = 1; end 
            else if ( greater_than) begin sel1 = 0 ; sel2 = 1 ; sel_in = 0 ; #1 lda = 1 ; ldb = 0; end 
        s3: if ( equal ) done =1 ; 
            else if ( less_than) begin sel1 = 1 ; sel2 = 0; sel_in = 0; #1 lda = 0 ; ldb = 1; end
            else if ( greater_than ) begin sel1 = 0; sel1 =1 ; sel_in = 0 ; end 
        s4: if ( equal) done = 1 ; 
            else if ( less_than) begin sel1 = 1 ; sel2 = 0; sel_in = 0 ; #1 lda =0; ldb =1 ; end 
            else if ( greater_than) begin sel1 = 0; sel2 = 1 ; sel_in = 0; #1 lda = 1; ldb = 0; end 
        s5: begin done =1 ; sel1 = 0; sel2 = 0; lda = 0; ldb = 0; end 
        default: begin lda = 0; ldb = 0 ; end 
        endcase
        end 
endmodule

// defining data path  

module gcd_datapath( greater_than,less_than,equal,lda,ldb,sel1,sel2,sel_in,data_in,clk);

input lda,ldb, sel1, sel2, sel_in,clk; 
input [15:0] data_in;
output greater_than,less_than,equal;
wire [15:0] aout,bout,x,y,bus,subout;

PIPO A (aout , bus , lda, clk);
PIPO B ( bout, bus , ldb, clk);
mux mux_1( x,aout,bout,sel1);
mux mux_2(y , aout,bout,sel2);
mux mux_load ( bus, subout , data_in, sel_in);
sub sb( subout, x,y);
comparator cp( less_than, greater_than,equal,aout,bout);
endmodule


