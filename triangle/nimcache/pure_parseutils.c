/* Generated by Nimrod Compiler v0.9.3 */
/*   (c) 2012 Andreas Rumpf */
/* The generated code is subject to the original license. */
/* Compiled for: Linux, amd64, gcc */
/* Command for C compiler:
   gcc -c  -w  -I/home/rnentjes/Programming/nimrod/linux-x86_64/f30848148985/lib -o /home/rnentjes/Development/nimrod/nimrod-opengl/triangle/nimcache/pure_parseutils.o /home/rnentjes/Development/nimrod/nimrod-opengl/triangle/nimcache/pure_parseutils.c */
#define NIM_INTBITS 64
#include "nimbase.h"
typedef struct tslice74669 tslice74669;
struct tslice74669 {
NI A;
NI B;
};
static N_INLINE(void, HEX2AHEX3D_121330)(NF* x, NF y);
static N_INLINE(void, nimFrame)(TFrame* s);
static N_INLINE(void, popFrame)(void);
static N_INLINE(tslice74669, HEX2EHEX2E_121700)(NI a, NI b);
extern TFrame* frameptr_12025;

static N_INLINE(void, nimFrame)(TFrame* s) {
	(*s).prev = frameptr_12025;
	frameptr_12025 = s;
}
static N_INLINE(void, popFrame)(void) {
	frameptr_12025 = (*frameptr_12025).prev;
}
static N_INLINE(void, HEX2AHEX3D_121330)(NF* x, NF y) {
	nimfr("*=", "system.nim")
	nimln(2491, "system.nim");
	nimln(2491, "system.nim");
	(*x) = ((NF)((*x)) * (NF)(y));
	popFrame();
}
static N_INLINE(tslice74669, HEX2EHEX2E_121700)(NI a, NI b) {
	tslice74669 result;
	nimfr("..", "system.nim")
	memset((void*)&result, 0, sizeof(result));
	nimln(179, "system.nim");
	result.A = a;
	nimln(180, "system.nim");
	result.B = b;
	popFrame();
	return result;
}N_NOINLINE(void, pureparseutilsInit)(void) {
	nimfr("parseutils", "parseutils.nim")
	popFrame();
}

N_NOINLINE(void, pureparseutilsDatInit)(void) {
}

