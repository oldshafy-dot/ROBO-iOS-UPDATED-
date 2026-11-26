#ifndef sandbox_escape_h
#define sandbox_escape_h

#include <stdint.h>
#include <stddef.h>

int sandbox_access_is_active(void);
/// Runs the same probes but writes a per-directory report into `buf`
/// ("path=ok(errno=0); path=fail(errno=2); ") and returns how many passed.
int sandbox_probe_report(char *buf, size_t cap);
int sandbox_escape(uint64_t self_proc);
int sandbox_elevate_to_root(uint64_t self_proc);

#endif
