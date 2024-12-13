// section 1 / Team 1
// Ahmed Fayez -- Hammad Omar -- Hassan Mohamed
// ECNG 4104, ASIC design Using CAD, Fall 2024
// 12 December 2024
// Description  : Encoder core module that takes in 96 bits serially and produces 192 bits
// History: Final Release (2nd edition)
module fec_encoder_wimax_phy (
    input  logic clk_50,                 
    input  logic clk_100,        
    input  logic reset_N,                   //active-low reset 
    input  logic randomizer_output_valid,   //valid_in signal for data from randomizer is ready
    input  logic ready_in,                  //ready signal from interleaver indicating it can accept data
    input  logic data_in,                   //input data bit from randomizer
    output logic valid_out,                 //valid signal to interleaver indicating output data is valid
    output logic data_out,                  //output data bit after FEC encoding
    output logic ready_out                  //ready signal to randomizer indicating FEC encoder is ready
);

    // Local parameters defining buffer sizes
    localparam BUFFER_SIZE  = 96;   //buffer size for input data //number of bits per block
    localparam BUFFER_SIZE2 = 192;  //buffer size for output data

    // Internal signals
    logic [5:0] shift_register;     
    logic [5:0] shift_register2;    
    int counter_input;              //counter for tracking number of input bits
    int counter_output;             // Counter for tracking number of output bits
    logic tail_flag_done;           //to indicate tail bits have been processed
    logic FEC_encoder_out_valid;    //valid signal for output data
    logic Ping_Pong_flag;           //flag to toggle between two buffers (ping-pong buffering)

    //FSM for input processing
    typedef enum logic [1:0] {
        IDLE,               //waiting for data from randomizer
        BUFFERING_INPUT,    //buffering input data
        PINGPONG            //processing data and toggling between buffers (ping - pong)
    } input_state_type;

    input_state_type input_state;   

    //FSM for output processing
    typedef enum logic [1:0] {
        OUTPUT_IDLE,        
        X,                  //first encoder output
        Y                   //second encoder output
    } output_state_type;

    output_state_type output_state; 

    //dpr signals
    logic [7:0] address_a;  
    logic [7:0] address_b;  
    logic [0:0] data_a;    
    logic [0:0] data_b;     
    logic wren_a;        
    logic wren_b;         
    logic clock;         
    logic [0:0] q_a;       
    logic [0:0] q_b;

    //FEC_DPR instantiation
    FEC_DPR fec_encoder_DPR (
        .address_a(address_a),
        .address_b(address_b),
        .clock(clock),
        .data_a(data_a),
        .data_b(data_b),
        .wren_a(wren_a),
        .wren_b(wren_b),
        .q_a(q_a),
        .q_b(q_b)
    );

    //RAM signals assignments
    assign clock = clk_50; ///50 MHz clock for RAM operations

    //for writing to RAM: address depends on Ping_Pong_flag (for ping-pong buffering)
    //when Ping_Pong_flag is high, write to the second half of the RAM (addresses 96-191)
    assign address_a = Ping_Pong_flag ? (counter_input + 8'd96) : counter_input;

    //for reading from RAM// address is given by counter_output
    assign address_b = counter_output[7:0]; 

    assign wren_a = randomizer_output_valid; 
    assign data_a[0] = data_in;            
    assign wren_b = 1'b0;      //port B is read-only

    assign valid_out = FEC_encoder_out_valid; //output valid signal to interleaver

    //ready signal to randomizer: high when FEC encoder can accept data
    //FEC Encoder is ready when in BUFFERING_INPUT or PINGPONG state and counter_input is less than 96
    assign ready_out = ((input_state == BUFFERING_INPUT && counter_input < BUFFER_SIZE) ||
                        (input_state == PINGPONG && counter_input < BUFFER_SIZE));


    ///// State Machine 1: Input FSM and Data Handling /////
    always_ff @(posedge clk_50 or negedge reset_N) begin
        if (!reset_N) begin 
            counter_input    <= 0;
            shift_register   <= 6'b0;
            shift_register2  <= 6'b0;
            counter_output   <= 0;
            tail_flag_done   <= 1'b0;
            Ping_Pong_flag   <= 1'b0;
            input_state      <= IDLE;
        end else if (!ready_in) begin
            //if interleaver is not ready, stay in IDLE
            input_state <= IDLE;
        end else begin
            //state machine transitions
            case (input_state)
                IDLE: begin
                    if (!randomizer_output_valid) begin
                        // no valid input data, remain IDLE
                        counter_input    <= 0;
                        counter_output   <= 0;
                        tail_flag_done   <= 1'b0;
                        shift_register   <= 6'b0;
                        shift_register2  <= 6'b0;
                        Ping_Pong_flag   <= 1'b0;
                        input_state      <= IDLE;
                    end else begin
                        // if valid input data available, start buffering input
                        counter_input <= counter_input + 1;
                        input_state    <= BUFFERING_INPUT;
                    end
                end

                BUFFERING_INPUT: begin
                    //this state is buffering input data into RAM
                    if (counter_input >= 90 && counter_input <= 95) begin
                        // For the last 6 bits (tail bits), store them into shift_register for tail biting
                        shift_register[counter_input - 90] <= data_in;
                    end

                    if (counter_input < BUFFER_SIZE - 1) begin
                        //continue buffering input data
                        counter_input <= counter_input + 1;
                    end else begin
                        //reached 96, then transition to PINGPONG state
                        counter_input     <= 0;
                        input_state       <= PINGPONG;
                        tail_flag_done    <= 1'b1;         // Tail bits have been processed
                        counter_output    <= counter_output + 1;
                        Ping_Pong_flag    <= 1'b1;         // Toggle Ping_Pong_flag to switch buffer
                    end
                end

                PINGPONG: begin
                    //processing data from RAM and performing convolutional encoding
                    //handling tail biting and shift registers

                    if (counter_output == BUFFER_SIZE2) begin
                        //when all output bits have been processed
  
                        shift_register   <= 6'b0;
                        shift_register2  <= 6'b0;
                        counter_output   <= 0;
                        counter_input    <= 0;
                        Ping_Pong_flag   <= 1'b0;
                        input_state      <= IDLE;
                    end

                    //uppdate shift registers with new data from RAM
                    if (counter_input >= 90 && counter_input <= 95) begin
                        //// tail biting //store last 6 bits into shift register
                        if (!Ping_Pong_flag) begin
                            shift_register[counter_input - 90] <= data_in;
                        end else begin
                            shift_register2[counter_input - 90] <= data_in;
                        end
                    end

                    if (counter_output < BUFFER_SIZE && Ping_Pong_flag) begin
                        //when Ping_Pong_flag is high and counter_output is less than BUFFER_SIZE
                        //shift in new bit into shift_register and increment counters
                        shift_register  <= {q_b[0], shift_register[5:1]}; // Shift in q_b[0] from RAM into shift_register
                        counter_output  <= counter_output + 1;
                        if (counter_input < BUFFER_SIZE - 1) begin
                            counter_input <= counter_input + 1;
                        end
                    end else if (!Ping_Pong_flag && counter_output >= BUFFER_SIZE && counter_output < BUFFER_SIZE2) begin
                        //when Ping_Pong_flag is low and counter_output is between 96 and 192
                        //shift in new bit into shift_register2
                        shift_register2 <= {q_b[0], shift_register2[5:1]}; //shift in q_b[0] from RAM into shift_register2
                        counter_output  <= counter_output + 1;
                        if (counter_input < BUFFER_SIZE - 1) begin
                            counter_input <= counter_input + 1;
                        end
                    end else if (counter_output == BUFFER_SIZE2) begin
                        //all data processed then reset counters
                        counter_output <= 0;
                        counter_input  <= counter_input + 1;
                    end

                    if ((counter_output == BUFFER_SIZE || counter_output == BUFFER_SIZE2) && !randomizer_output_valid) begin
                        ////reset counter_output if no new data is available
                        counter_output <= 0;
                        input_state    <= PINGPONG;
                    end

                    if (counter_input == BUFFER_SIZE - 1) begin
                        //when input buffer is full, toggle Ping_Pong_flag and reset counter_input
                        Ping_Pong_flag <= ~Ping_Pong_flag; //toggle buffer selection
                        counter_input  <= 0;

                        if (counter_output < BUFFER_SIZE2 - 1) begin
                            counter_output <= counter_output + 1;
                        end else begin
                            counter_output <= 0;
                        end
                    end

                    if (counter_output == BUFFER_SIZE2 - 1) begin
                        //when output buffer is full, reset counter_output
                        counter_output <= 0;
                    end
                end

                default: input_state <= IDLE; 
            endcase
        end
    end
	 
	 
	 
    // combinational output logic //compute data_out based on shift registers and current state
    always_comb begin
        if (Ping_Pong_flag) begin
            // When Ping_Pong_flag is high
            if ((output_state == OUTPUT_IDLE && tail_flag_done) || output_state == X) begin
                //c.ompute X output
                data_out = q_b[0] ^ shift_register[0] ^ shift_register[3] ^ shift_register[4] ^ shift_register[5];
            end else if (output_state == Y) begin
                ////compute Y output 
                data_out = q_b[0] ^ shift_register[0] ^ shift_register[1] ^ shift_register[3] ^ shift_register[4];
            end else begin
                data_out = 1'b0; // Default output when not in X or Y state
            end
        end else begin
            //ping_Pong_flag is low
            if ((output_state == OUTPUT_IDLE && tail_flag_done) || output_state == X) begin
                //compute theX output
                data_out = q_b[0] ^ shift_register2[0] ^ shift_register2[3] ^ shift_register2[4] ^ shift_register2[5];
            end else if (output_state == Y) begin
                //compute the Y output
                data_out = q_b[0] ^ shift_register2[0] ^ shift_register2[1] ^ shift_register2[3] ^ shift_register2[4];
            end else begin
                data_out = 1'b0; // Default output when not in X or Y state
            end
        end
    end

    //output valid signal: high when in PINGPONG state//
    assign FEC_encoder_out_valid = (input_state == PINGPONG) ? 1'b1 : 1'b0;
	 
	 

			///// State Machine 2: Output FSM /////
																				
																				
    //this fsm controls the output data timing and state transitions at  encoding//
	 
	 
    always_ff @(posedge clk_100 or negedge reset_N) begin
        if (!reset_N) begin
            output_state <= OUTPUT_IDLE;
        end else begin
            if (tail_flag_done) begin
                //only proceed if tail bits have been processed
                case (output_state)
                    OUTPUT_IDLE: begin
                        if (counter_output == 1) begin
                            output_state <= Y;
                        end else begin
                            output_state <= OUTPUT_IDLE; 
                        end
                    end

                    X: begin
                        if (counter_output <= BUFFER_SIZE2) begin
                            //continue outputting X bits
                            output_state <= Y; //go Y
                        end else begin
                            output_state <= X; //remain in X 
                        end
                    end

                    Y: begin
                        if (!FEC_encoder_out_valid && (counter_output == BUFFER_SIZE + 1 || counter_output == BUFFER_SIZE2 + 1)) begin
                            //if output not valid and specific counter_output values, go to idle
                            output_state <= OUTPUT_IDLE;
                        end else begin
                            output_state <= Y; 
                        end

                        if (counter_output < BUFFER_SIZE2 && FEC_encoder_out_valid) begin
                            //if output valid and counter_output less than BUFFER_SIZE2, go X 
                            output_state <= X;
                        end else begin
                            output_state <= OUTPUT_IDLE; 
                        end
                    end

                    default: output_state <= OUTPUT_IDLE;
                endcase
            end
        end
    end

	 
endmodule
