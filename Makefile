# We'll be using following prefixes with rules and variables. 
# Pixie 	==> px 
# Robusta   ==> rb 
# Kubecost  ==> kc 

INTERPRETER  = bash

PX_CHECKER = src/checker/px-checker.sh
PX_PRE_FLIGHT = src/checker/px-preflight.sh
PX_INSTALLER = src/checker/px-installer.sh

RB_CHECKER = src/checker/rb-checker.sh
RB_PRE_FLIGHT = src/preflight/rb-preflight.sh
RB_INSTALLER = src/installer/rb-installer.sh

KC_CHECKER = src/checker/kc-checker.sh
KC_PRE_FLIGHT = src/preflight/kc-preflight.sh
KC_INSTALLER = src/installer/kc-installer.sh

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

# Robusta relevant rules
rb_check:
#	<placeholder>

rb_preflight: 
#	<placeholder>

rb_install: 
#	<placeholder>


# Kubecost relevant rules
kc_check:
#	<placeholder>

kc_preflight: 
#	<placeholder>

kc_install: 
#	<placeholder>


all_check: 

all_preflight:

all_install:

