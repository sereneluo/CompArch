filename = top
pcf_file = iceBlinkPico.pcf

build:
	yosys -p "synth_ice40 -top top -json $(filename).json" $(filename).sv
	nextpnr-ice40 --up5k --package sg48 --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc
	icepack $(filename).asc $(filename).bin

prog: #for sram
	dfu-util --device 1d50:6146 --alt 0 -D $(filename).bin -R

sim-life:
	iverilog -g2012 -o life_tb.out life_tb.sv
	vvp life_tb.out

sim-seed:
	iverilog -g2012 -o seed_tb.out seed_tb.sv
	vvp seed_tb.out

clean:
	rm -rf $(filename).blif $(filename).asc $(filename).json $(filename).bin
	rm -rf life_tb.out seed_tb.out life.vcd seed.vcd
