# Run the arms over a fixture.
#
#   make                     say what running everything would do, and do none of it
#   make all -j3             every arm, every replicate
#   make arm6 -j3            one arm, and whatever it needs
#   make all F=readme-1      a different fixture
#   make all REPS=5          more replicates
#
# make owns the ordering, because an arm that reads another arm's output is
# just a prerequisite. It also owns what to redo, since an output older than
# the prompt behind it is out of date, and so is everything downstream of it.
#
# Keep -j small. A copy-edit round holds a large prompt open for about two
# minutes, and enough of those at once fail in the transport rather than in
# the model.
#
# A rebuild is not free. Each call costs minutes and money, and running it
# again gives different text rather than the same text again. Three things
# follow. Only what determines an output is a prerequisite, so the arm's own
# prompts, the fixture and the guide count, while the shared plumbing does
# not, since editing a comment in common.sh should not redo thirty calls.
# There is no clean target. And plain `make` only reports, so nothing is spent
# until you ask for it by name.
#
# make reads timestamps, and a timestamp moves without the content moving:
# cloning the repository, switching branch and renaming a file all do it, and
# every output then looks stale. When that happens and the outputs are the
# ones you want, `make -t all` marks them current without running anything.
# Each output also records the hash of the prompt behind it, in its
# meta.json, which settles what a timestamp cannot.

F ?= docstring-1
REPS ?= 3
ATTEMPTS ?= 3

REPLICATES := $(shell seq 1 $(REPS))
ARM_NUMBERS := 1 2 3 4 5 6

RUNS := ../runs/$(F)
FIX := ../fixtures/$(F)
GUIDE := ../snapshot/plain-english.md
EDITOR_AGENT := ../snapshot/copy-editor.md

SOURCE := $(addprefix ../fixtures/sources/,$(shell cat $(FIX)/source 2>/dev/null))
SEED := $(FIX)/seed-prompt.md $(SOURCE)
READER := $(FIX)/reader.md
COPYEDIT := $(GUIDE) $(EDITOR_AGENT) $(READER) \
            3-copyedit/editor.md 3-copyedit/author.md 3-copyedit/round.sh

OUTPUTS := $(foreach a,$(ARM_NUMBERS),\
             $(foreach r,$(REPLICATES),$(RUNS)/arm$(a)-r$(r)/output.md))

# A call can fail in the transport, and one failure would otherwise stop the
# build, so try again before giving up.
define attempt
@n=1; until $(1)/run.sh $(F) $(2); do \
   if [ $$n -ge $(ATTEMPTS) ]; then \
     echo "$(1) replicate $(2) failed after $(ATTEMPTS) attempts" >&2; exit 1; \
   fi; \
   n=$$((n + 1)); echo "  retrying $(1) replicate $(2), attempt $$n"; \
 done
endef

.PHONY: all list arm1 arm2 arm3 arm4 arm5 arm6
.DEFAULT_GOAL := list

all: $(OUTPUTS)

$(foreach a,$(ARM_NUMBERS),$(eval arm$(a): \
  $(foreach r,$(REPLICATES),$(RUNS)/arm$(a)-r$(r)/output.md)))

$(RUNS)/arm1-r%/output.md: $(SEED) 1-vanilla/run.sh
	$(call attempt,1-vanilla,$*)

$(RUNS)/arm2-r%/output.md: $(SEED) $(GUIDE) 2-guide-first/prompt.md 2-guide-first/run.sh
	$(call attempt,2-guide-first,$*)

$(RUNS)/arm3-r%/output.md: $(RUNS)/arm1-r%/output.md $(COPYEDIT) 3-copyedit/run.sh
	$(call attempt,3-copyedit,$*)

$(RUNS)/arm4-r%/output.md: $(RUNS)/arm3-r%/output.md $(COPYEDIT) 4-copyedit-twice/run.sh
	$(call attempt,4-copyedit-twice,$*)

$(RUNS)/arm5-r%/output.md: $(RUNS)/arm2-r%/output.md $(COPYEDIT) 5-guide-then-copyedit/run.sh
	$(call attempt,5-guide-then-copyedit,$*)

$(RUNS)/arm6-r%/output.md: $(RUNS)/arm1-r%/output.md 6-dialogue/prompt.md 6-dialogue/run.sh
	$(call attempt,6-dialogue,$*)

# What running everything would do. Runs nothing.
list:
	@$(MAKE) --dry-run --no-print-directory all F=$(F) REPS=$(REPS) 2>/dev/null \
	  | grep -oE '[0-9A-Za-z-]+/run\.sh [^ ]+ [0-9]+' \
	  | sed -E 's|/run\.sh [^ ]+ | replicate |; s|^|  would run |' | sort -u \
	  || echo "  everything is up to date"
	@echo "  (make all to run them; make -t all to mark them current instead)"

# A failed call must not leave a half-written output behind, or the next run
# would take it for finished work.
.DELETE_ON_ERROR:
