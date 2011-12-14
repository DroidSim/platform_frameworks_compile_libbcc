//===-- GDBJITRegistrar.h - Common Implementation shared by GDB-JIT users --===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains declarations of the interface an ExecutionEngine would use
// to register an in-memory object file with GDB.
//
//===----------------------------------------------------------------------===//

#ifndef GDBJITREGISTRAR_H
#define GDBJITREGISTRAR_H

#include <cstddef>

// Buffer for an in-memory object file in executable memory
typedef char ObjectBuffer;

void registerObjectWithGDB(const ObjectBuffer* Object, std::size_t Size);
void deregisterObjectWithGDB(const ObjectBuffer* Object);

#endif // GDBJITREGISTRAR_H
