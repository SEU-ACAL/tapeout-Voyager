#########################################################################################
# vcs makefile
#########################################################################################

#########################################################################################
# general path variables
#########################################################################################
base_dir=$(abspath ../..)
sim_dir=$(abspath .)

#########################################################################################
# include shared variables
#########################################################################################
include $(base_dir)/variables.mk

#########################################################################################
# name of simulator (used to generate *.f arguments file)
#########################################################################################
sim_name = vcs

#########################################################################################
# vcs simulator types and rules
#########################################################################################
sim_prefix = simv
sim = $(sim_dir)/$(sim_prefix)-$(MODEL_PACKAGE)-$(CONFIG)
sim_debug = $(sim_dir)/$(sim_prefix)-$(MODEL_PACKAGE)-$(CONFIG)-debug

include $(sim_dir)/vcs.mk

.PHONY: default debug
default: $(sim)
debug: $(sim_debug)

#########################################################################################
# simulation requirements
#########################################################################################
SIM_FILE_REQS += \
	$(ROCKETCHIP_RSRCS_DIR)/vsrc/TestDriver.v

# copy files but ignore *.h files in *.f since vcs has +incdir+$(build_dir)
$(sim_files): $(SIM_FILE_REQS) $(ALL_MODS_FILELIST) | $(GEN_COLLATERAL_DIR)
	cp -f $(SIM_FILE_REQS) $(GEN_COLLATERAL_DIR)
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
# vcs binary and arguments
#########################################################################################
VCS = vcs -full64

VCS_OPTS = $(VCS_CC_OPTS) $(VCS_NONCC_OPTS) $(SIM_PREPROC_DEFINES) $(VCS_PREPROC_DEFINES)

#########################################################################################
# vcs build paths
#########################################################################################
model_dir = $(build_dir)/$(long_name)
model_dir_debug = $(build_dir)/$(long_name).debug
REAL = no
define CONDITIONAL_RUN_REAL
    @# This is a shell 'if' statement, executed by the command shell, not by make.
    @if [ "$(REAL)" = "yes" ]; then \
        echo "✅ RUN_REAL=yes. Executing iocell.py script..."; \
        python $(base_dir)/tapeout/scripts/iocell.py $(GEN_COLLATERAL_DIR); \
		bash $(base_dir)/tapeout/scripts/sram_gen.sh --tool $(TOOL) --config $(CONFIG); \
    else \
        echo "☑️ RUN_REAL not set to 'yes'. Skipping iocell.py script."; \
    fi
endef

# export PATH="/usr/bin:$(PATH)"          # 系统 gcc/g++/ld 优先
# export CC=/usr/bin/gcc
# export CXX=/usr/bin/g++
# export LD=/usr/bin/ld

# # 编译阶段只让 ld 找到系统基础库 + VCS 私有库
# export LIBRARY_PATH="$(VCS_LIB):/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu"

# export LDFLAGS="-L$(VCS_LIB) -Wl,--no-as-needed \
#       -lvcsnew -lvirsim -lvcsucli -lvfs -lsnpsmalloc -lerrorinf -lzerosoft_rt_stubs \
#       -lsimprofile -luclinative -lpthread -ldl -lrt -lm -lstdc++"
#########################################################################################
# vcs simulator rules
#########################################################################################
$(sim): $(sim_common_files) $(dramsim_lib) $(EXTRA_SIM_REQS)
	rm -rf $(model_dir)
	
	$(CONDITIONAL_RUN_REAL)
	$(VCS) $(VCS_OPTS) $(EXTRA_SIM_SOURCES) -o $@ -Mdir=$(model_dir)

$(sim_debug): $(sim_common_files) $(dramsim_lib) $(EXTRA_SIM_REQS)
	rm -rf $(model_dir_debug)
	
	$(CONDITIONAL_RUN_REAL)
	
	
# 	unset LD_LIBRARY_PATH
	$(VCS) $(VCS_OPTS) $(EXTRA_SIM_SOURCES) -o $@ -Mdir=$(model_dir_debug)  \
	+define+DEBUG -debug_access+all -kdb -lca

#########################################################################################
# create vcs vpd/fsdb rules
#########################################################################################
.PRECIOUS: $(output_dir)/%.vpd %.vpd
$(output_dir)/%.vpd: $(output_dir)/% $(sim_debug)
	(set -o pipefail && $(sim_debug) $(PERMISSIVE_ON) $(SIM_FLAGS) $(EXTRA_SIM_FLAGS) $(SEED_FLAG) $(VERBOSE_FLAGS) +vcdplusfile=$@ $(PERMISSIVE_OFF) $< </dev/null 2> >(spike-dasm > $<.out) | tee $<.log)

.PRECIOUS: $(output_dir)/%.fsdb %.fsdb
$(output_dir)/%.fsdb: $(output_dir)/% $(sim_debug)
	(set -o pipefail && $(sim_debug) $(PERMISSIVE_ON) $(SIM_FLAGS) $(EXTRA_SIM_FLAGS) $(SEED_FLAG) $(VERBOSE_FLAGS) +fsdbfile=$@ $(PERMISSIVE_OFF) $< </dev/null 2> >(spike-dasm > $<.out) | tee $<.log)


#########################################################################################
# general cleanup rules
#########################################################################################
.PHONY: clean clean-sim clean-sim-debug
clean:
	rm -rf $(CLASSPATH_CACHE) $(gen_dir) $(sim_prefix)-* ucli.key

clean-sim:
	rm -rf $(model_dir) $(build_dir)/vc_hdrs.h $(sim) $(sim).daidir ucli.key

clean-sim-debug:
	rm -rf $(model_dir_debug) $(build_dir)/vc_hdrs.h $(sim_debug) $(sim_debug).daidir ucli.key
