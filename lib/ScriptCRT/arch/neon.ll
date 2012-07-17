target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:64:128-a0:0:64-n32-S64"
target triple = "armv7-none-linux-gnueabi"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;               INTRINSICS               ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

declare <2 x float> @llvm.arm.neon.vmaxs.v2f32(<2 x float>, <2 x float>) nounwind readnone
declare <4 x float> @llvm.arm.neon.vmaxs.v4f32(<4 x float>, <4 x float>) nounwind readnone
declare <2 x i32> @llvm.arm.neon.vmaxs.v2i32(<2 x i32>, <2 x i32>) nounwind readnone
declare <4 x i32> @llvm.arm.neon.vmaxs.v4i32(<4 x i32>, <4 x i32>) nounwind readnone
declare <2 x i32> @llvm.arm.neon.vmaxu.v2i32(<2 x i32>, <2 x i32>) nounwind readnone
declare <4 x i32> @llvm.arm.neon.vmaxu.v4i32(<4 x i32>, <4 x i32>) nounwind readnone

declare <2 x float> @llvm.arm.neon.vmins.v2f32(<2 x float>, <2 x float>) nounwind readnone
declare <4 x float> @llvm.arm.neon.vmins.v4f32(<4 x float>, <4 x float>) nounwind readnone
declare <2 x i32> @llvm.arm.neon.vmins.v2i32(<2 x i32>, <2 x i32>) nounwind readnone
declare <4 x i32> @llvm.arm.neon.vmins.v4i32(<4 x i32>, <4 x i32>) nounwind readnone
declare <2 x i32> @llvm.arm.neon.vminu.v2i32(<2 x i32>, <2 x i32>) nounwind readnone
declare <4 x i32> @llvm.arm.neon.vminu.v4i32(<4 x i32>, <4 x i32>) nounwind readnone


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;                HELPERS                 ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define internal <4 x float> @smear_4f(float %in) nounwind readnone alwaysinline {
  %1 = insertelement <4 x float> undef, float %in, i32 0
  %2 = insertelement <4 x float> %1, float %in, i32 1
  %3 = insertelement <4 x float> %2, float %in, i32 2
  %4 = insertelement <4 x float> %3, float %in, i32 3
  ret <4 x float> %4
}

