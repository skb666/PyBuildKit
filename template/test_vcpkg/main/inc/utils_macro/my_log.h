#ifndef __MY_LOG_H__
#define __MY_LOG_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>

/* Define trace levels */
#define MY_TRACE_LEVEL_NONE 0    /* No trace messages to be generated  */
#define MY_TRACE_LEVEL_ERROR 1   /* Error condition trace messages     */
#define MY_TRACE_LEVEL_WARNING 2 /* Warning condition trace messages   */
#define MY_TRACE_LEVEL_INFO 3    /* Debug messages for info            */
#define MY_TRACE_LEVEL_DEBUG 3   /* Full debug messages                */
#define MY_TRACE_LEVEL_RELEASE 0 /* Verbose debug messages             */

#ifdef DEBUG
#define DEFAULT_LOG_LEVEL MY_TRACE_LEVEL_DEBUG
#else
#define DEFAULT_LOG_LEVEL MY_TRACE_LEVEL_RELEASE
#endif

#define LOG_COLOR_YELLOW "\033[1;33m"
#define LOG_COLOR_RED "\033[1;31m"
#define LOG_COLOR_BLUE "\033[1;34m"
#define LOG_COLOR_GREEN "\033[0;32m"
#define LOG_COLOR_PURPLE "\033[1;35m"
#define LOG_COLOR_RESET "\033[0m"

#define LOG_OUT_DEVICE stdout

#define LOGCINFO(tag, fmt, ...) fprintf(LOG_OUT_DEVICE, LOG_COLOR_BLUE "\r[ %s ] " LOG_COLOR_RESET fmt, tag, ##__VA_ARGS__);
#define LOGCWARN(tag, fmt, ...) fprintf(LOG_OUT_DEVICE, LOG_COLOR_BLUE "\r[ %s ] " LOG_COLOR_RESET LOG_COLOR_YELLOW fmt LOG_COLOR_RESET, tag, ##__VA_ARGS__);
#define LOGCERR(tag, fmt, ...) fprintf(LOG_OUT_DEVICE, LOG_COLOR_BLUE "\r[ %s ] " LOG_COLOR_RESET LOG_COLOR_RED fmt LOG_COLOR_RESET, tag, ##__VA_ARGS__);
#define LOGINFO(tag, fmt, ...) fprintf(LOG_OUT_DEVICE, LOG_COLOR_BLUE "\r[ %s ] " LOG_COLOR_RESET fmt "\n", tag, ##__VA_ARGS__);
#define LOGWARN(tag, fmt, ...) fprintf(LOG_OUT_DEVICE, LOG_COLOR_BLUE "\r[ %s ] " LOG_COLOR_RESET LOG_COLOR_YELLOW fmt LOG_COLOR_RESET "\n", tag, ##__VA_ARGS__);
#define LOGERR(tag, fmt, ...) fprintf(LOG_OUT_DEVICE, LOG_COLOR_BLUE "\r[ %s ] " LOG_COLOR_RESET LOG_COLOR_RED fmt LOG_COLOR_RESET "\n", tag, ##__VA_ARGS__);

#define MY_LOGE(tag, fmt, ...)                           \
    do {                                                 \
        if (DEFAULT_LOG_LEVEL >= MY_TRACE_LEVEL_ERROR) { \
            LOGERR(tag, fmt, ##__VA_ARGS__);             \
        }                                                \
    } while (0)
#define MY_LOGW(tag, fmt, ...)                             \
    do {                                                   \
        if (DEFAULT_LOG_LEVEL >= MY_TRACE_LEVEL_WARNING) { \
            LOGWARN(tag, fmt, ##__VA_ARGS__);              \
        }                                                  \
    } while (0)
#define MY_LOGI(tag, fmt, ...)                          \
    do {                                                \
        if (DEFAULT_LOG_LEVEL >= MY_TRACE_LEVEL_INFO) { \
            LOGINFO(tag, fmt, ##__VA_ARGS__);           \
        }                                               \
    } while (0)
#define MY_LOGCE(tag, fmt, ...)                          \
    do {                                                 \
        if (DEFAULT_LOG_LEVEL >= MY_TRACE_LEVEL_ERROR) { \
            LOGCERR(tag, fmt, ##__VA_ARGS__);            \
        }                                                \
    } while (0)
#define MY_LOGCW(tag, fmt, ...)                            \
    do {                                                   \
        if (DEFAULT_LOG_LEVEL >= MY_TRACE_LEVEL_WARNING) { \
            LOGCWARN(tag, fmt, ##__VA_ARGS__);             \
        }                                                  \
    } while (0)
#define MY_LOGCI(tag, fmt, ...)                         \
    do {                                                \
        if (DEFAULT_LOG_LEVEL >= MY_TRACE_LEVEL_INFO) { \
            LOGCINFO(tag, fmt, ##__VA_ARGS__);          \
        }                                               \
    } while (0)

#ifdef __cplusplus
}
#endif

#endif /* __MYLOG_H__ */
