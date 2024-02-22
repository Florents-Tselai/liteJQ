#include <sqlite3ext.h>

SQLITE_EXTENSION_INIT1

#include <stdio.h>
#include <jq.h>
#include <jv.h>


/* Forward declarations for the SQLite jq function */
static void jq_text_text(sqlite3_context *context, int argc, sqlite3_value **argv);

/* Initialization function for the SQLite extension */
int sqlite3_litejq_init(sqlite3 *db, char **pzErrMsg, const sqlite3_api_routines *pApi) {
    SQLITE_EXTENSION_INIT2(pApi)
    // Register the jq function
    int rc = sqlite3_create_function(db, "jq", 2, SQLITE_UTF8, NULL, jq_text_text, NULL, NULL);
    if (rc != SQLITE_OK) {
        *pzErrMsg = sqlite3_mprintf("Failed to register function jq: %d", rc);
        return rc;
    }
    return SQLITE_OK;
}


/* Implementation of the jq(text, text) function */
static void jq_text_text(sqlite3_context *context, int argc, sqlite3_value **argv) {
    const char *input_json;
    const char *jq_program;
    jq_state *jq;
    jv input;
    jv result;

    if (argc != 2 || sqlite3_value_type(argv[0]) != SQLITE_TEXT || sqlite3_value_type(argv[1]) != SQLITE_TEXT) {
        sqlite3_result_error(context, "jq function requires exactly two TEXT arguments", -1);
        return;
    }

    input_json = (const char *) sqlite3_value_text(argv[0]);
    jq_program = (const char *) sqlite3_value_text(argv[1]);

    input = jv_parse(input_json);
    if (!jv_is_valid(input)) {
        sqlite3_result_error(context, "Invalid JSON input", -1);
        jv_free(input);
        return;
    }

    jq = jq_init();
    if (jq_compile(jq, jq_program)) {
        jq_start(jq, input, 0);

        while (jv_is_valid(result = jq_next(jq))) {
            switch (jv_get_kind(result)) {
                case JV_KIND_NULL:
                    sqlite3_result_null(context);
                    break;
                case JV_KIND_FALSE:
                    sqlite3_result_int(context, 0);
                    break;
                case JV_KIND_TRUE:
                    sqlite3_result_int(context, 1);
                    break;
                case JV_KIND_NUMBER:
                    if (jv_is_integer(result))
                        sqlite3_result_int(context, jv_number_value(result));
                    else
                        sqlite3_result_double(context, jv_number_value(result));
                    break;
                case JV_KIND_STRING: {
                    sqlite3_result_text(context, jv_string_value(result), -1, SQLITE_TRANSIENT);
                    break;
                }
                    /* SQLite doesn't have  a dedicated JSON type,
                     * thus we don't have to recurse into arrays and objects.
                     * Instead we just dump a json-serialized version of the result.
                     * */
                case JV_KIND_ARRAY:
                case JV_KIND_OBJECT: {
                    jv dumped = jv_dump_string(result, 0);
                    sqlite3_result_text(context, jv_string_value(dumped), -1, SQLITE_TRANSIENT);
                    jv_free(dumped);
                    break;
                }
                default:
                    sqlite3_result_error(context, "Unsupported JSON type", -1);
                    break;
            }

        } // end while loop
        jv_free(result);

    } else {
        sqlite3_result_error(context, "Failed to compile jq program", -1);
    }
    jq_teardown(&jq);
}
