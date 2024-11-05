# Typst Thesis

[Typst](https://typst.app/) template for students.

## Requirements

- Typst
- Rye (or simmilar)
- Make
- tree

## Guide

I recomend using VSCodium with the provided Workspace and extensions.\
See the Makefile for available actions. Simply run `make` to perform the whole deployment process.
That will:

- Generate an Appendix/Anhang.zip Archive
- Generate all nececary Metadata for Typst
  - Image Sources
  - Bibliography
  - Appendix
- Generate the main PDF from typst

### Assets

- **bib**
  - Your bibliography in, preferably, BibTex format from e.g. Zotero.
  - This can include automatic Web snapshots
- **code**
  - Code Repositories you wish to reference
  - All repos will automatically be referenced in the appendix
  - The folder structure and README will be printed
- **images**
  - Put image assets here
- **tables**
  - Put csv files here

### Chapters

Put the chapters of your thesis here

### Packages

Put new Packages form e.g. GitHub or Typst Universe here.

### Scripts

Folder for the provided python script.
