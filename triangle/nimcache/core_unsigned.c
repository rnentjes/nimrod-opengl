/* Generated by Nimrod Compiler v0.9.3 */
/*   (c) 2012 Andreas Rumpf */
/* The generated code is subject to the original license. */
/* Compiled for: Linux, amd64, gcc */
/* Command for C compiler:
   gcc -c  -w  -I/home/rnentjes/Programming/nimrod/linux-x86_64/f30848148985/lib -o /home/rnentjes/Development/nimrod/nimrod-opengl/triangle/nimcache/core_unsigned.o /home/rnentjes/Development/nimrod/nimrod-opengl/triangle/nimcache/core_unsigned.c */
#define NIM_INTBITS 64
#include "nimbase.h"
static N_INLINE(void, nimFrame)(TFrame* s);
static N_INLINE(void, popFrame)(void);
extern TFrame* frameptr_12025;

static N_INLINE(void, nimFrame)(TFrame* s) {
	(*s).prev = frameptr_12025;
	frameptr_12025 = s;
}
static N_INLINE(void, popFrame)(void) {
	frameptr_12025 = (*frameptr_12025).prev;
}N_NOINLINE(void, coreunsignedInit)(void) {
	nimfr("unsigned", "unsigned.nim")
	popFrame();
}

N_NOINLINE(void, coreunsignedDatInit)(void) {
}

