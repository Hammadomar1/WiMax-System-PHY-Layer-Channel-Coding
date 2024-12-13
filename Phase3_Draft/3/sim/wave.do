onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Verifier
add wave -noupdate /wimax_max_top_tb/clk_ref
add wave -noupdate /wimax_max_top_tb/reset_N
add wave -noupdate /wimax_max_top_tb/load
add wave -noupdate /wimax_max_top_tb/en
add wave -noupdate /wimax_max_top_tb/prbs_pass
add wave -noupdate /wimax_max_top_tb/fec_pass
add wave -noupdate /wimax_max_top_tb/interleaver_pass
add wave -noupdate /wimax_max_top_tb/modulator_pass
add wave -noupdate -divider PLL
add wave -noupdate -color {Dark Orchid} /wimax_max_top_tb/dut/clk_50
add wave -noupdate -color {Dark Orchid} /wimax_max_top_tb/dut/clk_100
add wave -noupdate -color {Dark Orchid} /wimax_max_top_tb/dut/pll_locked
add wave -noupdate -divider PRBS
add wave -noupdate -color Cyan /wimax_max_top_tb/dut/randomizer_data_in
add wave -noupdate -color Cyan /wimax_max_top_tb/dut/randomizer_valid_out
add wave -noupdate -color Cyan /wimax_max_top_tb/dut/randomizer_out_counter
add wave -noupdate -color Cyan /wimax_max_top_tb/dut/randomizer_ready_out
add wave -noupdate -color Cyan /wimax_max_top_tb/dut/randomizer_data_out
add wave -noupdate -color Cyan /wimax_max_top_tb/dut/randomizer_out_error_count
add wave -noupdate -color Cyan /wimax_max_top_tb/dut/WiMAX_PHY_U0/randomizer_U0/r_reg
add wave -noupdate -divider FEC
add wave -noupdate -color Salmon /wimax_max_top_tb/dut/FEC_valid_out
add wave -noupdate -color Salmon /wimax_max_top_tb/dut/FEC_counter
add wave -noupdate -color Salmon /wimax_max_top_tb/dut/FEC_data_out
add wave -noupdate -color Salmon /wimax_max_top_tb/dut/FEC_out_error_count
add wave -noupdate -divider Interleaver
add wave -noupdate -color Violet /wimax_max_top_tb/dut/interleaver_valid_out
add wave -noupdate -color Violet /wimax_max_top_tb/dut/interleaver_counter
add wave -noupdate -color Violet /wimax_max_top_tb/dut/interleaver_out_error_count
add wave -noupdate -color Violet /wimax_max_top_tb/dut/interleaver_data_out
add wave -noupdate -color Violet /wimax_max_top_tb/dut/WiMAX_PHY_U0/ready_interleaver
add wave -noupdate -divider Modulator
add wave -noupdate -color Yellow -radix decimal /wimax_max_top_tb/dut/mod_I_comp
add wave -noupdate -color Yellow -radix decimal /wimax_max_top_tb/dut/mod_Q_comp
add wave -noupdate -color Yellow /wimax_max_top_tb/dut/mod_valid_out
add wave -noupdate -color Yellow /wimax_max_top_tb/dut/mod_out_error_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11269061 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {26523 ns}
