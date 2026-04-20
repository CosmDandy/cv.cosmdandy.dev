.PHONY: build build-example render render-example render-ats render-ats-example build-ats build-ats-example clean help

PYTHON ?= python3
DATA ?= cv-data.yaml
OUTPUT ?= output

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

render: ## Generate .tex from YAML data
	$(PYTHON) scripts/build.py --data $(DATA) --lang ru,en --output $(OUTPUT)

render-example: ## Generate .tex from example data
	$(PYTHON) scripts/build.py --data cv-data.example.yaml --lang ru,en --output $(OUTPUT)

build: render ## Generate .tex and compile to PDF
	cd $(OUTPUT) && latexmk -xelatex CV-Timofey-Kondrashin-ru.tex && latexmk -xelatex CV-Timofey-Kondrashin-en.tex

build-example: render-example ## Generate and compile from example data
	cd $(OUTPUT) && latexmk -xelatex CV-Timofey-Kondrashin-ru.tex && latexmk -xelatex CV-Timofey-Kondrashin-en.tex

render-ats: ## Generate ATS .tex from YAML data
	$(PYTHON) scripts/build.py --data $(DATA) --lang ru,en --output $(OUTPUT) --template ats

render-ats-example: ## Generate ATS .tex from example data
	$(PYTHON) scripts/build.py --data cv-data.example.yaml --lang ru,en --output $(OUTPUT) --template ats

build-ats: render-ats ## Generate ATS .tex and compile to PDF
	cd $(OUTPUT) && latexmk -xelatex CV-Timofey-Kondrashin-ats-ru.tex && latexmk -xelatex CV-Timofey-Kondrashin-ats-en.tex

build-ats-example: render-ats-example ## Generate and compile ATS from example data
	cd $(OUTPUT) && latexmk -xelatex CV-Timofey-Kondrashin-ats-ru.tex && latexmk -xelatex CV-Timofey-Kondrashin-ats-en.tex

clean: ## Remove generated files
	rm -rf $(OUTPUT)
