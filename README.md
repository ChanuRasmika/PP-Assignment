# Programming Paradigms Assignment - IT23173118

## 📖 Overview

**FormLang++** is a Domain-Specific Language (DSL) designed for defining interactive web forms. This project leverages **Lex** and **Yacc** (via **Flex** and **Bison**) to parse FormLang++ code and generate corresponding HTML forms. The output HTML can be used to render fully functional web forms based on the provided FormLang++ input.

---

## 📂 Project Files

| **File Name**        | **Description**                                                                 |
|----------------------|--------------------------------------------------------------------------------|
| `form.l`             | Lex (Flex) specification for tokenizing FormLang++ DSL input.                   |
| `form.y`             | Yacc (Bison) grammar for parsing the tokenized DSL and generating HTML.         |
| `html_generator.c`   | C module containing functions to generate and output HTML form elements.        |
| `html_generator.h`   | Header file for `html_generator.c`.                                            |
| `Grammer.txt`        | EBNF grammar definition for the FormLang++ DSL.                                |
| `README.md`          | This file, providing an overview and instructions for the project.              |
| *Input file*         | User-provided `.form` file with FormLang++ code to be parsed and converted.      |

---

## 🛠️ Compilation Instructions

To build and run the FormLang++ tool, ensure you have **Flex**, **Bison**, and **GCC** installed on your system.

Run the following commands to generate the lexer and parser files:

```bash
flex form.l
bison -d form.y
gcc -o formlang form.tab.c lex.yy.c html_generator.c
./formlang <your-input-file.form>
