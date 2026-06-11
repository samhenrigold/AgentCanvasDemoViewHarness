#import "Trampoline.h"

// x0=arg0, x1=meta, x2=fn  ->  call fn with x0=arg0, x20=meta (preserved); returns x0.
__attribute__((naked)) void *DLCallRet1_X20(void *arg0, void *meta, void *fn) {
    __asm__ volatile(
        "stp x29, x30, [sp, #-32]!\n"
        "mov x29, sp\n"
        "str x20, [sp, #16]\n"
        "mov x20, x1\n"     // metadata
        "mov x16, x2\n"     // fn (x16 scratch; x0 already = arg0)
        "blr x16\n"         // returns in x0
        "ldr x20, [sp, #16]\n"
        "ldp x29, x30, [sp], #32\n"
        "ret\n"
    );
}
