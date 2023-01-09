# We'll be using following prefixes with rules and variables. 
# Pixie 	==> px 
# Robusta   ==> rb 
# Kubecost  ==> kc 

INTERPRETER  = bash

PX_CHECKER = /src/checker/px-checker.sh
PX_PRE_FLIGHT = /src/pre-flight/px-pre-flights/px-preflight.sh
PX_INSTALLER = /src/installer/px-installer.sh
PX_SANITIZATION = /src/sanitization/px-sanitization.sh

RB_CHECKER = /src/checker/rb-checker.sh
RB_PRE_FLIGHT = /src/pre-flight/rb-pre-flight/rb-preflight.sh
RB_INSTALLER = /src/installer/rb-installer.sh
RB_SANITIZATION = /src/sanitization/rb-sanitization.sh

KC_CHECKER = /src/checker/kc-checker.sh
KC_PRE_FLIGHT = /src/pre-flight/kc-pre-flight/kc-preflight.sh
KC_INSTALLER = /src/installer/kc-installer.sh
KC_SANITIZATION = /src/sanitization/kc-sanitization.sh


# Pixie relevant rules.  
px_check: 
	$(INTERPRETER) $(PX_CHECKER)

px_preflight:
	$(INTERPRETER) $(PX_PRE_FLIGHT)

px_deploy:
	$(INTERPRETER) $(PX_INSTALLER) "$(PX_API_KEY)" 

px_all: 
	$(INTERPRETER) $(PX_CHECKER)
	$(INTERPRETER) $(PX_PRE_FLIGHT)
	$(INTERPRETER) $(PX_INSTALLER) "$(PX_API_KEY)" 

px_sanitize:
	$(INTERPRETER) $(PX_SANITIZATION)

# Robusta relevant rules
rb_check:
	$(INTERPRETER) $(RB_CHECKER)

rb_preflight: 
	$(INTERPRETER) $(RB_PRE_FLIGHT)

rb_install: 
	$(INTERPRETER) $(RB_INSTALLER)

rb_all: 
	$(INTERPRETER) $(RB_CHECKER)
	$(INTERPRETER) $(RB_PRE_FLIGHT)
	$(INTERPRETER) $(RB_INSTALLER) 

rb_sanitize:
	$(INTERPRETER) $(RB_SANITIZATION)

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

kc_sanitize:
	$(INTERPRETER) $(KC_SANITIZATION)

all:
	$(MAKE) px_all
	$(MAKE) rb_all
	$(MAKE) kc_all

sanitize_all:
	$(MAKE) px_sanitize
	$(MAKE) rb_sanitize
	$(MAKE) kc_sanitize

