/*
 * Copyright 2011-2012, The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef __ANDROID_BCINFO_BITCODEWRAPPER_H__
#define __ANDROID_BCINFO_BITCODEWRAPPER_H__

#include "bcinfo/Wrap/BCHeaderField.h"

#include <cstddef>
#include <stdint.h>

namespace bcinfo {

enum BCFileType {
  BC_NOT_BC = 0,
  BC_WRAPPER = 1,
  BC_RAW = 2
};

class BitcodeWrapper {
 private:
  enum BCFileType mFileType;
  const char *mBitcode;
  const char *mBitcodeEnd;
  size_t mBitcodeSize;

  uint32_t mHeaderVersion;
  uint32_t mTargetAPI;
  uint32_t mCompilerVersion;
  uint32_t mOptimizationLevel;

 public:
  /**
   * Reads wrapper information from \p bitcode.
   *
   * \param bitcode - input bitcode string.
   * \param bitcodeSize - length of \p bitcode string (in bytes).
   */
  BitcodeWrapper(const char *bitcode, size_t bitcodeSize);

  ~BitcodeWrapper();

  /**
   * Attempt to unwrap the target bitcode. This function is \deprecated.
   *
   * \return true on success and false if an error occurred.
   */
  bool unwrap();

  /**
   * \return type of bitcode file.
   */
  enum BCFileType getBCFileType() const {
    return mFileType;
  }

  /**
   * \return header version of bitcode wrapper.
   */
  uint32_t getHeaderVersion() const {
    return mHeaderVersion;
  }

  /**
   * \return target API version for this bitcode.
   */
  uint32_t getTargetAPI() const {
    return mTargetAPI;
  }

  /**
   * \return compiler version that generated this bitcode.
   */
  uint32_t getCompilerVersion() const {
    return mCompilerVersion;
  }

  /**
   * \return compiler optimization level for this bitcode.
   */
  uint32_t getOptimizationLevel() const {
    return mOptimizationLevel;
  }

};

/**
 * Helper function to emit just the bitcode wrapper into a \p buffer,
 * returning the number of bytes that were written.
 *
 * \param buffer - where to write header information into.
 * \param bufferLen - maximum length that can be written into \p buffer.
 * \param bitcodeSize - size of bitcode in bytes.
 * \param targetAPI - target API version for this bitcode.
 * \param compilerVersion - compiler version that generated this bitcode.
 * \param optimizationLevel - compiler optimization level for this bitcode.
 *
 * \return number of wrapper bytes written into the \p buffer.
 */
static inline size_t writeAndroidBitcodeWrapper(char *buffer, size_t bufferLen,
    size_t bitcodeSize, uint32_t targetAPI, uint32_t compilerVersion,
    uint32_t optimizationLevel) {
  // Statically declare our common format and just write it directly.
  struct AndroidBitcodeWrapper {
    uint32_t Magic;
    uint32_t Version;
    uint32_t BitcodeOffset;
    uint32_t BitcodeSize;
    uint32_t HeaderVersion;
    uint32_t TargetAPI;
    uint32_t PNaClVersion;
    uint16_t CompilerVersionTag;
    uint16_t CompilerVersionLen;
    uint32_t CompilerVersion;
    uint16_t OptimizationLevelTag;
    uint16_t OptimizationLevelLen;
    uint32_t OptimizationLevel;
  };

  AndroidBitcodeWrapper ABCWrapper;

  // Don't copy anything if we can't fit our entire wrapper.
  if (!buffer || (bufferLen < sizeof(ABCWrapper))) {
    return 0;
  }

  ABCWrapper.Magic = 0x0B17C0DE;
  ABCWrapper.Version = 0;
  ABCWrapper.BitcodeOffset = sizeof(ABCWrapper);
  ABCWrapper.BitcodeSize = bitcodeSize;
  ABCWrapper.HeaderVersion = 0;
  ABCWrapper.TargetAPI = targetAPI;
  ABCWrapper.PNaClVersion = 0;
  ABCWrapper.CompilerVersionTag = BCHeaderField::kAndroidCompilerVersion;
  ABCWrapper.CompilerVersionLen = 4;
  ABCWrapper.CompilerVersion = compilerVersion;
  ABCWrapper.OptimizationLevelTag = BCHeaderField::kAndroidOptimizationLevel;
  ABCWrapper.OptimizationLevelLen = 4;
  ABCWrapper.OptimizationLevel = optimizationLevel;

  memcpy(buffer, &ABCWrapper, sizeof(ABCWrapper));

  return sizeof(ABCWrapper);
}

}  // namespace bcinfo

#endif  // __ANDROID_BCINFO_BITCODEWRAPPER_H__
