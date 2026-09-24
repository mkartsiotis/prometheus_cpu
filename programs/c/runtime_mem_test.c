
typedef unsigned int size_t;

void *memcpy(void *, const void *, size_t);
void *memmove(void *, const void *, size_t);
void *memset(void *, int, size_t);
int memcmp(const void *, const void *, size_t);

static int check_bytes(const unsigned char *actual,
                       const unsigned char *expected, size_t count) {
  return memcmp(actual, expected, count) == 0;
}

int main(void) {
  unsigned char source[8];
  unsigned char destination[8];
  unsigned char expected[8];
  unsigned char overlap[8];

  memset(source, 0xa5, sizeof(source));

  for (size_t i = 0; i < sizeof(expected); i++) {
    expected[i] = 0xa5;
  }

  if (!check_bytes(source, expected, sizeof(source))) {
    return 1;
  }

  memcpy(destination, source, sizeof(source));

  if (!check_bytes(destination, expected, sizeof(destination))) {
    return 1;
  }

  overlap[0] = 1;
  overlap[1] = 2;
  overlap[2] = 3;
  overlap[3] = 4;
  overlap[4] = 5;
  overlap[5] = 6;
  overlap[6] = 7;
  overlap[7] = 8;

  memmove(&overlap[2], &overlap[0], 6);

  if (overlap[2] != 1 || overlap[3] != 2 || overlap[4] != 3 ||
      overlap[5] != 4 || overlap[6] != 5 || overlap[7] != 6) {
    return 1;
  }

  return 0;
}
