.PHONY: all check lint up help

INVENTORY ?= inventory.yml
PLAYBOOK ?= cluster.yml
TAGS ?=
ANSIBLE_FLAGS ?=

ifneq ($(TAGS),)
	ANSIBLE_FLAGS += --tags $(TAGS)
endif

all: check lint ## Syntax-check and lint the playbook

check: ## Syntax-check the playbook against $(INVENTORY)
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --syntax-check

lint: ## Lint every playbook, role and template with ansible-lint
	ansible-lint

up: ## Run the playbook against $(INVENTORY)
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) $(ANSIBLE_FLAGS)

help: ## Show this help message
	@echo "quickstart Makefile targets:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Variables: INVENTORY=$(INVENTORY) PLAYBOOK=$(PLAYBOOK) TAGS='$(TAGS)'"
	@echo ""
