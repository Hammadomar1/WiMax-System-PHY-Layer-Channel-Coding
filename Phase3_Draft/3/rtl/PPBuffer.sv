// section 1 / Team 1
// Ahmed Fayez -- Hammad Omar -- Hassan Mohamed
// ECNG 4104, ASIC design Using CAD, Fall 2024
// 12 December 2024
// Description: Ping Poing buffer top module. It instantiates the control module and two DPR banks.
// History: Final Release

module PPBuffer (
    input  logic       clk,
    input  logic       resetN, 
    input  logic [7:0] wraddress,
    input  logic       wrdata,
    // input  logic q_A,
    input  logic [7:0] rdaddress,
    // input  logic wrdata_B,
    input  logic       valid_in,
    input  logic       ready_in,
    output logic       q,
    output logic       valid_out,
    output logic       ready_out
);

logic q_A;
logic q_B;
logic rden_A;
logic rden_B;
logic wren_A;
logic wren_B;

PPBufferControl BufferControl (
    .clk(clk),
    .resetN(resetN),
    .valid_in(valid_in),
    .q_A(q_A),
    .q_B(q_B),
    .rden_A(rden_A),
    .rden_B(rden_B),
    .wren_A(wren_A),
    .wren_B(wren_B),
    .ready_in(ready_in),    
    .ready_out(ready_out),
    .valid_out(valid_out),
    .q(q)
);

// DPR Banks
SDPR BankA (
    .clock(clk),
    .data(wrdata),
    .wraddress(wraddress),
    .wren(wren_A),
    .rdaddress(rdaddress),
    .rden(rden_A),
    .q(q_A)
);

SDPR BankB (
    .clock(clk),
    .data(wrdata),
    .wraddress(wraddress),
    .wren(wren_B),
    .rdaddress(rdaddress),
    .rden(rden_B),
    .q(q_B)
);
endmodule