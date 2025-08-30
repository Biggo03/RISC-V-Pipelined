`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2025 07:55:31 PM
// Design Name: 
// Module Name: InstrCacheSet_TB
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


module instr_cache_set_tb();

    localparam B = 64;
    localparam NumTagBits = 26;
    localparam E = 4;
    
    //Used Signals
    logic clk, reset;
    logic ActiveSet, RepReady;
    logic [$clog2(B)-1:0] Block;
    logic [NumTagBits-1:0] Tag;
    logic [(B*8)-1:0] RepBlock;
    logic [31:0] Data;
    logic CacheMiss;
    
    logic [1:0] LRUBitsE [3:0];
    
    //Device instantiation
    instr_cache_set DUT(.clk(clk),
                      .reset(reset),
                      .ActiveSet(ActiveSet),
                      .RepReady(RepReady),
                      .Block(Block),
                      .Tag(Tag),
                      .RepBlock(RepBlock),
                      .Data(Data),
                      .CacheMiss(CacheMiss));
    
    //Task for assering Cache misses produce the expected outputs
    task AssertMiss();
        assert(CacheMiss === 1) else $fatal(1, "Incorrectly indicated cache hit\nData Output: %b", Data);
    endtask
    
    //Task for checking LRUBits are as expected
    task AssertLRUBits();
        for (integer i = 0; i < E; i = i + 1) begin
            assert(DUT.LRUBits[i] === LRUBitsE[i]) else $fatal(1, "Unexpected LRU ordering. Incorrect LRU index: %d\nActual: %d\nExpected: %d", i, DUT.LRUBits[i], LRUBitsE[i]);
        end
            
    endtask
    
    //Clock
    always begin
        clk = ~clk; #5;
    end
    
    initial begin

        dump_setup;
        
        //Initialization
        reset = 1; clk = 0; ActiveSet = 0; RepReady = 0; Block = 0; Tag = 0;
        RepBlock = 512'h55555555_44444444_FFEEAABB_00001111_BBBBBBBB_AAAAAAAA_FFFFFFFF_33333333_22222222_EEEEEEEE_CCCCCCCC_88888888_99999999_12345678_FEDCBA98_00AA00AA;
        #10; 
        reset = 0;
        
        #100;
        
        //After initialized with no input, should output same as a miss
        AssertMiss();
        
        ActiveSet = 1;  Block = 0; Tag = 500;
        #10;
        AssertMiss();
        
        //Fill up the set with data
        for (integer i = 0; i < E; i = i + 1) begin
            
            //Check data is ready one clock cycle after replacement indicated ready
            RepReady = 1;
            #20;
            
            assert(Data === RepBlock[31:0] && CacheMiss == 0) else $fatal(1, "Incorrect Data output on miss\nData:          %h\nExpected Data: %h", Data, RepBlock[31:0]);
            
            //Update tag
            Tag =  Tag + 100;
            RepReady = 0;
            #10;
            AssertMiss();
            
        end
        
        //Ensure LRU bits as expected
        LRUBitsE[0] = 3; LRUBitsE[1] = 2; LRUBitsE[2] = 1; LRUBitsE[3] = 0;
        AssertLRUBits();
        
        Tag = Tag - 100; //Undo extra increment from previous loop
        
        //Check that all data has been correctly stored, and have hits
        for (integer i = 0; i < E; i = i + 1) begin
            Block = Block + 4;
            #10;
            assert(Data === RepBlock[(Block*8) +: 32] && CacheMiss === 0) else $fatal(1, "Incorrectly reading data on hit\nData:          %h\nExpected Data: %h", Data, RepBlock[(Block*8) +: 32]);
            Tag = Tag - 100;
        end
        
        //Ensure LRU bits as expected
        LRUBitsE[0] = 0; LRUBitsE[1] = 1; LRUBitsE[2] = 2; LRUBitsE[3] = 3;
        AssertLRUBits();
        
        ActiveSet = 0; 
        RepReady = 1;
        
        //Ensure that cache remains stable when inactive
        for (int i = 0; i < 64; i = i + 1) begin
            Tag = Tag + 100;
            #10;
            AssertMiss();
            AssertLRUBits();
        end
        
        
        //Want to check if the LRU block was replaced
        //Need to look into the LRUBits object in simulation to confirm that Block 3 was replaced
        ActiveSet = 1; RepReady = 0; Tag = 1000;
        #10;
        AssertMiss();
        
        //Check replacement policy
        RepBlock = 512'hCCCCCCCC_EEEEEEEE_55555555_12345678_88888888_00AA00AA_BBBBBBBB_99999999_AAAAAAAA_FEDCBA98_FFFFFFFF_44444444_22222222_33333333_00001111_FFEEAABB;
        RepReady = 1; 
        
        LRUBitsE[0] = 1; LRUBitsE[1] = 2; LRUBitsE[2] = 3; LRUBitsE[3] = 0;
        
        //Ensure remains stable even when data takes > 1 clock cycle to arrive
        #100;
        AssertLRUBits();
        assert(Data === RepBlock[(Block*8) +: 32] && CacheMiss === 0) else $fatal(1, "Incorrectly reading data on hit\nData:          %h\nExpected Data: %h", Data, RepBlock[(Block*8) +: 32]);
                                                                           
        //Check that LRUBits update properly when a stored tag is accessed
        RepReady = 0; Tag = 600; //Block 1's tag
        LRUBitsE[0] = 2; LRUBitsE[1] = 0; LRUBitsE[2] = 3; LRUBitsE[3] = 1;
        #10;
        
        AssertLRUBits();
        
        $display("Simulation completed succesfully!");
        $finish;
        
        
    end


endmodule
