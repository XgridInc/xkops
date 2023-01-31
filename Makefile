# We'll be using following prefixes with rules and variables. 
# Pixie 	==> px 
# Robusta   ==> rb 
# Kubecost  ==> kc 

INTERPRETER  = bash

PX_CHECKER = /src/checker/px-checker.sh
PX_PRE_FLIGHT = /src/pre-flight/px-pre-flight/px-preflight.sh
PX_INSTALLER = /src/installer/px-installer.sh
PX_ROLLBACK = /src/rollback/px-rollback.sh

RB_CHECKER = /src/checker/rb-checker.sh
RB_PRE_FLIGHT = /src/pre-flight/rb-pre-flight/rb-preflight.sh
RB_INSTALLER = /src/installer/rb-installer.sh
RB_ROLLBACK = /src/rollback/rb-rollback.sh

KC_CHECKER = /src/checker/kc-checker.sh
KC_PRE_FLIGHT = /src/pre-flight/kc-pre-flight/kc-preflight.sh
KC_INSTALLER = /src/installer/kc-installer.sh
KC_ROLLBACK = /src/rollback/kc-rollback.sh


# Pixie relevant rules.  
px_check: 
	$(INTERPRETER) $(PX_CHECKER)

px_preflight:
	$(INTERPRETER) $(PX_PRE_FLIGHT)

px_deploy:
	$(INTERPRETER) $(PX_INSTALLER) "$(PX_API_KEY)" 

px_all:
	$(INTERPRETER) $(PX_CHECKER) && ( $(INTERPRETER) $(PX_PRE_FLIGHT) && ( $(INTERPRETER) $(PX_INSTALLER) "$(PX_API_KEY)" && echo "PX_INSTALLER Exit 0" || echo "PX_INSTALLER Exit 1") || echo "PX_PRE_FLIGHT Exit 1" ) || echo "PX_CHECKER Exit 1"

px_rollback:
	$(INTERPRETER) $(PX_ROLLBACK) && echo "PX_ROLLBACK Exit 0" || echo "PX_ROLLBACK Exit 1"

# Robusta relevant rules
rb_check:
	$(INTERPRETER) $(RB_CHECKER)

rb_preflight: 
	$(INTERPRETER) $(RB_PRE_FLIGHT)

rb_install: 
	$(INTERPRETER) $(RB_INSTALLER) 

rb_all:
	$(INTERPRETER) $(RB_CHECKER) && ( $(INTERPRETER) $(RB_PRE_FLIGHT) && ( $(INTERPRETER) $(RB_INSTALLER) && echo "RB_INSTALLER Exit 0" || echo "RB_INSTALLER Exit 1") || echo "RB_PRE_FLIGHT Exit 1" ) || echo "RB_CHECKER Exit 1"

rb_rollback:
	$(INTERPRETER) $(RB_ROLLBACK) && echo "RB_ROLLBACK Exit 0" || echo "RB_ROLLBACK Exit 1"

# Kubecost relevant rules
kc_check:
	$(INTERPRETER) $(KC_CHECKER)

kc_preflight:
	$(INTERPRETER) $(KC_PRE_FLIGHT)

kc_install:
	$(INTERPRETER) $(KC_INSTALLER)

kc_all:
	$(INTERPRETER) $(KC_CHECKER) && ( $(INTERPRETER) $(KC_PRE_FLIGHT) && ( $(INTERPRETER) $(KC_INSTALLER) && echo "KC_INSTALLER Exit 0" || echo "KC_INSTALLER Exit 1") || echo "KC_PRE_FLIGHT Exit 1" ) || echo "KC_CHECKER Exit 1"

kc_rollback:
	$(INTERPRETER) $(KC_ROLLBACK) && echo "KC_ROLLBACK Exit 0" || echo "KC_ROLLBACK Exit 1"

all:
	$(MAKE) px_all  
	$(MAKE) rb_all
	$(MAKE) kc_all

rollback_all:
	$(MAKE) px_rollback
	$(MAKE) rb_rollback
	$(MAKE) kc_rollback

