.PHONY: mobile-pub-get mobile-analyze mobile-test mobile-run help

MOBILE_FLUTTER := ./scripts/mobile_flutter.sh

help:
	@printf "Available targets:\n"
	@printf "  make mobile-pub-get\n"
	@printf "  make mobile-analyze\n"
	@printf "  make mobile-test\n"
	@printf "  make mobile-run ARGS=\"--dart-define=...\"\n"

mobile-pub-get:
	$(MOBILE_FLUTTER) pub get

mobile-analyze:
	$(MOBILE_FLUTTER) analyze

mobile-test:
	$(MOBILE_FLUTTER) test

mobile-run:
	$(MOBILE_FLUTTER) run $(ARGS)
