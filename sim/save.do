
mem save -o SRAM.mem -f mti -data hex -addr hex -startaddress 0 -endaddress 262143 -wordsperline 8 /TB/SRAM_component/SRAM_data



if {[file exists $rtl/RAM_inst0.ver]} {
	file delete $rtl/RAM_inst0.ver
}
mem save -o RAM_inst0.mem -f mti -data hex -addr decimal -wordsperline 1 /TB/UUT/Milestone2_unit/RAM_inst0/altsyncram_component/m_default/altsyncram_inst/mem_data


if {[file exists $rtl/RAM_inst1.ver]} {
	file delete $rtl/RAM_inst1.ver
}
mem save -o RAM_inst1.mem -f mti -data hex -addr decimal -wordsperline 1 /TB/UUT/Milestone2_unit/RAM_inst1/altsyncram_component/m_default/altsyncram_inst/mem_data

if {[file exists $rtl/RAM_inst2.ver]} {
	file delete $rtl/RAM_inst2.ver
}
mem save -o RAM_inst2.mem -f mti -data hex -addr decimal -wordsperline 1 /TB/UUT/Milestone2_unit/RAM_inst2/altsyncram_component/m_default/altsyncram_inst/mem_data

