module instr_cache_set_multi_tb();

    localparam B          = 64;
    localparam NumTagBits = 26;
    localparam E          = 4;
    localparam words      = B/4;

    // Used Signals
    logic                  clk;
    logic                  reset;
    logic                  ActiveSet;
    logic                  RepEnable;
    logic [$clog2(B)-1:0]  Block;
    logic [NumTagBits-1:0] Tag;
    logic [NumTagBits-1:0] BlockTagsE [E-1:0];
    logic [(B*8)-1:0]      RepBlock;
    logic [63:0]           RepWord;
    logic [31:0]           Data;
    logic                  CacheSetMiss;

    logic [1:0] LRUBitsE [3:0];

    integer cycles;

    // Device instantiation
    instr_cache_set_multi u_DUT (
        .clk          (clk),
        .reset        (reset),
        .ActiveSet    (ActiveSet),
        .RepEnable    (RepEnable),
        .Block        (Block),
        .Tag          (Tag),
        .RepWord      (RepWord),
        .Data         (Data),
        .CacheSetMiss (CacheSetMiss)
    );
    
    //Task for assering Cache misses produce the expected outputs
    task AssertMiss();
        assert(CacheSetMiss === 1) else $fatal(1, "Incorrectly indicated cache hit\nData Output: %b", Data);
    endtask
    
    //Task for checking LRUBits are as expected
    task AssertLRUBits();
        for (integer i = 0; i < E; i = i + 1) begin
            assert(u_DUT.LRUBits[i] === LRUBitsE[i]) else $fatal(1, "Unexpected LRU ordering. Incorrect LRU index: %d\nActual: %d\nExpected: %d", i, u_DUT.LRUBits[i], LRUBitsE[i]);
        end
            
    endtask
    
    //Clock
    always begin
        clk = ~clk; #5;
    end
    
    initial begin

        dump_setup;
        
        //Initialization
        reset = 1; clk = 0; ActiveSet = 0; RepEnable = 0; Block = 0; Tag = 0;
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
            RepEnable = 1;
            cycles = 0;
            BlockTagsE[i] = Tag;
            for (integer n = 0; n < words/2; n = n + 1) begin
                RepWord = RepBlock[n*64 +: 64];
                $display("Currently Replacing word: %d, value is: %h", n, RepWord);
                cycles = cycles + 1;
                #10;
            end
            $display("Number of cycles for replacement: %d", cycles);
            //wait(CacheSetMiss == 0);
            
            assert(Data === RepBlock[31:0] && CacheSetMiss == 0) else $fatal(1, "Incorrect Data output on miss\nData:          %h\nExpected Data: %h", Data, RepBlock[31:0]);
            
            //Update tag
            Tag =  Tag + 100;
            RepEnable = 0;
            #10;
            AssertMiss();
            
        end
        
        //Undo extra increment from previous loop
        Tag = Tag - 100; 
        
        //Ensure LRU bits as expected
        for (int i = 0; i < E; i = i + 1) begin
            LRUBitsE[i] = (E-1-i);
        end
        AssertLRUBits();
        
        
        //Check that all data has been correctly stored, and have hits
        for (integer i = 0; i < E; i = i + 1) begin
            Block = Block + 4;
            #10;
            assert(Data === RepBlock[(Block*8) +: 32] && CacheSetMiss === 0) else $fatal(1, "Incorrectly reading data on hit (test 1)\nData:          %h\nExpected Data: %h", Data, RepBlock[(Block*8) +: 32]);
            Tag = Tag - 100;
        end
        
        //Ensure LRU bits as expected 
        for (integer i = 0; i < E; i = i + 1) begin
            //(reads started from block 3 and went down, so LRU matches index)
            LRUBitsE[i] = i;
        end
        AssertLRUBits();
        
        ActiveSet = 0; 
        RepEnable = 1;
        
        //Ensure that cache remains stable when inactive
        for (int i = 0; i < 64; i = i + 1) begin
            Tag = Tag + 100;
            #10;
            AssertMiss();
            AssertLRUBits();
        end
        
        
        //Check if the LRU block was replaced
        ActiveSet = 1; RepEnable = 0; Tag = 1000;
        for (int i = 0; i < E; i = i + 1) begin
            if (LRUBitsE[i] == E-1) BlockTagsE[i] = Tag;
        end
        #10;
        AssertMiss();
        
        //Check replacement policy
        RepBlock = 512'hCCCCCCCC_EEEEEEEE_55555555_12345678_88888888_00AA00AA_BBBBBBBB_99999999_AAAAAAAA_FEDCBA98_FFFFFFFF_44444444_22222222_33333333_00001111_FFEEAABB;
        RepEnable = 1; 
        
        for (int i = 0; i < E; i = i + 1) begin
            if (i == E-1) LRUBitsE[i] = 0;
            else LRUBitsE[i] = LRUBitsE[i] + 1;
        end
        
        //Feed replacement words
        for (int i = 0; i < words/2; i = i + 1) begin
            RepWord = RepBlock[i*64 +: 64];
            #10;
        end
        
        
        wait(CacheSetMiss == 0);
        AssertLRUBits();
        assert(Data === RepBlock[(Block*8) +: 32] && CacheSetMiss === 0) else $fatal(1, "Incorrectly reading data on hit (test 2)\nData:          %h\nExpected Data: %h", Data, RepBlock[(Block*8) +: 32]);
                                                                           
        //Check that LRUBits update properly when a stored tag is accessed
        RepEnable = 0; Tag = BlockTagsE[1]; //Block 1's tag
        for (int i = 0; i < E; i = i + 1) begin
            if (BlockTagsE[i] == Tag) LRUBitsE[i] = 0;
            else if (LRUBitsE[i] != E-1) LRUBitsE[i] = LRUBitsE[i] + 1;
        end
        #10;
        
        AssertLRUBits();
        
        $display("TEST PASSED");
        $finish;
        
        
    end


endmodule
