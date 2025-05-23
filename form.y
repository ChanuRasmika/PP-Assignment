%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "html_generator.h"

extern FILE *yyin;
extern int yylineno;
extern int yylex(void);  

void yyerror(const char *s);

typedef struct {
    int required;
    int min, max;
    char *pattern;
    char *default_value;
    int rows, cols;
    char *dropdown_options[20];
    int dropdown_option_count;
    char *radio_options[20];
    int radio_option_count;
    int checkbox_default;
} FieldAttr;

FieldAttr field_attr;

void reset_field_attr() {
    field_attr.required = 0;
    field_attr.min = 0;
    field_attr.max = 0;
    if (field_attr.pattern) { free(field_attr.pattern); field_attr.pattern = NULL; }
    if (field_attr.default_value) { free(field_attr.default_value); field_attr.default_value = NULL; }
    field_attr.rows = 0;
    field_attr.cols = 0;
    for (int i = 0; i < field_attr.dropdown_option_count; i++) free(field_attr.dropdown_options[i]);
    for (int i = 0; i < field_attr.radio_option_count; i++) free(field_attr.radio_options[i]);
    field_attr.dropdown_option_count = 0;
    field_attr.radio_option_count = 0;
    field_attr.checkbox_default = 0;
}

typedef struct {
    char *key;
    char *value;
} MetaEntry;

#define MAX_META 20
MetaEntry meta_entries[MAX_META];
int meta_count = 0;

void add_meta(const char *key, const char *value) {
    if (meta_count < MAX_META) {
        meta_entries[meta_count].key = strdup(key);
        meta_entries[meta_count].value = strdup(value);
        meta_count++;
    }
}

void free_meta() {
    for (int i = 0; i < meta_count; i++) {
        free(meta_entries[i].key);
        free(meta_entries[i].value);
    }
    meta_count = 0;
}

char *current_section_name = NULL;
int section_has_fields = 0;

%}

%union {
    char *str;
    int num;
    struct {
        char **options;
        int count;
    } option_list;
}

%token <str> IDENTIFIER STRING
%token <num> NUMVAL
%token TRUE FALSE
%token FORM SECTION FIELD META VALIDATE IF ERROR
%token REQUIRED DEFAULT PATTERN OPTIONS ACCEPT MIN MAX
%token TEXT TEXTAREA DROPDOWN RADIO CHECKBOX COLOR DATE DATETIME_LOCAL EMAIL INPUT_FILE HIDDEN IMAGE MONTH PASSWORD RANGE RESET SEARCH SUBMIT TEL TIME URL WEEK BUTTON NUMBER
%token ROWS COLS
%token COLON SEMICOLON LBRACE RBRACE EQUALS LBRACKET RBRACKET COMMA

%type <str> input_type
%type <option_list> option_list

%start program

%%

program:
    FORM IDENTIFIER LBRACE
    {
        printf("<form id=\"%s\">\n<!-- Form: %s -->\n", $2, $2);
        free($2);
    }
    form_content
    RBRACE
    {
        printf("</form>\n");
        free_meta();
    }
    ;

form_content:
    form_content metadata
    | form_content section
    | form_content field
    | form_content validation
    | /* empty */
    ;

metadata:
    META IDENTIFIER EQUALS STRING SEMICOLON
    {
        add_meta($2, $4);
        free($2);
        free($4);
    }
    ;

section:
    SECTION IDENTIFIER LBRACE
    {
        if (current_section_name) free(current_section_name);
        current_section_name = strdup($2);
        section_has_fields = 0;
        printf("<fieldset>\n<legend>");
        print_escaped(current_section_name);
        printf("</legend>\n");
        free($2);
    }
    field_list
    RBRACE
    {
        if (section_has_fields)
            printf("</fieldset>\n");
        free(current_section_name);
        current_section_name = NULL;
    }
    ;

field_list:
    field_list field
    | field
    ;

field:
    FIELD IDENTIFIER COLON input_type field_attrs SEMICOLON
    {
        section_has_fields = 1;
        generate_html($2, $4,
                      field_attr.required,
                      field_attr.min, field_attr.max,
                      field_attr.pattern,
                      field_attr.default_value,
                      field_attr.rows, field_attr.cols,
                      field_attr.dropdown_options, field_attr.dropdown_option_count,
                      field_attr.radio_options, field_attr.radio_option_count,
                      field_attr.checkbox_default);
        free($2);
        free($4);
        reset_field_attr();
    }
    | error SEMICOLON
    {
        yyerror("Invalid field definition, skipping.");
        yyerrok;
        reset_field_attr();
    }
    ;

