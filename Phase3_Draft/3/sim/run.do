quit -sim
vlib work
vmap altera_mf "C:/intelFPGA_lite/23.1std/questa_fse/intel/verilog/altera_mf"
vmap altera_lnsim "C:/intelFPGA_lite/23.1std/questa_fse/intel/verilog/altera_lnsim"

vlog -sv "../pkg/*.sv"
vlog -sv "../ip/*.v"
vlog -sv "../ip/PLL_50_100_sim/PLL_50_100.vo"
#vlog -sv "../ip/PLL_50_100/*.v"
vlog -sv "../rtl/*.sv"

vlog -sv wimax_max_top_tb.sv
vsim -voptargs=+acc -L altera_mf -L altera_lnsim work.wimax_max_top_tb
do wave.do
run -all