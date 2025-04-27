`include "gcd.v"

module gcd_test;
    reg [15:0] data_in;
    reg clk , start; 
    wire done ; 
    reg [15:0] A,B;

    gcd_datapath DP( greater_than,less_than,equal,lda,ldb,sel1,sel2,sel_in,data_in,clk);
    controller con(lda , ldb , sel1 ,sel2, sel_in, done , clk , less_than, greater_than, equal, start);

    initial
        begin
        clk = 1'b0;
        #3 start = 1'b1;
        #1000 $finish;
        end 

    always #5 clk = ~ clk ; 

    initial 
        begin 
        #12 data_in =143;
        #10 data_in = 78;
        end 

    initial
        begin 
        $monitor ( $time , " %d %b", DP.aout, done);
        end 
endmodule
