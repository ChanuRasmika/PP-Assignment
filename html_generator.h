#ifndef HTML_GENERATOR_H
#define HTML_GENERATOR_H

void generate_html(const char *field_name, const char *type, int required,
                   int min, int max, const char *pattern, const char *default_value,
                   int rows, int cols,
                   char **dropdown_options, int dropdown_count,
                   char **radio_options, int radio_count,
                   int checkbox_default);

void print_escaped(const char *src);

#endif
