filename = hsv_pwm
pcf_file = iceBlinkPico.pcf

build:
	yosys -p "synth_ice40 -top top -json $(filename).json" $(filename).sv
	nextpnr-ice40 --up5k --package sg48 --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc
	icepack $(filename).asc $(filename).bin

prog: #for sram
	dfu-util --device 1d50:6146 --alt 0 -D $(filename).bin -R

sim:
	iverilog -g2012 -o hsv_pwm_tb hsv_pwm_tb.sv
	vvp hsv_pwm_tb

clean:
	rm -rf $(filename).blif $(filename).asc $(filename).json $(filename).bin hsv_pwm_tb hsv_pwm.vcd
