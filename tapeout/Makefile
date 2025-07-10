#########################################################################################
# fpga prototype makefile
#########################################################################################

#########################################################################################
# general path variables
#########################################################################################
base_dir=$(shell git rev-parse --show-toplevel)
sim_dir=$(base_dir)/tapeout

# do not generate simulation files
sim_name := none

#########################################################################################
# include shared variables
#########################################################################################
SUB_PROJECT ?= voyager_tapeout

# For voyager_tapeout developers
ifeq ($(SUB_PROJECT),voyager_tapeout)
	SBT_PROJECT       ?= voyager_tapeout
	MODEL             ?= VCU118FPGATestHarness
	VLOG_MODEL        ?= $(MODEL)
	MODEL_PACKAGE     ?= voyager_tapeout.custom.fpga
	CONFIG            ?= VoyagerFPGAConfig
	CONFIG_PACKAGE    ?= voyager_tapeout
	GENERATOR_PACKAGE ?= chipyard
	TB                ?= TestDriver
	TOP               ?= ChipTop
	BOARD             ?= vcu118
	FPGA_BRAND        ?= xilinx
endif

export USE_CHISEL6=1

include $(base_dir)/variables.mk

# default variables to build the arty example
# setup the board to use

.PHONY: default
default: $(mcs)

#########################################################################################
# misc. directories
#########################################################################################
fpga_dir := $(base_dir)/tapeout/board/$(BOARD)
fpga_common_script_dir := $(fpga_dir)/common/tcl

#########################################################################################
# setup misc. sim files
#########################################################################################
# copy files but ignore *.h files in *.f (match vcs)
$(sim_files): $(SIM_FILE_REQS) $(ALL_MODS_FILELIST) | $(GEN_COLLATERAL_DIR)
	-cp -f $(SIM_FILE_REQS) $(GEN_COLLATERAL_DIR)
	touch $@
	$(foreach file,\
		$(SIM_FILE_REQS),\
		$(if $(filter %.h,$(file)),\
			,\
			echo "$(addprefix $(GEN_COLLATERAL_DIR)/, $(notdir $(file)))" >> $@;))

#########################################################################################
# import other necessary rules and variables
#########################################################################################
include $(base_dir)/common.mk

#########################################################################################
# add tapeout source files to incremental build dependencies
#########################################################################################
# Add tapeout source directories to the source detection
TAPEOUT_EXTRA_SOURCE_DIRS = $(addprefix $(base_dir)/,tapeout/src)
TAPEOUT_EXTRA_SCALA_SOURCES = $(call lookup_srcs_by_multiple_type,$(TAPEOUT_EXTRA_SOURCE_DIRS),$(SCALA_EXT))
TAPEOUT_EXTRA_VLOG_SOURCES = $(call lookup_srcs_by_multiple_type,$(TAPEOUT_EXTRA_SOURCE_DIRS),$(VLOG_EXT))

# Extend the existing source variables to include tapeout sources
CHIPYARD_SCALA_SOURCES += $(TAPEOUT_EXTRA_SCALA_SOURCES)
CHIPYARD_VLOG_SOURCES += $(TAPEOUT_EXTRA_VLOG_SOURCES)

# Redefine GENERATOR_CLASSPATH dependency to include tapeout sources
$(GENERATOR_CLASSPATH) &: $(CHIPYARD_SCALA_SOURCES) $(SCALA_BUILDTOOL_DEPS) $(CHIPYARD_VLOG_SOURCES) $(TAPEOUT_EXTRA_SCALA_SOURCES) $(TAPEOUT_EXTRA_VLOG_SOURCES)
	$(CHECK_SUBMODULES_COMMAND)
	mkdir -p $(dir $@)
	$(call run_sbt_assembly,$(SBT_PROJECT),$(GENERATOR_CLASSPATH))

#########################################################################################
# copy from other directory
#########################################################################################
all_vsrcs := \
	$(base_dir)/generators/rocket-chip-blocks/vsrc/SRLatch.v

#########################################################################################
# vivado rules
#########################################################################################
# combine all sources into single .f
synth_list_f := $(build_dir)/$(long_name).vsrcs.f
$(synth_list_f): $(sim_common_files) $(all_vsrcs)
	$(foreach file,$(all_vsrcs),echo "$(file)" >> $@;)
	cat $(sim_common_files) >> $@

BIT_FILE := $(build_dir)/obj/$(MODEL).bit
$(BIT_FILE): $(synth_list_f)
	cd $(build_dir); vivado \
		-nojournal -mode batch \
		-source $(fpga_common_script_dir)/vivado.tcl \
		-tclargs \
			-top-module "$(MODEL)" \
			-F "$(synth_list_f)" \
			-board "$(BOARD)" \
			-ip-vivado-tcls "$(shell find '$(build_dir)' -name '*.vivado.tcl')"

.PHONY: bitstream
bitstream: $(BIT_FILE)

.PHONY: debug-bitstream
debug-bitstream: $(build_dir)/obj/post_synth.dcp
	cd $(build_dir); vivado \
		-nojournal -mode batch \
		-source $(sim_dir)/scripts/run_impl_bitstream.tcl \
		-tclargs \
			$(build_dir)/obj/post_synth.dcp \
			$(BOARD) \
			$(build_dir)/debug_obj \
			$(fpga_common_script_dir)

#########################################################################################
# general cleanup rules
#########################################################################################
.PHONY: clean
clean:
	rm -rf $(gen_dir)