field_attrs:
    field_attrs field_attr
    | /* empty */
    ;

field_attr:
    REQUIRED              { field_attr.required = 1; }
    | MIN EQUALS NUMVAL   { field_attr.min = $3; }
    | MAX EQUALS NUMVAL   { field_attr.max = $3; }
    | PATTERN EQUALS STRING { field_attr.pattern = strdup($3); free($3); }
    | DEFAULT EQUALS STRING { field_attr.default_value = strdup($3); free($3); }
    | DEFAULT EQUALS TRUE  { field_attr.checkbox_default = 1; }
    | DEFAULT EQUALS FALSE { field_attr.checkbox_default = 0; }
    | ROWS EQUALS NUMVAL  { field_attr.rows = $3; }
    | COLS EQUALS NUMVAL  { field_attr.cols = $3; }
    | OPTIONS EQUALS LBRACKET option_list RBRACKET
        {
            for (int i = 0; i < $4.count; i++) {
                field_attr.dropdown_options[i] = strdup($4.options[i]);
                free($4.options[i]);
            }
            field_attr.dropdown_option_count = $4.count;
            free($4.options);
        }
    | RADIO LBRACKET option_list RBRACKET
        {
            for (int i = 0; i < $3.count; i++) {
                field_attr.radio_options[i] = strdup($3.options[i]);
                free($3.options[i]);
            }
            field_attr.radio_option_count = $3.count;
            free($3.options);
        }
    | ACCEPT EQUALS STRING
        { /* handle accept attribute here, e.g., store in field_attr */ }
    ;


input_type:
    TEXT              { $$ = strdup("text"); }
    | TEXTAREA        { $$ = strdup("textarea"); }
    | DROPDOWN        { $$ = strdup("dropdown"); }
    | RADIO           { $$ = strdup("radio"); }
    | CHECKBOX        { $$ = strdup("checkbox"); }
    | COLOR           { $$ = strdup("color"); }
    | DATE            { $$ = strdup("date"); }
    | DATETIME_LOCAL  { $$ = strdup("datetime-local"); }
    | EMAIL           { $$ = strdup("email"); }
    | INPUT_FILE      { $$ = strdup("file"); }
    | HIDDEN          { $$ = strdup("hidden"); }
    | IMAGE           { $$ = strdup("image"); }
    | MONTH           { $$ = strdup("month"); }
    | PASSWORD        { $$ = strdup("password"); }
    | RANGE           { $$ = strdup("range"); }
    | RESET           { $$ = strdup("reset"); }
    | SEARCH          { $$ = strdup("search"); }
    | SUBMIT          { $$ = strdup("submit"); }
    | TEL             { $$ = strdup("tel"); }
    | TIME            { $$ = strdup("time"); }
    | URL             { $$ = strdup("url"); }
    | WEEK            { $$ = strdup("week"); }
    | BUTTON          { $$ = strdup("button"); }
    | NUMBER          { $$ = strdup("number"); }
    ;

option_list:
    STRING
    {
        $$.options = malloc(sizeof(char*));
        $$.options[0] = strdup($1);
        $$.count = 1;
        free($1);
    }
    | option_list COMMA STRING
    {
        $$.options = realloc($1.options, ($1.count + 1) * sizeof(char*));
        $$.options[$1.count] = strdup($3);
        $$.count = $1.count + 1;
        free($3);
    }
    ;

validation:
    VALIDATE LBRACE validation_conditions RBRACE
    {
        // Parsed but ignored for now (no JS)
    }
    ;

validation_conditions:
    validation_conditions validation_condition
    | /* empty */
    ;

validation_condition:
    IF expr LBRACE ERROR STRING SEMICOLON RBRACE
    {
        // Parsed but ignored for now
    }
    ;

expr:
    /* Simplified for now */
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error at line %d: %s\n", yylineno, s);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror("Failed to open input file");
            return 1;
        }
        yyin = file;
    }
    return yyparse();
}
