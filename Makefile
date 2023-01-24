# We'll be using following prefixes with rules and variables. 
# Pixie 	==> px 
# Robusta   ==> rb 
# Kubecost  ==> kc 

INTERPRETER  = bash

PX_CHECKER = /src/checker/px-checker.sh
PX_PRE_FLIGHT = /src/pre-flight/px-pre-flight/px-preflight.sh
PX_INSTALLER = /src/installer/px-installer.sh
PX_ROLLBACK = /src/rollback/px-rollback.sh
PX_TEST= /src/test/px-test.sh

RB_CHECKER = /src/checker/rb-checker.sh
RB_PRE_FLIGHT = /src/pre-flight/rb-pre-flight/rb-preflight.sh
RB_INSTALLER = /src/installer/rb-installer.sh
RB_ROLLBACK = /src/rollback/rb-rollback.sh
RB_TEST = /src/test/rb-test.sh

KC_CHECKER = /src/checker/kc-checker.sh
KC_PRE_FLIGHT = /src/pre-flight/kc-pre-flight/kc-preflight.sh
KC_INSTALLER = /src/installer/kc-installer.sh
KC_ROLLBACK = /src/rollback/kc-rollback.sh
KC_TEST = /src/test/kc-test.sh


# Pixie relevant rules.  
px_check: 
	$(INTERPRETER) $(PX_CHECKER)

px_preflight:
	$(INTERPRETER) $(PX_PRE_FLIGHT)

px_deploy:
	$(INTERPRETER) $(PX_INSTALLER) "$(PX_API_KEY)" 

px_test: 
	$(INTERPRETER) $(PX_TEST)

px_rollback:
	$(INTERPRETER) $(PX_ROLLBACK)

px_all: 
	$(INTERPRETER) $(PX_CHECKER)
	$(INTERPRETER) $(PX_PRE_FLIGHT)
	$(INTERPRETER) $(PX_INSTALLER) "$(PX_API_KEY)" 
	$(INTERPRETER) $(PX_TEST) 

# Robusta relevant rules
rb_check:
	$(INTERPRETER) $(RB_CHECKER)

rb_preflight: 
	$(INTERPRETER) $(RB_PRE_FLIGHT)

rb_install: 
	$(INTERPRETER) $(RB_INSTALLER)

rb_rollback:
	$(INTERPRETER) $(RB_ROLLBACK)

rb_test: 
	$(INTERPRETER) $(RB_TEST)

rb_all: 
	$(INTERPRETER) $(RB_CHECKER)
	$(INTERPRETER) $(RB_PRE_FLIGHT)
	$(INTERPRETER) $(RB_INSTALLER)
	$(INTERPRETER) $(RB_TEST) 

# Kubecost relevant rules
kc_check:
	$(INTERPRETER) $(KC_CHECKER)

kc_preflight:
	$(INTERPRETER) $(KC_PRE_FLIGHT)

kc_install:
	$(INTERPRETER) $(KC_INSTALLER)

kc_all:
	$(INTERPRETER) $(KC_CHECKER)
	$(INTERPRETER) $(KC_PRE_FLIGHT)
	$(INTERPRETER) $(KC_INSTALLER)

kc_rollback:
	$(INTERPRETER) $(KC_ROLLBACK)

all:
	$(MAKE) px_all
	$(MAKE) rb_all
	$(MAKE) kc_all

rollback_all:
	$(MAKE) px_rollback
	$(MAKE) rb_rollback
	$(MAKE) kc_rollback

