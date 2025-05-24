#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "global_build_info_time.h"
#include "global_build_info_version.h"
#include "global_config.h"
#include "libutils_rust.h"

int main() {
    printf("==============================\n");
    printf("version: %d.%d.%d-%s-%d.%d\n",
           BUILD_VERSION_MAJOR, BUILD_VERSION_MINOR, BUILD_VERSION_MICRO,
           BUILD_GIT_COMMIT_ID, BUILD_VERSION_DEV, BUILD_GIT_IS_DIRTY);
    printf("build_time: %04d-%02d-%02d %02d:%02d:%02d\n",
           BUILD_TIME_YEAR, BUILD_TIME_MONTH, BUILD_TIME_DAY,
           BUILD_TIME_HOUR, BUILD_TIME_MINUTE, BUILD_TIME_SECOND);
    printf("week_of_day: %d\n", BUILD_TIME_WEEK_OF_DAY);
    printf("year_of_day: %d\n", BUILD_TIME_YEAR_OF_DAY);
    printf("==============================\n");

    int a = 28;
    int b = 44;

    printf("hello world!!!\r\n");
    printf("%d + %d = %d\n", a, b, add(a, b));
    printf("%d - %d = %d\n", a, b, sub(a, b));

    return 0;
}
