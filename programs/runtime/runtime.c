
typedef unsigned int uint32_t;

#define RESULT_MAILBOX ((volatile uint32_t *)0x00000000u)
#define STATUS_MAILBOX ((volatile uint32_t *)0x00000004u)

__attribute__((noreturn)) void runtime_finish(int result) {
  *RESULT_MAILBOX = (uint32_t)result;
  *STATUS_MAILBOX = 1u;

  for (;;) {
  }
}

__attribute__((noreturn)) void exit(int status) {
  *RESULT_MAILBOX = (uint32_t)status;
  *STATUS_MAILBOX = (status == 0) ? 1u : 2u;

  for (;;) {
  }
}

__attribute__((noreturn)) void abort(void) {
  *RESULT_MAILBOX = 1u;
  *STATUS_MAILBOX = 2u;

  for (;;) {
  }
}
