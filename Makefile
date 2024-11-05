all: sync generate-appendix generate_pdf

sync:
	rye sync

generate-appendix:
	rye run python scripts/generate_appendix.py

generate_pdf:
	typst compile main.typ 