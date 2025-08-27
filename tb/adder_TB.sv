`timescale 1ns / 1ps

module adder_TB();

    logic [31:0] a, b, y;

    adder DUT(a, b, y);
    
    initial begin

        dump_setup;
        
        //Adding small numbers
        a = 4; b = 3; #10;
        assert (y == 7) else $display("Small number error");
        
        //Adding large numbers
        a = 32'h0FFFFFF0; b = 32'h1EFFE012; #10;
        assert (y == 32'h2EFFE002) else $display("Large number error");
        
        a = 32'hFFFFFFFF; b = 32'h5EFFFFFF; #10;
        assert (y == 32'h5EFFFFFE) else $display("Large number error");
        
        //Adding 0
        a = 0; b = 5; #10;
        assert (y == 5) else $display("Zero adding error");
        
        //Adding negative numbers
        a = -5; b = -6; #10;
        assert (y == -11) else $display("Negative adding error");
        
        a = 10; b = -5; #10;
        assert (y == 5) else $display("Negative adding error");
        
        a = 0; b = -10; #10;
        assert (y == -10) else $display("Negative adding error (Zero case)");
        
        $display("Simulation complete");
        
    end

endmodule
