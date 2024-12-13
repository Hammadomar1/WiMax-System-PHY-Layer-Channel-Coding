// section 1 / Team 1
// Ahmed Fayez -- Hammad Omar -- Hassan Mohamed
// ECNG 4104, ASIC design Using CAD, Fall 2024
// 12 December 2024
// Description  : Package file that contains all the constants and SELF-CHECKING tasks.
// History: Final Release (2nd edition)

package Package_wimax;

//constants 
    timeunit 1ns;
    timeprecision 1ps;
    parameter time CLK_50_PERIOD                    = 20ns;
    parameter time CLK_50_HALF_PERIOD				= CLK_50_PERIOD / 2;
    parameter time CLK_100_PERIOD 				    = 10ns;
    parameter time CLK_100_HALF_PERIOD 				= CLK_100_PERIOD / 2;

    // randomizer parameter
    parameter logic [95:0] RANDOMIZER_INPUT 		= 96'hACBCD2114DAE1577C6DBF4C9;
    parameter logic [95:0] RANDOMIZER_OUTPUT		= 96'h558AC4A53A1724E163AC2BF9;
    parameter logic [1:15] SEED                     = 15'b011011100010101;
    // FEC-Encoder parameter
    parameter logic [95:0]  FEC_ENCODER_INPUT 		= 96'h558AC4A53A1724E163AC2BF9;
	parameter logic [191:0] FEC_ENDODER_OUTPUT 		= 192'h2833E48D392026D5B6DC5E4AF47ADD29494B6C89151348CA;
    
    // interleaver parameter
    parameter logic [191:0] INTERLEAVER_INPUT 		= 192'h2833E48D392026D5B6DC5E4AF47ADD29494B6C89151348CA;
	parameter logic [191:0] INTERLEAVER_OUTPUT 		= 192'h4B047DFA42F2A5D5F61C021A5851E9A309A24FD58086BD1E;

    
    // modulator parameters
	parameter logic [191:0] INPUT_MODULATION 		= 192'h4B047DFA42F2A5D5F61C021A5851E9A309A24FD58086BD1E;
 
    parameter logic [15:0] ZeroPointSeven		 	= 16'b0101_1010_1000_0010;
    parameter logic [15:0] NegativeZeroPointSeven   = 16'b1010_0101_0111_1110;

    parameter logic [1:0] MOD_OUTPUT [0:95]         = '{
        2'b01,
        2'b00,
        2'b10,
        2'b11,
        2'b00,
        2'b00,
        2'b01,
        2'b00,
        2'b01,
        2'b11,
        2'b11,
        2'b01,
        2'b11,
        2'b11,
        2'b10,
        2'b10,
        2'b01,
        2'b00,
        2'b00,
        2'b10,
        2'b11,
        2'b11,
        2'b00,
        2'b10,
        2'b10,
        2'b10,
        2'b01,
        2'b01,
        2'b11,
        2'b01,
        2'b01,
        2'b01,
        2'b11,
        2'b11,
        2'b01,
        2'b10,
        2'b00,
        2'b01,
        2'b11,
        2'b00,
        2'b00,
        2'b00,
        2'b00,
        2'b10,
        2'b00,
        2'b01,
        2'b10,
        2'b10,
        2'b01,
        2'b01,
        2'b10,
        2'b00,
        2'b01,
        2'b01,
        2'b00,
        2'b01,
        2'b11,
        2'b10,
        2'b10,
        2'b01,
        2'b10,
        2'b10,
        2'b00,
        2'b11,
        2'b00,
        2'b00,
        2'b10,
        2'b01,
        2'b10,
        2'b10,
        2'b00,
        2'b10,
        2'b01,
        2'b00,
        2'b11,
        2'b11,
        2'b11,
        2'b01,
        2'b01,
        2'b01,
        2'b10,
        2'b00,
        2'b00,
        2'b00,
        2'b10,
        2'b00,
        2'b01,
        2'b10,
        2'b10,
        2'b11,
        2'b11,
        2'b01,
        2'b00,
        2'b01,
        2'b11,
        2'b10
};



																	//**** Tasks ****//
    
 task automatic enter_96_inputs(
    input int start,
    input int STOP,
    input logic [95:0] data_in,
    output logic test_data
);
    for (int i = STOP; i >= start; i--) begin
        test_data = data_in[i];
        $display("Time=%0t | Sending bit %0d: %b", $time, i, test_data);
        #(CLK_50_PERIOD);
    end
endtask



    // enter192-bit output
    task automatic enter_192_outputs(
        input int start,
        input int STOP,
        output logic [191:0] data_out,
        input logic test_data
    );
        for (int i = STOP; i >= start; i--) begin
            data_out[i] = test_data;
            #(CLK_100_PERIOD);
        end
    endtask
	 
	 
	  //enter 192 bit input
    task automatic enter_192_inputs(
        input int start,
        input int STOP,
        input logic [191:0] data_in,
        output logic test_data
    );
        for (int i = STOP; i >= start; i--) begin
            test_data = data_in[i];
            #(CLK_100_PERIOD);
        end
    endtask

task checkOutput96(input logic [95:0] out_vec, input logic [95:0] expected_vec);
    if(out_vec === expected_vec) begin
        $display("Run Passed @ t = %0t", $time);
        $display("Expected: %h Got: %h", expected_vec, out_vec);
    end else begin
        $display("Run Failed @ t = %0t", $time);
        $display("Expected: %h Got: %h", expected_vec, out_vec);

    end
endtask
task checkOutput192(input logic [191:0] out_vec, input logic [191:0] expected_vec);
    if(out_vec === expected_vec) begin
        $display("Run Passed @ t = %0t", $time);
        $display("Expected: %h Got: %h", expected_vec, out_vec);
    end else begin
        $display("Run Failed @ t = %0t", $time);
        $display("Expected: %h Got: %h", expected_vec, out_vec);

    end
endtask
task checkModOutput(input logic [1:0] out_vec [0:95], input logic [1:0] expected_vec [0:95]);
    if(out_vec === expected_vec) begin
        $display("Run Passed @ t = %0t", $time);
        $display("Expected | Got");
        // foreach (out_vec[i]) begin
        //     $display("   %b    | %b", expected_vec[i], out_vec[i]);
        // end
        for(int i = 0; i < 96; i++) begin
            $display("   %b    | %b", expected_vec[i], out_vec[i]);
        end
    end else begin
        $display("Run Failed @ t = %0t", $time);
        $display("Expected | Got");
        // foreach (out_vec[i]) begin
        //     $display("   %b    | %b", expected_vec[i], out_vec[i]);
        // end
        for(int i = 0; i < 96; i++) begin
            $display("   %b    | %b", expected_vec[i], out_vec[i]);
        end

    end
endtask


endpackage