module instr_cache_set_multi_tb();

    localparam B          = 64;
    localparam NumTagBits = 26;
    localparam E          = 4;
    localparam words      = B/4;

    // Used Signals
    logic                  clk;
    logic                  reset;
    logic                  ActiveSet;
    logic                  rep_enable;
    logic [$clog2(B)-1:0]  block;
    logic [NumTagBits-1:0] tag;
    logic [NumTagBits-1:0] block_tags_e [E-1:0];
    logic [(B*8)-1:0]      RepBlock;
    logic [63:0]           RepWord;
    logic [31:0]           Data;
    logic                  CacheSetMiss;

    logic [1:0] lru_bits_e [3:0];

    integer cycles;

    // Device instantiation
    instr_cache_set_multi u_DUT (
        .clk_i                          (clk),
        .reset_i                        (reset),
        .ActiveSet                      (ActiveSet),
        .rep_enable_i                   (rep_enable),
        .block_i                        (block),
        .tag_i                          (tag),
        .RepWord                        (RepWord),
        .Data                           (Data),
        .CacheSetMiss                   (CacheSetMiss)
    );
    
    //Task for assering Cache misses produce the expected outputs
    task AssertMiss();
        assert(CacheSetMiss === 1) else $fatal(1, "Incorrectly indicated cache hit\nData Output: %b", Data);
    endtask
    
    //Task for checking lru_bits are as expected
    task Assertlru_bits();
        for (integer i = 0; i < E; i = i + 1) begin
            assert(u_DUT.lru_bits[i] === lru_bits_e[i]) else $fatal(1, "Unexpected LRU ordering. Incorrect LRU index: %d\nActual: %d\nExpected: %d", i, u_DUT.lru_bits[i], lru_bits_e[i]);
        end
            
    endtask
    
    //Clock
    always begin
        clk = ~clk; #5;
    end
    
    initial begin

        dump_setup;
        
        //Initialization
        reset = 1; clk = 0; ActiveSet = 0; rep_enable = 0; block = 0; tag = 0;
        RepBlock = 512'h55555555_44444444_FFEEAABB_00001111_BBBBBBBB_AAAAAAAA_FFFFFFFF_33333333_22222222_EEEEEEEE_CCCCCCCC_88888888_99999999_12345678_FEDCBA98_00AA00AA;
        #10; 
        reset = 0;
        
        #100;
        
        //After initialized with no input, should output same as a miss
        AssertMiss();
        
        ActiveSet = 1;  block = 0; tag = 500;
        #10;
        AssertMiss();
        
        //Fill up the set with data
        for (integer i = 0; i < E; i = i + 1) begin
            
            //Check data is ready one clock cycle after replacement indicated ready
            rep_enable = 1;
            cycles = 0;
            block_tags_e[i] = tag;
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
            tag =  tag + 100;
            rep_enable = 0;
            #10;
            AssertMiss();
            
        end
        
        //Undo extra increment from previous loop
        tag = tag - 100; 
        
        //Ensure LRU bits as expected
        for (int i = 0; i < E; i = i + 1) begin
            lru_bits_e[i] = (E-1-i);
        end
        Assertlru_bits();
        
        
        //Check that all data has been correctly stored, and have hits
        for (integer i = 0; i < E; i = i + 1) begin
            block = block + 4;
            #10;
            assert(Data === RepBlock[(block*8) +: 32] && CacheSetMiss === 0) else $fatal(1, "Incorrectly reading data on hit (test 1)\nData:          %h\nExpected Data: %h", Data, RepBlock[(block*8) +: 32]);
            tag = tag - 100;
        end
        
        //Ensure LRU bits as expected 
        for (integer i = 0; i < E; i = i + 1) begin
            //(reads started from block 3 and went down, so LRU matches index)
            lru_bits_e[i] = i;
        end
        Assertlru_bits();
        
        ActiveSet = 0; 
        rep_enable = 1;
        
        //Ensure that cache remains stable when inactive
        for (int i = 0; i < 64; i = i + 1) begin
            tag = tag + 100;
            #10;
            AssertMiss();
            Assertlru_bits();
        end
        
        
        //Check if the LRU block was replaced
        ActiveSet = 1; rep_enable = 0; tag = 1000;
        for (int i = 0; i < E; i = i + 1) begin
            if (lru_bits_e[i] == E-1) block_tags_e[i] = tag;
        end
        #10;
        AssertMiss();
        
        //Check replacement policy
        RepBlock = 512'hCCCCCCCC_EEEEEEEE_55555555_12345678_88888888_00AA00AA_BBBBBBBB_99999999_AAAAAAAA_FEDCBA98_FFFFFFFF_44444444_22222222_33333333_00001111_FFEEAABB;
        rep_enable = 1; 
        
        for (int i = 0; i < E; i = i + 1) begin
            if (i == E-1) lru_bits_e[i] = 0;
            else lru_bits_e[i] = lru_bits_e[i] + 1;
        end
        
        //Feed replacement words
        for (int i = 0; i < words/2; i = i + 1) begin
            RepWord = RepBlock[i*64 +: 64];
            #10;
        end
        
        
        wait(CacheSetMiss == 0);
        Assertlru_bits();
        assert(Data === RepBlock[(block*8) +: 32] && CacheSetMiss === 0) else $fatal(1, "Incorrectly reading data on hit (test 2)\nData:          %h\nExpected Data: %h", Data, RepBlock[(block*8) +: 32]);
                                                                           
        //Check that lru_bits update properly when a stored tag is accessed
        rep_enable = 0; tag = block_tags_e[1]; //block 1's tag
        for (int i = 0; i < E; i = i + 1) begin
            if (block_tags_e[i] == tag) lru_bits_e[i] = 0;
            else if (lru_bits_e[i] != E-1) lru_bits_e[i] = lru_bits_e[i] + 1;
        end
        #10;
        
        Assertlru_bits();
        
        $display("TEST PASSED");
        $finish;
        
        
    end


endmodule
