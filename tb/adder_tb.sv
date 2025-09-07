`timescale 1ns / 1ps

module adder_tb();

    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] y;

    adder u_DUT (
        .a (a),
        .b (b),
        .y (y)
    );
    
    initial begin

        dump_setup;
        
        //Adding small numbers
        a = 4; b = 3; #10;
        assert (y == 7) else $fatal(1, "Small number error");
        
        //Adding large numbers
        a = 32'h0FFFFFF0; b = 32'h1EFFE012; #10;
        assert (y == 32'h2EFFE002) else $fatal(1, "Large number error");
        
        a = 32'hFFFFFFFF; b = 32'h5EFFFFFF; #10;
        assert (y == 32'h5EFFFFFE) else $fatal(1, "Large number error");
        
        //Adding 0
        a = 0; b = 5; #10;
        assert (y == 5) else $fatal(1, "Zero adding error");
        
        //Adding negative numbers
        a = -5; b = -6; #10;
        assert (y == -11) else $fatal(1, "Negative adding error");
        
        a = 10; b = -5; #10;
        assert (y == 5) else $fatal(1, "Negative adding error");
        
        a = 0; b = -10; #10;
        assert (y == -10) else $fatal(1, "Negative adding error (Zero case)");
        
        $display("TEST PASSED");
        $finish;
        
    end

endmodule
