%{
#include "form.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%option noyywrap
%option yylineno

%%

"form"              { return FORM; }
"section"           { return SECTION; }
"field"             { return FIELD; }
"required"          { return REQUIRED; }
"number"            { return NUMBER; }
"text"              { return TEXT; }
"radio"             { return RADIO; }
"checkbox"          { return CHECKBOX; }
"color"             { return COLOR; }
"date"              { return DATE; }
"datetime-local"    { return DATETIME_LOCAL; }
"email"             { return EMAIL; }
"file"              { return INPUT_FILE; }
"hidden"            { return HIDDEN; }
"image"             { return IMAGE; }
"month"             { return MONTH; }
"password"          { return PASSWORD; }
"range"             { return RANGE; }
"reset"             { return RESET; }
"search"            { return SEARCH; }
"submit"            { return SUBMIT; }
"tel"               { return TEL; }
"time"              { return TIME; }
"url"               { return URL; }
"week"              { return WEEK; }
"button"            { return BUTTON; }
"textarea"          { return TEXTAREA; }
"dropdown"          { return DROPDOWN; }

"options"           { return OPTIONS; }
"pattern"           { return PATTERN; }
"accept"            { return ACCEPT; }
"min"               { return MIN; }
"max"               { return MAX; }
"default"           { return DEFAULT; }
"rows"              { return ROWS; }
"cols"              { return COLS; }

"true"              { return TRUE; }
"false"             { return FALSE; }

"meta"              { return META; }
"validate"          { return VALIDATE; }
"if"                { return IF; }
"error"             { return ERROR; }

":"                 { return COLON; }
";"                 { return SEMICOLON; }
"{"                 { return LBRACE; }
"}"                 { return RBRACE; }
"="                 { return EQUALS; }
"["                 { return LBRACKET; }
"]"                 { return RBRACKET; }
","                 { return COMMA; }
"<"                 { return LT; }
">"                 { return GT; }


\"(\\.|[^"\\])*\" {
    yylval.str = strdup(yytext + 1);
    yylval.str[strlen(yylval.str) - 1] = '\0';
    return STRING;
}

[0-9]+              { yylval.num = atoi(yytext); return NUMVAL; }

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str = strdup(yytext);
    return IDENTIFIER;
}

[ \t\r\n]+          { /* skip whitespace */ }

.                   { return *yytext; }

%%
