
typedef unsigned int uint32_t;
typedef __SIZE_TYPE__ size_t;
typedef unsigned char byte_t;
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

void *memcpy(void *destination, const void *source, size_t count) {
  byte_t *dst = destination;
  const byte_t *src = source;

  for (size_t i = 0; i < count; i++) {
    dst[i] = src[i];
  }

  return destination;
}

void *memmove(void *destination, const void *source, size_t count) {
  byte_t *dst = destination;
  const byte_t *src = source;

  if (dst == src || count == 0) {
    return destination;
  }

  if (dst < src) {
    for (size_t i = 0; i < count; i++) {
      dst[i] = src[i];
    }
  } else {
    for (size_t i = count; i > 0; i--) {
      dst[i - 1] = src[i - 1];
    }
  }

  return destination;
}

void *memset(void *destination, int value, size_t count) {
  byte_t *dst = destination;
  byte_t fill = (byte_t)value;

  for (size_t i = 0; i < count; i++) {
    dst[i] = fill;
  }

  return destination;
}

int memcmp(const void *left, const void *right, size_t count) {
  const byte_t *lhs = left;
  const byte_t *rhs = right;

  for (size_t i = 0; i < count; i++) {
    if (lhs[i] != rhs[i]) {
      return (int)lhs[i] - (int)rhs[i];
    }
  }

  return 0;
}
