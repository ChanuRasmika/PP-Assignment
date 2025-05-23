#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "html_generator.h"

// Escape &, <, >, " characters in HTML attributes and text
void html_escape(const char *src, char *dest, size_t dest_size) {
    size_t pos = 0;
    for (; *src && pos + 6 < dest_size; src++) {
        switch (*src) {
            case '&': strcpy(dest + pos, "&amp;"); pos += 5; break;
            case '<': strcpy(dest + pos, "&lt;"); pos += 4; break;
            case '>': strcpy(dest + pos, "&gt;"); pos += 4; break;
            case '"': strcpy(dest + pos, "&quot;"); pos += 6; break;
            default: dest[pos++] = *src; break;
        }
    }
    dest[pos] = '\0';
}

void print_escaped(const char *src) {
    char buf[1024];
    html_escape(src, buf, sizeof(buf));
    fputs(buf, stdout);
}

// Capitalize and prettify field names (e.g., fullName -> Full Name)
char* prettify_field_name(const char *field_name) {
    if (!field_name) return NULL;
    size_t len = strlen(field_name);
    char *display = malloc(len * 2 + 1);
    if (!display) return NULL;
    int j = 0;
    for (size_t i = 0; i < len; i++) {
        if (i > 0 && isupper(field_name[i])) {
            display[j++] = ' ';
        }
        display[j++] = (i == 0) ? toupper(field_name[i]) : field_name[i];
    }
    display[j] = '\0';
    return display;
}

void generate_html(const char *field_name, const char *type, int required,
                   int min, int max, const char *pattern, const char *default_value,
                   int rows, int cols,
                   char **dropdown_options, int dropdown_count,
                   char **radio_options, int radio_count,
                   int checkbox_default) {
    char *label = prettify_field_name(field_name);

    if (strcmp(type, "radio") == 0 && radio_options && radio_count > 0) {
        printf("<label>%s:</label><br>\n", label ? label : field_name);
        for (int i = 0; i < radio_count; i++) {
            printf("<input type=\"radio\" name=\"");
            print_escaped(field_name);
            printf("\" value=\"");
            print_escaped(radio_options[i]);
            printf("\" id=\"%s_%d\">", field_name, i);
            printf("<label for=\"%s_%d\">", field_name, i);
            print_escaped(radio_options[i]);
            printf("</label><br>\n");
        }
    } else if (strcmp(type, "checkbox") == 0) {
        printf("<label><input type=\"checkbox\" name=\"");
        print_escaped(field_name);
        printf("\" id=\"%s\"%s> ", field_name, checkbox_default ? " checked" : "");
        if (label) print_escaped(label);
        else print_escaped(field_name);
        printf("</label><br>\n");
    } else if (strcmp(type, "dropdown") == 0 && dropdown_options && dropdown_count > 0) {
        printf("<label for=\"%s\">%s: </label>\n", field_name, label ? label : field_name);
        printf("<select name=\"%s\" id=\"%s\"%s>\n", field_name, field_name, required ? " required" : "");
        for (int i = 0; i < dropdown_count; i++) {
            printf("  <option value=\"");
            print_escaped(dropdown_options[i]);
            printf("\"");
            if (default_value && strcmp(dropdown_options[i], default_value) == 0)
                printf(" selected");
            printf(">");
            print_escaped(dropdown_options[i]);
            printf("</option>\n");
        }
        printf("</select><br>\n");
    } else if (strcmp(type, "textarea") == 0) {
        printf("<label for=\"%s\">%s: </label>\n", field_name, label ? label : field_name);
        printf("<textarea name=\"%s\" id=\"%s\" rows=\"%d\" cols=\"%d\"%s>", field_name, field_name,
               rows > 0 ? rows : 4, cols > 0 ? cols : 40, required ? " required" : "");
        if (default_value) print_escaped(default_value);
        printf("</textarea><br>\n");
    } else {
        printf("<label for=\"%s\">%s: </label>\n", field_name, label ? label : field_name);
        printf("<input type=\"%s\" name=\"%s\" id=\"%s\"", type, field_name, field_name);
        if (required) printf(" required");
        if (min != 0) printf(" min=\"%d\"", min);
        if (max != 0) printf(" max=\"%d\"", max);
        if (pattern && strlen(pattern) > 0) {
            printf(" pattern=\"");
            print_escaped(pattern);
            printf("\"");
        }
        if (default_value && strlen(default_value) > 0) {
            printf(" value=\"");
            print_escaped(default_value);
            printf("\"");
        }
        printf("><br>\n");
    }
    free(label);
}
