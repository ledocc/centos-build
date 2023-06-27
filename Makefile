

targets = build run run-dev
.PHONY: $(targets)

$(targets):
	$(MAKE) -C docker $@
