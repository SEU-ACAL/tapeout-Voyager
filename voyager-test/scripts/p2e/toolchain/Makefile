vsyn:
	vsyn -f ${VSRC_PATH}/filelist.f -top VCU118FPGATestHarness -o VCU118FPGATestHarness.vm -area-report area.log -l vsyn.log
vsyn_ff:
	xjob run -c 4 -m 10g make vsyn
vsyn_clean:
	rm -rf area.log data.vsyn fnl.db libs.vsyn TestHarness.vm vsyn.log vsyn_timing_path.rpt
vcom:
	vcom vcom_compile.tcl | tee vcom_compile.log
vcom_ff:
	xjob run -c 8 -m 20g make vcom
pnr:
	cd fpgaCompDir;make all
pnr_ff:
	xjob run -c 8 -m 60g make pnr

all:vsyn vcom pnr