define internal <2 x float> @smear_2f(float %in) nounwind readnone alwaysinline {
  %1 = insertelement <2 x float> undef, float %in, i32 0
  %2 = insertelement <2 x float> %1, float %in, i32 1
  ret <2 x float> %2
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;                 CLAMP                  ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define <4 x float> @_Z5clampDv4_fS_S_(<4 x float> %value, <4 x float> %low, <4 x float> %high) nounwind readonly {
  %1 = tail call <4 x float> @llvm.arm.neon.vmins.v4f32(<4 x float> %value, <4 x float> %high) nounwind readnone
  %2 = tail call <4 x float> @llvm.arm.neon.vmaxs.v4f32(<4 x float> %1, <4 x float> %low) nounwind readnone
  ret <4 x float> %2
}

define <4 x float> @_Z5clampDv4_fff(<4 x float> %value, float %low, float %high) nounwind readonly {
  %_high = tail call <4 x float> @smear_4f(float %high) nounwind readnone
  %_low = tail call <4 x float> @smear_4f(float %low) nounwind readnone
  %out = tail call <4 x float> @_Z5clampDv4_fS_S_(<4 x float> %value, <4 x float> %_low, <4 x float> %_high) nounwind readonly
  ret <4 x float> %out
}

define <3 x float> @_Z5clampDv3_fS_S_(<3 x float> %value, <3 x float> %low, <3 x float> %high) nounwind readonly {
  %_value = shufflevector <3 x float> %value, <3 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %_low = shufflevector <3 x float> %low, <3 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %_high = shufflevector <3 x float> %high, <3 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %a = tail call <4 x float> @llvm.arm.neon.vmins.v4f32(<4 x float> %_value, <4 x float> %_high) nounwind readnone
  %b = tail call <4 x float> @llvm.arm.neon.vmaxs.v4f32(<4 x float> %a, <4 x float> %_low) nounwind readnone
  %c = shufflevector <4 x float> %b, <4 x float> undef, <3 x i32> <i32 0, i32 1, i32 2>
  ret <3 x float> %c
}

define <3 x float> @_Z5clampDv3_fff(<3 x float> %value, float %low, float %high) nounwind readonly {
  %_value = shufflevector <3 x float> %value, <3 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %_high = tail call <4 x float> @smear_4f(float %high) nounwind readnone
  %_low = tail call <4 x float> @smear_4f(float %low) nounwind readnone
  %a = tail call <4 x float> @llvm.arm.neon.vmins.v4f32(<4 x float> %_value, <4 x float> %_high) nounwind readnone
  %b = tail call <4 x float> @llvm.arm.neon.vmaxs.v4f32(<4 x float> %a, <4 x float> %_low) nounwind readnone
  %c = shufflevector <4 x float> %b, <4 x float> undef, <3 x i32> <i32 0, i32 1, i32 2>
  ret <3 x float> %c
}

define <2 x float> @_Z5clampDv2_fS_S_(<2 x float> %value, <2 x float> %low, <2 x float> %high) nounwind readonly {
  %1 = tail call <2 x float> @llvm.arm.neon.vmins.v2f32(<2 x float> %value, <2 x float> %high) nounwind readnone
  %2 = tail call <2 x float> @llvm.arm.neon.vmaxs.v2f32(<2 x float> %1, <2 x float> %low) nounwind readnone
  ret <2 x float> %2
}

define <2 x float> @_Z5clampDv2_fff(<2 x float> %value, float %low, float %high) nounwind readonly {
  %_high = tail call <2 x float> @smear_2f(float %high) nounwind readnone
  %_low = tail call <2 x float> @smear_2f(float %low) nounwind readnone
  %a = tail call <2 x float> @llvm.arm.neon.vmins.v2f32(<2 x float> %value, <2 x float> %_high) nounwind readnone
  %b = tail call <2 x float> @llvm.arm.neon.vmaxs.v2f32(<2 x float> %a, <2 x float> %_low) nounwind readnone
  ret <2 x float> %b
}


define float @_Z5clampfff(float %value, float %low, float %high) nounwind readonly {
  %_value = tail call <2 x float> @smear_2f(float %value) nounwind readnone
  %_low = tail call <2 x float> @smear_2f(float %low) nounwind readnone
  %_high = tail call <2 x float> @smear_2f(float %high) nounwind readnone
  %a = tail call <2 x float> @llvm.arm.neon.vmins.v2f32(<2 x float> %_value, <2 x float> %_high) nounwind readnone
  %b = tail call <2 x float> @llvm.arm.neon.vmaxs.v2f32(<2 x float> %a, <2 x float> %_low) nounwind readnone
  %c = extractelement <2 x float> %b, i32 0
  ret float %c
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;                  FMAX                  ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define <4 x float> @_Z4fmaxDv4_fS_(<4 x float> %v1, <4 x float> %v2) nounwind readonly {
  %1 = tail call <4 x float> @llvm.arm.neon.vmaxs.v4f32(<4 x float> %v1, <4 x float> %v2) nounwind readnone
  ret <4 x float> %1
}

define <4 x float> @_Z4fmaxDv4_ff(<4 x float> %v1, float %v2) nounwind readonly {
  %1 = tail call <4 x float> @smear_4f(float %v2) nounwind readnone
  %2 = tail call <4 x float> @llvm.arm.neon.vmaxs.v4f32(<4 x float> %v1, <4 x float> %1) nounwind readnone
  ret <4 x float> %2
}

define <3 x float> @_Z4fmaxDv3_fS_(<3 x float> %v1, <3 x float> %v2) nounwind readonly {
  %1 = shufflevector <3 x float> %v1, <3 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %2 = shufflevector <3 x float> %v2, <3 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = tail call <4 x float> @llvm.arm.neon.vmaxs.v4f32(<4 x float> %1, <4 x float> %2) nounwind readnone
  %4 = shufflevector <4 x float> %3, <4 x float> undef, <3 x i32> <i32 0, i32 1, i32 2>
  ret <3 x float> %4
}

define <3 x float> @_Z4fmaxDv3_ff(<3 x float> %v1, float %v2) nounwind readonly {
  %1 = shufflevector <3 x float> %v1, <3 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %2 = tail call <4 x float> @smear_4f(float %v2) nounwind readnone
  %3 = tail call <4 x float> @llvm.arm.neon.vmaxs.v4f32(<4 x float> %1, <4 x float> %2) nounwind readnone
  %c = shufflevector <4 x float> %3, <4 x float> undef, <3 x i32> <i32 0, i32 1, i32 2>
  ret <3 x float> %c
}

define <2 x float> @_Z4fmaxDv2_fS_(<2 x float> %v1, <2 x float> %v2) nounwind readonly {
  %1 = tail call <2 x float> @llvm.arm.neon.vmaxs.v2f32(<2 x float> %v1, <2 x float> %v2) nounwind readnone
  ret <2 x float> %1
}

define <2 x float> @_Z4fmaxDv2_ff(<2 x float> %v1, float %v2) nounwind readonly {
  %1 = tail call <2 x float> @smear_2f(float %v2) nounwind readnone
  %2 = tail call <2 x float> @llvm.arm.neon.vmaxs.v2f32(<2 x float> %v1, <2 x float> %1) nounwind readnone
  ret <2 x float> %2
}

define float @_Z4fmaxff(float %v1, float %v2) nounwind readonly {
  %1 = fcmp ogt float %v1, %v2
  %2 = select i1 %1, float %v1, float %v2
  ret float %2
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;                  FMIN                  ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define <4 x float> @_Z4fminDv4_fS_(<4 x float> %v1, <4 x float> %v2) nounwind readonly {
  %1 = tail call <4 x float> @llvm.arm.neon.vmins.v4f32(<4 x float> %v1, <4 x float> %v2) nounwind readnone
  ret <4 x float> %1
}

define <4 x float> @_Z4fminDv4_ff(<4 x float> %v1, float %v2) nounwind readonly {
  %1 = tail call <4 x float> @smear_4f(float %v2) nounwind readnone
  %2 = tail call <4 x float> @llvm.arm.neon.vmins.v4f32(<4 x float> %v1, <4 x float> %1) nounwind readnone
  ret <4 x float> %2
}

define <3 x float> @_Z4fminDv3_fS_(<3 x float> %v1, <3 x float> %v2) nounwind readonly {
  %1 = shufflevector <3 x float> %v1, <3 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %2 = shufflevector <3 x float> %v2, <3 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = tail call <4 x float> @llvm.arm.neon.vmins.v4f32(<4 x float> %1, <4 x float> %2) nounwind readnone
  %4 = shufflevector <4 x float> %3, <4 x float> undef, <3 x i32> <i32 0, i32 1, i32 2>
  ret <3 x float> %4
}

define <3 x float> @_Z4fminDv3_ff(<3 x float> %v1, float %v2) nounwind readonly {
  %1 = shufflevector <3 x float> %v1, <3 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %2 = tail call <4 x float> @smear_4f(float %v2) nounwind readnone
  %3 = tail call <4 x float> @llvm.arm.neon.vmins.v4f32(<4 x float> %1, <4 x float> %2) nounwind readnone
  %c = shufflevector <4 x float> %3, <4 x float> undef, <3 x i32> <i32 0, i32 1, i32 2>
  ret <3 x float> %c
}

define <2 x float> @_Z4fminDv2_fS_(<2 x float> %v1, <2 x float> %v2) nounwind readonly {
  %1 = tail call <2 x float> @llvm.arm.neon.vmins.v2f32(<2 x float> %v1, <2 x float> %v2) nounwind readnone
  ret <2 x float> %1
}

define <2 x float> @_Z4fminDv2_ff(<2 x float> %v1, float %v2) nounwind readonly {
  %1 = tail call <2 x float> @smear_2f(float %v2) nounwind readnone
  %2 = tail call <2 x float> @llvm.arm.neon.vmins.v2f32(<2 x float> %v1, <2 x float> %1) nounwind readnone
  ret <2 x float> %2
}

define float @_Z4fminff(float %v1, float %v2) nounwind readnone {
  %1 = fcmp olt float %v1, %v2
  %2 = select i1 %1, float %v1, float %v2
  ret float %2
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;                  MAX                   ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define signext i8 @_Z3maxcc(i8 signext %v1, i8 signext %v2) nounwind readnone {
  %1 = icmp sgt i8 %v1, %v2
  %2 = select i1 %1, i8 %v1, i8 %v2
  ret i8 %2
}

define <2 x i8> @_Z3maxDv2_cS_(<2 x i8> %v1, <2 x i8> %v2) nounwind readnone {
  %1 = sext <2 x i8> %v1 to <2 x i32>
  %2 = sext <2 x i8> %v2 to <2 x i32>
  %3 = tail call <2 x i32> @llvm.arm.neon.vmaxs.v2i32(<2 x i32> %1, <2 x i32> %2) nounwind readnone
  %4 = trunc <2 x i32> %3 to <2 x i8>
  ret <2 x i8> %4
}

define <3 x i8> @_Z3maxDv3_cS_(<3 x i8> %v1, <3 x i8> %v2) nounwind readnone {
  %1 = sext <3 x i8> %v1 to <3 x i32>
  %2 = sext <3 x i8> %v2 to <3 x i32>
  %3 = shufflevector <3 x i32> %1, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %4 = shufflevector <3 x i32> %2, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %5 = tail call <4 x i32> @llvm.arm.neon.vmaxs.v4i32(<4 x i32> %3, <4 x i32> %4) nounwind readnone
  %6 = shufflevector <4 x i32> %5, <4 x i32> undef, <3 x i32> <i32 0, i32 1, i32 2>
  %7 = trunc <3 x i32> %6 to <3 x i8>
  ret <3 x i8> %7
}

define <4 x i8> @_Z3maxDv4_cS_(<4 x i8> %v1, <4 x i8> %v2) nounwind readnone {
  %1 = sext <4 x i8> %v1 to <4 x i32>
  %2 = sext <4 x i8> %v2 to <4 x i32>
  %3 = tail call <4 x i32> @llvm.arm.neon.vmaxs.v4i32(<4 x i32> %1, <4 x i32> %2) nounwind readnone
  %4 = trunc <4 x i32> %3 to <4 x i8>
  ret <4 x i8> %4
}

define signext i16 @_Z3maxss(i16 signext %v1, i16 signext %v2) nounwind readnone {
  %1 = icmp sgt i16 %v1, %v2
  %2 = select i1 %1, i16 %v1, i16 %v2
  ret i16 %2
}

define <2 x i16> @_Z3maxDv2_sS_(<2 x i16> %v1, <2 x i16> %v2) nounwind readnone {
  %1 = sext <2 x i16> %v1 to <2 x i32>
  %2 = sext <2 x i16> %v2 to <2 x i32>
  %3 = tail call <2 x i32> @llvm.arm.neon.vmaxs.v2i32(<2 x i32> %1, <2 x i32> %2) nounwind readnone
  %4 = trunc <2 x i32> %3 to <2 x i16>
  ret <2 x i16> %4
}

define <3 x i16> @_Z3maxDv3_sS_(<3 x i16> %v1, <3 x i16> %v2) nounwind readnone {
  %1 = sext <3 x i16> %v1 to <3 x i32>
  %2 = sext <3 x i16> %v2 to <3 x i32>
  %3 = shufflevector <3 x i32> %1, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %4 = shufflevector <3 x i32> %2, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %5 = tail call <4 x i32> @llvm.arm.neon.vmaxs.v4i32(<4 x i32> %3, <4 x i32> %4) nounwind readnone
  %6 = shufflevector <4 x i32> %5, <4 x i32> undef, <3 x i32> <i32 0, i32 1, i32 2>
  %7 = trunc <3 x i32> %6 to <3 x i16>
  ret <3 x i16> %7
}

define <4 x i16> @_Z3maxDv4_sS_(<4 x i16> %v1, <4 x i16> %v2) nounwind readnone {
  %1 = sext <4 x i16> %v1 to <4 x i32>
  %2 = sext <4 x i16> %v2 to <4 x i32>
  %3 = tail call <4 x i32> @llvm.arm.neon.vmaxs.v4i32(<4 x i32> %1, <4 x i32> %2) nounwind readnone
  %4 = trunc <4 x i32> %3 to <4 x i16>
  ret <4 x i16> %4
}

define i32 @_Z3maxii(i32 %v1, i32 %v2) nounwind readnone {
  %1 = icmp sgt i32 %v1, %v2
  %2 = select i1 %1, i32 %v1, i32 %v2
  ret i32 %2
}

define <2 x i32> @_Z3maxDv2_iS_(<2 x i32> %v1, <2 x i32> %v2) nounwind readnone {
  %1 = tail call <2 x i32> @llvm.arm.neon.vmaxs.v2i32(<2 x i32> %v1, <2 x i32> %v2) nounwind readnone
  ret <2 x i32> %1
}

define <3 x i32> @_Z3maxDv3_iS_(<3 x i32> %v1, <3 x i32> %v2) nounwind readnone {
  %1 = shufflevector <3 x i32> %v1, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %2 = shufflevector <3 x i32> %v2, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = tail call <4 x i32   > @llvm.arm.neon.vmaxs.v4i32(<4 x i32> %1, <4 x i32> %2) nounwind readnone
  %4 = shufflevector <4 x i32> %3, <4 x i32> undef, <3 x i32> <i32 0, i32 1, i32 2>
  ret <3 x i32> %4
}

define <4 x i32> @_Z3maxDv4_iS_(<4 x i32> %v1, <4 x i32> %v2) nounwind readnone {
  %1 = tail call <4 x i32> @llvm.arm.neon.vmaxs.v4i32(<4 x i32> %v1, <4 x i32> %v2) nounwind readnone
  ret <4 x i32> %1
}

define i64 @_Z3maxxx(i64 %v1, i64 %v2) nounwind readnone {
  %1 = icmp sgt i64 %v1, %v2
  %2 = select i1 %1, i64 %v1, i64 %v2
  ret i64 %2
}

; TODO:  long vector types

define zeroext i8 @_Z3maxhh(i8 zeroext %v1, i8 zeroext %v2) nounwind readnone {
  %1 = icmp ugt i8 %v1, %v2
  %2 = select i1 %1, i8 %v1, i8 %v2
  ret i8 %2
}

define <2 x i8> @_Z3maxDv2_hS_(<2 x i8> %v1, <2 x i8> %v2) nounwind readnone {
  %1 = zext <2 x i8> %v1 to <2 x i32>
  %2 = zext <2 x i8> %v2 to <2 x i32>
  %3 = tail call <2 x i32> @llvm.arm.neon.vmaxu.v2i32(<2 x i32> %1, <2 x i32> %2) nounwind readnone
  %4 = trunc <2 x i32> %3 to <2 x i8>
  ret <2 x i8> %4
}

define <3 x i8> @_Z3maxDv3_hS_(<3 x i8> %v1, <3 x i8> %v2) nounwind readnone {
  %1 = zext <3 x i8> %v1 to <3 x i32>
  %2 = zext <3 x i8> %v2 to <3 x i32>
  %3 = shufflevector <3 x i32> %1, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %4 = shufflevector <3 x i32> %2, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %5 = tail call <4 x i32> @llvm.arm.neon.vmaxu.v4i32(<4 x i32> %3, <4 x i32> %4) nounwind readnone
  %6 = shufflevector <4 x i32> %5, <4 x i32> undef, <3 x i32> <i32 0, i32 1, i32 2>
  %7 = trunc <3 x i32> %6 to <3 x i8>
  ret <3 x i8> %7
}

define <4 x i8> @_Z3maxDv4_hS_(<4 x i8> %v1, <4 x i8> %v2) nounwind readnone {
  %1 = zext <4 x i8> %v1 to <4 x i32>
  %2 = zext <4 x i8> %v2 to <4 x i32>
  %3 = tail call <4 x i32> @llvm.arm.neon.vmaxu.v4i32(<4 x i32> %1, <4 x i32> %2) nounwind readnone
  %4 = trunc <4 x i32> %3 to <4 x i8>
  ret <4 x i8> %4
}

define zeroext i16 @_Z3maxtt(i16 zeroext %v1, i16 zeroext %v2) nounwind readnone {
  %1 = icmp ugt i16 %v1, %v2
  %2 = select i1 %1, i16 %v1, i16 %v2
  ret i16 %2
}

define <2 x i16> @_Z3maxDv2_tS_(<2 x i16> %v1, <2 x i16> %v2) nounwind readnone {
  %1 = zext <2 x i16> %v1 to <2 x i32>
  %2 = zext <2 x i16> %v2 to <2 x i32>
  %3 = tail call <2 x i32> @llvm.arm.neon.vmaxu.v2i32(<2 x i32> %1, <2 x i32> %2) nounwind readnone
  %4 = trunc <2 x i32> %3 to <2 x i16>
  ret <2 x i16> %4
}

define <3 x i16> @_Z3maxDv3_tS_(<3 x i16> %v1, <3 x i16> %v2) nounwind readnone {
  %1 = zext <3 x i16> %v1 to <3 x i32>
  %2 = zext <3 x i16> %v2 to <3 x i32>
  %3 = shufflevector <3 x i32> %1, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %4 = shufflevector <3 x i32> %2, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %5 = tail call <4 x i32> @llvm.arm.neon.vmaxu.v4i32(<4 x i32> %3, <4 x i32> %4) nounwind readnone
  %6 = shufflevector <4 x i32> %5, <4 x i32> undef, <3 x i32> <i32 0, i32 1, i32 2>
  %7 = trunc <3 x i32> %6 to <3 x i16>
  ret <3 x i16> %7
}

define <4 x i16> @_Z3maxDv4_tS_(<4 x i16> %v1, <4 x i16> %v2) nounwind readnone {
  %1 = zext <4 x i16> %v1 to <4 x i32>
  %2 = zext <4 x i16> %v2 to <4 x i32>
  %3 = tail call <4 x i32> @llvm.arm.neon.vmaxu.v4i32(<4 x i32> %1, <4 x i32> %2) nounwind readnone
  %4 = trunc <4 x i32> %3 to <4 x i16>
  ret <4 x i16> %4
}

define i32 @_Z3maxjj(i32 %v1, i32 %v2) nounwind readnone {
  %1 = icmp ugt i32 %v1, %v2
  %2 = select i1 %1, i32 %v1, i32 %v2
  ret i32 %2
}

define <2 x i32> @_Z3maxDv2_jS_(<2 x i32> %v1, <2 x i32> %v2) nounwind readnone {
  %1 = tail call <2 x i32> @llvm.arm.neon.vmaxu.v2i32(<2 x i32> %v1, <2 x i32> %v2) nounwind readnone
  ret <2 x i32> %1
}

define <3 x i32> @_Z3maxDv3_jS_(<3 x i32> %v1, <3 x i32> %v2) nounwind readnone {
  %1 = shufflevector <3 x i32> %v1, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %2 = shufflevector <3 x i32> %v2, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = tail call <4 x i32   > @llvm.arm.neon.vmaxu.v4i32(<4 x i32> %1, <4 x i32> %2) nounwind readnone
  %4 = shufflevector <4 x i32> %3, <4 x i32> undef, <3 x i32> <i32 0, i32 1, i32 2>
  ret <3 x i32> %4
}

define <4 x i32> @_Z3maxDv4_jS_(<4 x i32> %v1, <4 x i32> %v2) nounwind readnone {
  %1 = tail call <4 x i32> @llvm.arm.neon.vmaxu.v4i32(<4 x i32> %v1, <4 x i32> %v2) nounwind readnone
  ret <4 x i32> %1
}

define i64 @_Z3maxyy(i64 %v1, i64 %v2) nounwind readnone {
  %1 = icmp ugt i64 %v1, %v2
  %2 = select i1 %1, i64 %v1, i64 %v2
  ret i64 %2
}

; TODO:  long vector types

define float @_Z3maxff(float %v1, float %v2) nounwind readnone {
  %1 = tail call float @_Z4fmaxff(float %v1, float %v2)
  ret float %1
}

define <2 x float> @_Z3maxDv2_fS_(<2 x float> %v1, <2 x float> %v2) nounwind readnone {
  %1 = tail call <2 x float> @_Z4fmaxDv2_fS_(<2 x float> %v1, <2 x float> %v2)
  ret <2 x float> %1
}

define <2 x float> @_Z3maxDv2_ff(<2 x float> %v1, float %v2) nounwind readnone {
  %1 = tail call <2 x float> @_Z4fmaxDv2_ff(<2 x float> %v1, float %v2)
  ret <2 x float> %1
}

define <3 x float> @_Z3maxDv3_fS_(<3 x float> %v1, <3 x float> %v2) nounwind readnone {
  %1 = tail call <3 x float> @_Z4fmaxDv3_fS_(<3 x float> %v1, <3 x float> %v2)
  ret <3 x float> %1
}

define <3 x float> @_Z3maxDv3_ff(<3 x float> %v1, float %v2) nounwind readnone {
  %1 = tail call <3 x float> @_Z4fmaxDv3_ff(<3 x float> %v1, float %v2)
  ret <3 x float> %1
}

define <4 x float> @_Z3maxDv4_fS_(<4 x float> %v1, <4 x float> %v2) nounwind readnone {
  %1 = tail call <4 x float> @_Z4fmaxDv4_fS_(<4 x float> %v1, <4 x float> %v2)
  ret <4 x float> %1
}

define <4 x float> @_Z3maxDv4_ff(<4 x float> %v1, float %v2) nounwind readnone {
  %1 = tail call <4 x float> @_Z4fmaxDv4_ff(<4 x float> %v1, float %v2)
  ret <4 x float> %1
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;                  MIN                   ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define signext i8 @_Z3mincc(i8 signext %v1, i8 signext %v2) nounwind readnone {
  %1 = icmp slt i8 %v1, %v2
  %2 = select i1 %1, i8 %v1, i8 %v2
  ret i8 %2
}

define <2 x i8> @_Z3minDv2_cS_(<2 x i8> %v1, <2 x i8> %v2) nounwind readnone {
  %1 = sext <2 x i8> %v1 to <2 x i32>
  %2 = sext <2 x i8> %v2 to <2 x i32>
  %3 = tail call <2 x i32> @llvm.arm.neon.vmins.v2i32(<2 x i32> %1, <2 x i32> %2) nounwind readnone
  %4 = trunc <2 x i32> %3 to <2 x i8>
  ret <2 x i8> %4
}

define <3 x i8> @_Z3minDv3_cS_(<3 x i8> %v1, <3 x i8> %v2) nounwind readnone {
  %1 = sext <3 x i8> %v1 to <3 x i32>
  %2 = sext <3 x i8> %v2 to <3 x i32>
  %3 = shufflevector <3 x i32> %1, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %4 = shufflevector <3 x i32> %2, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %5 = tail call <4 x i32> @llvm.arm.neon.vmins.v4i32(<4 x i32> %3, <4 x i32> %4) nounwind readnone
  %6 = shufflevector <4 x i32> %5, <4 x i32> undef, <3 x i32> <i32 0, i32 1, i32 2>
  %7 = trunc <3 x i32> %6 to <3 x i8>
  ret <3 x i8> %7
}

define <4 x i8> @_Z3minDv4_cS_(<4 x i8> %v1, <4 x i8> %v2) nounwind readnone {
  %1 = sext <4 x i8> %v1 to <4 x i32>
  %2 = sext <4 x i8> %v2 to <4 x i32>
  %3 = tail call <4 x i32> @llvm.arm.neon.vmins.v4i32(<4 x i32> %1, <4 x i32> %2) nounwind readnone
  %4 = trunc <4 x i32> %3 to <4 x i8>
  ret <4 x i8> %4
}

define signext i16 @_Z3minss(i16 signext %v1, i16 signext %v2) nounwind readnone {
  %1 = icmp slt i16 %v1, %v2
  %2 = select i1 %1, i16 %v1, i16 %v2
  ret i16 %2
}

define <2 x i16> @_Z3minDv2_sS_(<2 x i16> %v1, <2 x i16> %v2) nounwind readnone {
  %1 = sext <2 x i16> %v1 to <2 x i32>
  %2 = sext <2 x i16> %v2 to <2 x i32>
  %3 = tail call <2 x i32> @llvm.arm.neon.vmins.v2i32(<2 x i32> %1, <2 x i32> %2) nounwind readnone
  %4 = trunc <2 x i32> %3 to <2 x i16>
  ret <2 x i16> %4
}

define <3 x i16> @_Z3minDv3_sS_(<3 x i16> %v1, <3 x i16> %v2) nounwind readnone {
  %1 = sext <3 x i16> %v1 to <3 x i32>
  %2 = sext <3 x i16> %v2 to <3 x i32>
  %3 = shufflevector <3 x i32> %1, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %4 = shufflevector <3 x i32> %2, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %5 = tail call <4 x i32> @llvm.arm.neon.vmins.v4i32(<4 x i32> %3, <4 x i32> %4) nounwind readnone
  %6 = shufflevector <4 x i32> %5, <4 x i32> undef, <3 x i32> <i32 0, i32 1, i32 2>
  %7 = trunc <3 x i32> %6 to <3 x i16>
  ret <3 x i16> %7
}

define <4 x i16> @_Z3minDv4_sS_(<4 x i16> %v1, <4 x i16> %v2) nounwind readnone {
  %1 = sext <4 x i16> %v1 to <4 x i32>
  %2 = sext <4 x i16> %v2 to <4 x i32>
  %3 = tail call <4 x i32> @llvm.arm.neon.vmins.v4i32(<4 x i32> %1, <4 x i32> %2) nounwind readnone
  %4 = trunc <4 x i32> %3 to <4 x i16>
  ret <4 x i16> %4
}

define i32 @_Z3minii(i32 %v1, i32 %v2) nounwind readnone {
  %1 = icmp slt i32 %v1, %v2
  %2 = select i1 %1, i32 %v1, i32 %v2
  ret i32 %2
}

define <2 x i32> @_Z3minDv2_iS_(<2 x i32> %v1, <2 x i32> %v2) nounwind readnone {
  %1 = tail call <2 x i32> @llvm.arm.neon.vmins.v2i32(<2 x i32> %v1, <2 x i32> %v2) nounwind readnone
  ret <2 x i32> %1
}

define <3 x i32> @_Z3minDv3_iS_(<3 x i32> %v1, <3 x i32> %v2) nounwind readnone {
  %1 = shufflevector <3 x i32> %v1, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %2 = shufflevector <3 x i32> %v2, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = tail call <4 x i32   > @llvm.arm.neon.vmins.v4i32(<4 x i32> %1, <4 x i32> %2) nounwind readnone
  %4 = shufflevector <4 x i32> %3, <4 x i32> undef, <3 x i32> <i32 0, i32 1, i32 2>
  ret <3 x i32> %4
}

define <4 x i32> @_Z3minDv4_iS_(<4 x i32> %v1, <4 x i32> %v2) nounwind readnone {
  %1 = tail call <4 x i32> @llvm.arm.neon.vmins.v4i32(<4 x i32> %v1, <4 x i32> %v2) nounwind readnone
  ret <4 x i32> %1
}

define i64 @_Z3minxx(i64 %v1, i64 %v2) nounwind readnone {
  %1 = icmp slt i64 %v1, %v2
  %2 = select i1 %1, i64 %v1, i64 %v2
  ret i64 %2
}

; TODO:  long vector types

define zeroext i8 @_Z3minhh(i8 zeroext %v1, i8 zeroext %v2) nounwind readnone {
  %1 = icmp ult i8 %v1, %v2
  %2 = select i1 %1, i8 %v1, i8 %v2
  ret i8 %2
}

define <2 x i8> @_Z3minDv2_hS_(<2 x i8> %v1, <2 x i8> %v2) nounwind readnone {
  %1 = zext <2 x i8> %v1 to <2 x i32>
  %2 = zext <2 x i8> %v2 to <2 x i32>
  %3 = tail call <2 x i32> @llvm.arm.neon.vminu.v2i32(<2 x i32> %1, <2 x i32> %2) nounwind readnone
  %4 = trunc <2 x i32> %3 to <2 x i8>
  ret <2 x i8> %4
}

define <3 x i8> @_Z3minDv3_hS_(<3 x i8> %v1, <3 x i8> %v2) nounwind readnone {
  %1 = zext <3 x i8> %v1 to <3 x i32>
  %2 = zext <3 x i8> %v2 to <3 x i32>
  %3 = shufflevector <3 x i32> %1, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %4 = shufflevector <3 x i32> %2, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %5 = tail call <4 x i32> @llvm.arm.neon.vminu.v4i32(<4 x i32> %3, <4 x i32> %4) nounwind readnone
  %6 = shufflevector <4 x i32> %5, <4 x i32> undef, <3 x i32> <i32 0, i32 1, i32 2>
  %7 = trunc <3 x i32> %6 to <3 x i8>
  ret <3 x i8> %7
}

define <4 x i8> @_Z3minDv4_hS_(<4 x i8> %v1, <4 x i8> %v2) nounwind readnone {
  %1 = zext <4 x i8> %v1 to <4 x i32>
  %2 = zext <4 x i8> %v2 to <4 x i32>
  %3 = tail call <4 x i32> @llvm.arm.neon.vminu.v4i32(<4 x i32> %1, <4 x i32> %2) nounwind readnone
  %4 = trunc <4 x i32> %3 to <4 x i8>
  ret <4 x i8> %4
}

define zeroext i16 @_Z3mintt(i16 zeroext %v1, i16 zeroext %v2) nounwind readnone {
  %1 = icmp ult i16 %v1, %v2
  %2 = select i1 %1, i16 %v1, i16 %v2
  ret i16 %2
}

define <2 x i16> @_Z3minDv2_tS_(<2 x i16> %v1, <2 x i16> %v2) nounwind readnone {
  %1 = zext <2 x i16> %v1 to <2 x i32>
  %2 = zext <2 x i16> %v2 to <2 x i32>
  %3 = tail call <2 x i32> @llvm.arm.neon.vminu.v2i32(<2 x i32> %1, <2 x i32> %2) nounwind readnone
  %4 = trunc <2 x i32> %3 to <2 x i16>
  ret <2 x i16> %4
}

define <3 x i16> @_Z3minDv3_tS_(<3 x i16> %v1, <3 x i16> %v2) nounwind readnone {
  %1 = zext <3 x i16> %v1 to <3 x i32>
  %2 = zext <3 x i16> %v2 to <3 x i32>
  %3 = shufflevector <3 x i32> %1, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %4 = shufflevector <3 x i32> %2, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %5 = tail call <4 x i32> @llvm.arm.neon.vminu.v4i32(<4 x i32> %3, <4 x i32> %4) nounwind readnone
  %6 = shufflevector <4 x i32> %5, <4 x i32> undef, <3 x i32> <i32 0, i32 1, i32 2>
  %7 = trunc <3 x i32> %6 to <3 x i16>
  ret <3 x i16> %7
}

define <4 x i16> @_Z3minDv4_tS_(<4 x i16> %v1, <4 x i16> %v2) nounwind readnone {
  %1 = zext <4 x i16> %v1 to <4 x i32>
  %2 = zext <4 x i16> %v2 to <4 x i32>
  %3 = tail call <4 x i32> @llvm.arm.neon.vminu.v4i32(<4 x i32> %1, <4 x i32> %2) nounwind readnone
  %4 = trunc <4 x i32> %3 to <4 x i16>
  ret <4 x i16> %4
}

define i32 @_Z3minjj(i32 %v1, i32 %v2) nounwind readnone {
  %1 = icmp ult i32 %v1, %v2
  %2 = select i1 %1, i32 %v1, i32 %v2
  ret i32 %2
}

define <2 x i32> @_Z3minDv2_jS_(<2 x i32> %v1, <2 x i32> %v2) nounwind readnone {
  %1 = tail call <2 x i32> @llvm.arm.neon.vminu.v2i32(<2 x i32> %v1, <2 x i32> %v2) nounwind readnone
  ret <2 x i32> %1
}

define <3 x i32> @_Z3minDv3_jS_(<3 x i32> %v1, <3 x i32> %v2) nounwind readnone {
  %1 = shufflevector <3 x i32> %v1, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %2 = shufflevector <3 x i32> %v2, <3 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %3 = tail call <4 x i32   > @llvm.arm.neon.vminu.v4i32(<4 x i32> %1, <4 x i32> %2) nounwind readnone
  %4 = shufflevector <4 x i32> %3, <4 x i32> undef, <3 x i32> <i32 0, i32 1, i32 2>
  ret <3 x i32> %4
}

define <4 x i32> @_Z3minDv4_jS_(<4 x i32> %v1, <4 x i32> %v2) nounwind readnone {
  %1 = tail call <4 x i32> @llvm.arm.neon.vminu.v4i32(<4 x i32> %v1, <4 x i32> %v2) nounwind readnone
  ret <4 x i32> %1
}

define i64 @_Z3minyy(i64 %v1, i64 %v2) nounwind readnone {
  %1 = icmp ult i64 %v1, %v2
  %2 = select i1 %1, i64 %v1, i64 %v2
  ret i64 %2
}

; TODO:  long vector types

define float @_Z3minff(float %v1, float %v2) nounwind readnone {
  %1 = tail call float @_Z4fminff(float %v1, float %v2)
  ret float %1
}

define <2 x float> @_Z3minDv2_fS_(<2 x float> %v1, <2 x float> %v2) nounwind readnone {
  %1 = tail call <2 x float> @_Z4fminDv2_fS_(<2 x float> %v1, <2 x float> %v2)
  ret <2 x float> %1
}

define <2 x float> @_Z3minDv2_ff(<2 x float> %v1, float %v2) nounwind readnone {
  %1 = tail call <2 x float> @_Z4fminDv2_ff(<2 x float> %v1, float %v2)
  ret <2 x float> %1
}

define <3 x float> @_Z3minDv3_ff(<3 x float> %v1, float %v2) nounwind readnone {
  %1 = tail call <3 x float> @_Z4fminDv3_ff(<3 x float> %v1, float %v2)
  ret <3 x float> %1
}

define <4 x float> @_Z3minDv4_fS_(<4 x float> %v1, <4 x float> %v2) nounwind readnone {
  %1 = tail call <4 x float> @_Z4fminDv4_fS_(<4 x float> %v1, <4 x float> %v2)
  ret <4 x float> %1
}

define <4 x float> @_Z3minDv4_ff(<4 x float> %v1, float %v2) nounwind readnone {
  %1 = tail call <4 x float> @_Z4fminDv4_ff(<4 x float> %v1, float %v2)
  ret <4 x float> %1
}
