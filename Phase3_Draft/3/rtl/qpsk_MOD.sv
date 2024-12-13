// section 1 / Team 1
// Ahmed Fayez -- Hammad Omar -- Hassan Mohamed
// ECNG 4104, ASIC design Using CAD, Fall 2024
// 12 December 2024
// Description  : Modulator module that takes in 192 bits serially and produces a constellation map
//                working on 2 bits at a time
// History: Final Release (2nd edition)

module qpsk_MOD (
    input  logic        Reset_N, // Reset (active low)
    input  logic        clk_100, // 100 Mhz clock
    // input  logic        clk_50, // 50 Mhz clock
    input  logic        valid_in, // valid input coming from interleaver
    input  logic        ready_in, // ready input coming from top module TB
    input  logic        data_in, // data coming in serially from TB
    output logic        valid_out, // valid output going to top module TB
    output logic        ready_out, // ready output going to interleaver
    output logic [15:0] I_comp, // output of Modulator (16 bits) to represent I component
    output logic [15:0] Q_comp // output of Modulator (16 bits) to represent Q component
   // output logic        b0 // to create a task in the TB for self checking {b0,data_in} 
);

    // logic b0, 
    logic bit_count; // Internal signals
    logic b0; // Internal signal
    
    const logic [15:0] POS_A = 16'b0101_1010_1000_0010; // 0.707 in Q15 format
    const logic [15:0] NEG_A = 16'b1010_0101_0111_1110; // -0.707 in Q15 format

    always_ff @(posedge clk_100 or negedge Reset_N) begin
        if (Reset_N == 1'b0) begin
            bit_count     <= 1'b1;
//            valid_out  <= 1'b0; // Modulator cannot send data when Reset is active -> valid going to TOP is 0
//            ready_out <= 1'b0; // Modulator cannot accept data when Reset is active -> ready going to INTER is 0
            b0 <= 1'b0; 
            
        end else begin
            // if(valid_in == 1'b1) begin
            //     valid_counter <= 1'b1;
            // end else begin
            //     valid_counter <= 1'b0;
            // end
            if (ready_in == 1'b1 && valid_in == 1'b1 /*&& valid_counter == 1'b1*/) begin //  once i get ready from TOP tb
//                ready_out <= 1'b1; // ready going out from modulator to interleaver to take in data

                if (bit_count == 1'b1) begin
                    b0    <= data_in; // store the first bit of data in
                    bit_count <= ~bit_count; // negate bit count (make it = 1)
                end else if (bit_count == 1'b0) begin
                    bit_count     <= ~bit_count; // make bit count 0 to take the next bit
//                    valid_out  <= 1'b1; // to maintain that the valid output of modulator is 1 to top TB

                end
            end
    end
    end

    always_ff @(posedge clk_100 or negedge Reset_N) begin

        if(Reset_N == 1'b0) begin
            I_comp = 16'b0;
            Q_comp = 16'b0;
            valid_out <= 1'b0;
            //  valid_out  <= 1'b0; // Modulator cannot send data when Reset is active -> valid going to TOP is 0
            // ready_out <= 1'b0; // Modulator cannot accept data when Reset is active -> ready going to INTER is 0
        end else if((ready_in == 1'b1) && (valid_in == 1'b1) && (bit_count == 1'b0)) begin // TB ready but  still not asserted
        
                        // ready_out <= 1'b1; // Added by fayez.l
                            case ({b0,data_in})

                        2'b00: begin I_comp <= POS_A; Q_comp <= POS_A; end // 00 -> (+0.707, +0.707)
                        2'b01: begin I_comp <= POS_A; Q_comp <= NEG_A; end // 01 -> (+0.707, -0.707)
                        2'b10: begin I_comp <= NEG_A; Q_comp <= POS_A; end // 10 -> (-0.707, +0.707)
                        2'b11: begin I_comp <= NEG_A; Q_comp <= NEG_A; end // 11 -> (-0.707, -0.707)
                       // default: begin I_comp <= 16'b0; Q_comp <= 16'b0; end
                            
                            endcase

                    valid_out <= 1'b1; // Modulator can send data to TB --> valid tb will be 1
                    

                    // if( {b0,data_in} == (2'b00 || 2'b01 || 2'b10 || 2'b11) )  begin
                    //     valid_out <= 1'b1;
                    // end else begin
                    //     valid_out <= 1'b0;
                    // end
                end else begin // top testbench is NOT ready
                // valid_out  <= 1'b0; // cannot send data to TB --> valid tb will be 0
                // ready_out <= 1'b0; // cannot take data from interleaver --> ready interleaver will be 0
              end
        end
        
    assign ready_out = (Reset_N && ready_in); // Modulator is always ready to take in data from interleaver
    // assign valid_out = (valid_in && ~bit_count); // Modulator can send data to TB only when it has valid data and bit count is 1

endmodule