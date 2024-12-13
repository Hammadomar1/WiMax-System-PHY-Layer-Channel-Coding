// section 1 / Team 1
// Ahmed Fayez -- Hammad Omar -- Hassan Mohamed
// ECNG 4104, ASIC design Using CAD, Fall 2024
// 12 December 2024
// Description  : Interleaver top instantiation module. It instantiates the interleaver and ping pong buffer modules. 
// History: Final Release

module interleaver_top #(
    parameter Ncbps = 192,   // Coded Bits Per Second
    parameter Ncpc  = 2,     // Coded bits per carrier = 2 (QPSK)
    parameter s     = Ncpc/2,
    parameter d     = 16
) (
    input  logic clk,
    input  logic reset_N,
    input  logic data_in,
    input  logic ready_in, 
    input  logic valid_in,
    
    output logic data_out,
    output logic valid_out,
    output logic ready_out
);

logic [7:0] data_out_index;
logic       ready_interleaver;
logic       valid_interleaver;
logic [7:0] rdaddress;
logic       data_interleaved;

interleaver Interleaver_inst (
    .clk(clk),
    .resetN(reset_N),
    .ready_buffer(ready_out),
    .valid_fec(valid_in),
    .data_in(data_in),
    .data_out(data_interleaved),
    .data_out_index(data_out_index),
    .ready_interleaver(ready_interleaver),
    .valid_interleaver(valid_interleaver)
);

PPBuffer PingPongBuffer_inst (
    .clk(clk),
    .resetN(reset_N),
    .wraddress(data_out_index),
    .wrdata(data_interleaved),
    .rdaddress(rdaddress),
    .valid_in(valid_interleaver),
    .ready_in(ready_in),    // Corrected by fayez
    .q(data_out),
    .valid_out(valid_out),
    .ready_out(ready_out)
);

// ReadControl ReadControl_inst (
//     .clk(clk),
//     .resetN(resetN),
//     .valid_out(valid_out),
//     .ready_out(ready_out),
//     .rdaddress(rdaddress)
// );

always_ff @(posedge clk or negedge reset_N) begin
    if(reset_N == 1'b0) begin
        rdaddress <= '0;
    end else if((valid_in) == 1'b1) begin
        if(rdaddress == 191) begin
            rdaddress <= '0;
        end else begin
            rdaddress <= rdaddress + 1'b1;
        end
    end
end

endmodule