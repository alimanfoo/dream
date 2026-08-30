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
# make reads timestamps, and git records none, so cloning the repository or
# switching branch would stamp every file with the current time and leave
# most outputs looking stale. restore-mtimes.sh puts back the time each
# file's content last changed, and runs below while this file is read, which
# is before make looks at any target. So a fresh clone needs nothing
# remembered.
#
# If a timestamp is wrong anyway, `make -t all` marks every output current
# without running anything, and each output records the hash of the prompt
# behind it in its meta.json.

# Before anything else, and before make stats a single target: give each file
# back the time its content last changed. See the note above.
RESTORED := $(shell $(dir $(lastword $(MAKEFILE_LIST)))restore-mtimes.sh 2>&1)

F ?= docstring-1
REPS ?= 3
ATTEMPTS ?= 3

REPLICATES := $(shell seq 1 $(REPS))
ARM_NUMBERS := 1 2 3 4 5 7 8

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

.PHONY: all list arm1 arm2 arm3 arm4 arm5 arm6 arm7 arm8
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

# Arm 6 is retired. It invents, so it is not worth judging, and it is out of
# ARM_NUMBERS so `make all` leaves it alone. Its runs stand as the evidence,
# and `make arm6` still builds it.
arm6: $(foreach r,$(REPLICATES),$(RUNS)/arm6-r$(r)/output.md)

$(RUNS)/arm6-r%/output.md: $(RUNS)/arm1-r%/output.md 6-dialogue/prompt.md 6-dialogue/run.sh
	$(call attempt,6-dialogue,$*)

$(RUNS)/arm7-r%/output.md: $(RUNS)/arm1-r%/output.md 7-dialogue-bounded/prompt.md 7-dialogue-bounded/run.sh
	$(call attempt,7-dialogue-bounded,$*)

$(RUNS)/arm8-r%/output.md: $(RUNS)/arm1-r%/output.md 8-altitude/prompt.md 8-altitude/run.sh
	$(call attempt,8-altitude,$*)

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
