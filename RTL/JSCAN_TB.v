`timescale 1ns / 1ps

module tb_top_3d_jscan;

    // ----------------------------------------------------------------
    // Signals
    // ----------------------------------------------------------------
    reg  scan_clk;
    reg  reset_n;
    reg  scan_in;
    reg  test_enable;
    wire fault_flag;

    // ----------------------------------------------------------------
    // Device Under Test (DUT)
    // ----------------------------------------------------------------
    top_3d_jscan uut (
        .scan_clk(scan_clk),
        .reset_n(reset_n),
        .scan_in(scan_in),
        .test_enable(test_enable),
        .fault_flag(fault_flag)
    );

    // ----------------------------------------------------------------
    // Clock Generation (100 MHz)
    // ----------------------------------------------------------------
    initial begin
        scan_clk = 0;
        forever #5 scan_clk = ~scan_clk;
    end

    // ----------------------------------------------------------------
    // Test Sequence
    // ----------------------------------------------------------------
    initial begin
        // Initialize Inputs
        reset_n = 1'b1;
        scan_in = 1'b0;
        test_enable = 1'b0;

        $display("--- Starting 3D-JSCAN Corner Case Verification ---");

        $display("[Time: %0t] Case 1: Applying Asynchronous Reset", $time);
        #7 reset_n = 1'b0; // Drop reset mid-cycle
        #10 reset_n = 1'b1;
        
        // ------------------------------------------------------------
        // CASE 2: Normal Operation & Tier Rollover
        // ------------------------------------------------------------
        $display("[Time: %0t] Case 2: Mode and Tier/Col Rollover", $time);
        test_enable = 1'b1;
        
        // Feed a specific sequence to scan_in to build MISR signatures
        repeat(30) begin
            @(negedge scan_clk);
            scan_in = $random % 2; 
        end
        // By 30 cycles, tier_sel (01->10->11->01) and col_addr (4-bit rollover) 
        // will have looped multiple times.

        // ------------------------------------------------------------
        // CASE 3: Test Enable De-assertion (Pause/Freeze State)
        // ------------------------------------------------------------
        $display("[Time: %0t] Case 3: Freezing State via test_enable=0", $time);
        @(negedge scan_clk);
        test_enable = 1'b0; // Logic should freeze, shift_en/capture_en hold
        #40; 
        
        // ------------------------------------------------------------
        // CASE 4: Forced SAS Mode (Serial Architecture Scan)
        // ------------------------------------------------------------
        // GTC hardcodes mode_sel to 2'b10. We force it to 2'b00 to test MSS blocks.
        $display("[Time: %0t] Case 4: Forcing SAS Mode (mode_sel = 00)", $time);
        force uut.GTC.mode_sel = 2'b00;
        test_enable = 1'b1;
        
        // Shift 8 bits to fill the 8-bit scan_chain in mss_block
        repeat(12) begin
            @(negedge scan_clk);
            scan_in = ~scan_in; // Alternating 101010 pattern
        end

        // ------------------------------------------------------------
        // CASE 5: Forced RAS Mode (Random Access Scan)
        // ------------------------------------------------------------
        // Force mode_sel to 2'b01 to test PRAS blocks.
        // PRAS grid is hardcoded to 16'h0000 at reset. We force internal grids 
        // to non-zero values to verify dynamic bit selection via col_addr.
        $display("[Time: %0t] Case 5: Forcing RAS Mode (mode_sel = 01)", $time);
        force uut.GTC.mode_sel = 2'b01;
        force uut.TIER1.PRAS.grid = 16'hA5A5;
        force uut.TIER2.PRAS.grid = 16'h5A5A;
        force uut.TIER3.PRAS.grid = 16'hFFFF;
        
        repeat(20) begin
            @(negedge scan_clk);
        end

        // Release forces
        release uut.GTC.mode_sel;
        release uut.TIER1.PRAS.grid;
        release uut.TIER2.PRAS.grid;
        release uut.TIER3.PRAS.grid;

        // ------------------------------------------------------------
        // CASE 6: Mid-Operation Reset Glitch
        // ------------------------------------------------------------
        $display("[Time: %0t] Case 6: Mid-operation async reset", $time);
        #3 reset_n = 1'b0;
        #5 reset_n = 1'b1;
        #20;

        $display("--- Verification Complete ---");
        $finish;
    end

    // ----------------------------------------------------------------
    // Waveform Dumping (for GTKWave / ModelSim / Vivado)
    // ----------------------------------------------------------------
    initial begin
        $dumpfile("jscan_tb.vcd");
        $dumpvars(0, tb_top_3d_jscan);
    end

endmodule