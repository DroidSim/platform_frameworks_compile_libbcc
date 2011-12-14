//===-- GDBJIT.cpp - Common Implementation shared by GDB-JIT users --------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file is used to support GDB's JIT interface 
//
//===----------------------------------------------------------------------===//

#include "llvm/Support/Compiler.h"

// This interface must be kept in sync with gdb/gdb/jit.h .
extern "C" {

  // Debuggers puts a breakpoint in this function.
  LLVM_ATTRIBUTE_NOINLINE void __jit_debug_register_code() { }

}
