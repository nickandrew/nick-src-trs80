/* signal.h */

#define SIGHUP       1
#define SIGINT       2
#define SIGQUIT      3

#define SIG_DFL      0
#define SIG_IGN      1

typedef void (*sighandler_t)(int);

extern sighandler_t signal(int signum, sighandler_t handler);
