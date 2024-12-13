// section 1 / Team 1
// Ahmed Fayez -- Hammad Omar -- Hassan Mohamed
// ECNG 4104, ASIC design Using CAD, Fall 2024
// 12 December 2024
// Description  : PRBS module that generates a pseudo random output to 
//                begin the WiMAX encoding operation
// History: Final Release (2nd edition)

import Package_wimax::*;

module prbs(
    input  logic        data_in,
    input  logic        clk,
    input  logic        reset_N,
    input  logic        load,
    input  logic        en,
    input  logic        ready_fec,  // Ready in from FEC
    input  logic        valid_in,   // Valid in from TB
    output logic        valid_out,  // Valid out to FEC
    output logic        ready_prbs, // Ready out to TB
    output logic        data_out
);
    logic [1:15] r_reg;
    logic [1:15] r_next;

    logic lfsrXOR;
    logic valid_out_ff;
    logic [6:0] counter; // 7 bits counter (128) to reach 96 and to reload 

    // Register inference 
    always_ff @(posedge clk or negedge reset_N)
    begin
        if(reset_N == 1'b0) 
        begin
            r_reg <= '0;
            ready_prbs <= 1'b0;
            valid_out <= 1'b0;
            counter <= '0;
            data_out <= '0;
        end
        else if(load == 1'b1)
        begin
            r_reg <= SEED;
            ready_prbs <= 1'b1;
            valid_out <= 1'b0;
        end
        else if((en /*&& ready_fec */&& valid_in) == 1'b1)
        begin
            r_reg <= r_next;
            ready_prbs <= 1'b1;
            valid_out <= 1'b1;
            data_out <= data_in ^ lfsrXOR;
            // counter <= 7'b0;

                if(counter == 7'd95) begin
                    counter <= 0;
                    r_reg <= SEED;
                end else begin
                        counter <= counter + 1'b1;
                end
        end

    end

    always_comb
    begin
        lfsrXOR = r_reg[15] ^ r_reg[14];
        // Next state logic
        r_next = {lfsrXOR, r_reg[1:14]};
    end

endmodule