// section 1 / Team 1
// Ahmed Fayez -- Hammad Omar -- Hassan Mohamed
// ECNG 4104, ASIC design Using CAD, Fall 2024
// 12 December 2024
// Description  : Ping Poing buffer control module. It is FSM-based. It controls the read and write 
//         operations of the two DPR banks and switching between them.
// History: Final Release

module PPBufferControl (
    input  logic clk,
    input  logic resetN,
    // input  logic wrdata_A,
    output logic wren_A,
    // input  logic wraddress_A,
    // input  logic rdaddress_A,
    output logic rden_A,
    input  logic q_A,
	 
    output logic wren_B,
    output logic rden_B,
    input  logic q_B,
    
    input  logic valid_in,
    input  logic ready_in,
    output logic ready_out,
    output logic valid_out,
    output logic q

);

logic       q_sel;

logic       bit_counter_resetN;
logic [7:0] bit_counter;
logic       count_en;

logic       clear_counter_resetN;
logic       clear_counter;
logic       clear_count_en;

// logic       valid_out;
typedef enum logic [1:0] {
    IDLE,
    CLEAR,
    WRITE_A,
    WRITE_B
} BufferControlState_t;

BufferControlState_t state, state_next;

// State Register
always_ff @(posedge clk or negedge resetN) begin
    if(resetN == 1'b0) begin
        state <= IDLE;
    end else begin
        state <= state_next;
    end
end

// Next State Logic
always_comb begin
    case(state)
        IDLE: begin
            state_next = CLEAR;
        end
        CLEAR: begin
            if((clear_counter && valid_in) == 1'b1)  begin
                state_next = WRITE_A;
            end else begin
                state_next = CLEAR;
            end
        end
        WRITE_A: begin
            if((bit_counter == 8'd191) && (valid_in && ready_in)) begin
                state_next = WRITE_B;
            end else begin
                state_next = WRITE_A;
            end
        end
        WRITE_B: begin
            if((bit_counter == 8'd191) && (valid_in && ready_in)) begin
                state_next = WRITE_A;
            end else begin
                state_next = WRITE_B;
            end
        end
    
    endcase
end

// Output logic
always_comb begin
    case(state)
        IDLE: begin
            rden_A             = 1'b0;
            rden_B             = 1'b0;
            wren_A             = 1'b0;
            wren_B             = 1'b0;
            q_sel              = 1'b0;

            bit_counter_resetN = 1'b0;
            count_en           = 1'b0;
            clear_count_en     = 1'b0;
            clear_counter_resetN = 1'b0;

            ready_out          = 1'b0;
        end
        CLEAR: begin
            rden_A             = 1'b1;
            rden_B             = 1'b1;
            wren_A             = 1'b1;
            wren_B             = 1'b1;
            q_sel              = 1'b0;

            bit_counter_resetN = 1'b0;
            count_en           = 1'b0;
            clear_count_en     = 1'b1;
            clear_counter_resetN = 1'b1;

            ready_out          = (clear_counter == 1'b1);
        end
        WRITE_A: begin
            rden_A             = 1'b0;
            rden_B             = 1'b1;
            wren_A             = 1'b1;
            wren_B             = 1'b0;
            q_sel              = 1'b1;

            bit_counter_resetN = 1'b1;
            count_en           = 1'b1;
            clear_count_en     = 1'b0;
            clear_counter_resetN = 1'b0;

            ready_out          = 1'b1;
            
        end
        WRITE_B: begin
            rden_A             = 1'b1;
            rden_B             = 1'b0;
            wren_A             = 1'b0;
            wren_B             = 1'b1;
            q_sel              = 1'b0;

            bit_counter_resetN = 1'b1;
            count_en           = 1'b1;
            clear_count_en     = 1'b0;
            clear_counter_resetN = 1'b0;

            ready_out          = 1'b1;
        end
    endcase

    if (q_sel == 1'b1) begin
        q = q_B;
    end else begin
        q = q_A;
    end
end

always_ff @(posedge clk or negedge bit_counter_resetN) begin
    if(bit_counter_resetN == 1'b0) begin
        bit_counter <= '0;
        valid_out <= 1'b0;
    end else if(count_en == 1'b1) begin
        if(bit_counter == 191) begin 
            bit_counter <= '0;
            valid_out <= 1'b1;
        end else begin
            bit_counter <= bit_counter + 1'b1;
        end
    end
end

always_ff @(posedge clk or negedge clear_counter_resetN) begin
    if(clear_counter_resetN == 1'b0) begin
        clear_counter <= '0;
    end else if(clear_count_en == 1'b1) begin

        if(clear_counter == 1) clear_counter <= '1;
        else                   clear_counter <= clear_counter + 1'b1;
    end
end

// always_ff @(posedge clk or negedge resetN) begin
//     if(resetN == 1'b0) begin
//         valid_out_ff <= 1'b0;
//     end else begin
//         valid_out_ff <= valid_out;
//     end
// end

endmodule