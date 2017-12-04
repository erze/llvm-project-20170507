; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-linux | FileCheck %s --check-prefix=32
; RUN: llc < %s -mtriple=x86_64-unknown-linux | FileCheck %s --check-prefix=64

define i64 @rotl64(i64 %A, i8 %Amt) nounwind {
; 32-LABEL: rotl64:
; 32:       # %bb.0:
; 32-NEXT:    pushl %ebx
; 32-NEXT:    pushl %edi
; 32-NEXT:    pushl %esi
; 32-NEXT:    movb {{[0-9]+}}(%esp), %cl
; 32-NEXT:    movl {{[0-9]+}}(%esp), %esi
; 32-NEXT:    movl {{[0-9]+}}(%esp), %edi
; 32-NEXT:    movl %esi, %eax
; 32-NEXT:    shll %cl, %eax
; 32-NEXT:    movl %edi, %edx
; 32-NEXT:    shldl %cl, %esi, %edx
; 32-NEXT:    testb $32, %cl
; 32-NEXT:    je .LBB0_2
; 32-NEXT:  # %bb.1:
; 32-NEXT:    movl %eax, %edx
; 32-NEXT:    xorl %eax, %eax
; 32-NEXT:  .LBB0_2:
; 32-NEXT:    movb $64, %ch
; 32-NEXT:    subb %cl, %ch
; 32-NEXT:    movl %edi, %ebx
; 32-NEXT:    movb %ch, %cl
; 32-NEXT:    shrl %cl, %ebx
; 32-NEXT:    shrdl %cl, %edi, %esi
; 32-NEXT:    testb $32, %ch
; 32-NEXT:    je .LBB0_4
; 32-NEXT:  # %bb.3:
; 32-NEXT:    movl %ebx, %esi
; 32-NEXT:    xorl %ebx, %ebx
; 32-NEXT:  .LBB0_4:
; 32-NEXT:    orl %ebx, %edx
; 32-NEXT:    orl %esi, %eax
; 32-NEXT:    popl %esi
; 32-NEXT:    popl %edi
; 32-NEXT:    popl %ebx
; 32-NEXT:    retl
;
; 64-LABEL: rotl64:
; 64:       # %bb.0:
; 64-NEXT:    movl %esi, %ecx
; 64-NEXT:    rolq %cl, %rdi
; 64-NEXT:    movq %rdi, %rax
; 64-NEXT:    retq
	%shift.upgrd.1 = zext i8 %Amt to i64
	%B = shl i64 %A, %shift.upgrd.1
	%Amt2 = sub i8 64, %Amt
	%shift.upgrd.2 = zext i8 %Amt2 to i64
	%C = lshr i64 %A, %shift.upgrd.2
	%D = or i64 %B, %C
	ret i64 %D
}

define i64 @rotr64(i64 %A, i8 %Amt) nounwind {
; 32-LABEL: rotr64:
; 32:       # %bb.0:
; 32-NEXT:    pushl %ebx
; 32-NEXT:    pushl %edi
; 32-NEXT:    pushl %esi
; 32-NEXT:    movb {{[0-9]+}}(%esp), %cl
; 32-NEXT:    movl {{[0-9]+}}(%esp), %edi
; 32-NEXT:    movl {{[0-9]+}}(%esp), %esi
; 32-NEXT:    movl %esi, %edx
; 32-NEXT:    shrl %cl, %edx
; 32-NEXT:    movl %edi, %eax
; 32-NEXT:    shrdl %cl, %esi, %eax
; 32-NEXT:    testb $32, %cl
; 32-NEXT:    je .LBB1_2
; 32-NEXT:  # %bb.1:
; 32-NEXT:    movl %edx, %eax
; 32-NEXT:    xorl %edx, %edx
; 32-NEXT:  .LBB1_2:
; 32-NEXT:    movb $64, %ch
; 32-NEXT:    subb %cl, %ch
; 32-NEXT:    movl %edi, %ebx
; 32-NEXT:    movb %ch, %cl
; 32-NEXT:    shll %cl, %ebx
; 32-NEXT:    shldl %cl, %edi, %esi
; 32-NEXT:    testb $32, %ch
; 32-NEXT:    je .LBB1_4
; 32-NEXT:  # %bb.3:
; 32-NEXT:    movl %ebx, %esi
; 32-NEXT:    xorl %ebx, %ebx
; 32-NEXT:  .LBB1_4:
; 32-NEXT:    orl %esi, %edx
; 32-NEXT:    orl %ebx, %eax
; 32-NEXT:    popl %esi
; 32-NEXT:    popl %edi
; 32-NEXT:    popl %ebx
; 32-NEXT:    retl
;
; 64-LABEL: rotr64:
; 64:       # %bb.0:
; 64-NEXT:    movl %esi, %ecx
; 64-NEXT:    rorq %cl, %rdi
; 64-NEXT:    movq %rdi, %rax
; 64-NEXT:    retq
	%shift.upgrd.3 = zext i8 %Amt to i64
	%B = lshr i64 %A, %shift.upgrd.3
	%Amt2 = sub i8 64, %Amt
	%shift.upgrd.4 = zext i8 %Amt2 to i64
	%C = shl i64 %A, %shift.upgrd.4
	%D = or i64 %B, %C
	ret i64 %D
}

define i64 @rotli64(i64 %A) nounwind {
; 32-LABEL: rotli64:
; 32:       # %bb.0:
; 32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; 32-NEXT:    movl %ecx, %edx
; 32-NEXT:    shldl $5, %eax, %edx
; 32-NEXT:    shldl $5, %ecx, %eax
; 32-NEXT:    retl
;
; 64-LABEL: rotli64:
; 64:       # %bb.0:
; 64-NEXT:    rolq $5, %rdi
; 64-NEXT:    movq %rdi, %rax
; 64-NEXT:    retq
	%B = shl i64 %A, 5
	%C = lshr i64 %A, 59
	%D = or i64 %B, %C
	ret i64 %D
}

define i64 @rotri64(i64 %A) nounwind {
; 32-LABEL: rotri64:
; 32:       # %bb.0:
; 32-NEXT:    movl {{[0-9]+}}(%esp), %edx
; 32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; 32-NEXT:    movl %ecx, %eax
; 32-NEXT:    shldl $27, %edx, %eax
; 32-NEXT:    shldl $27, %ecx, %edx
; 32-NEXT:    retl
;
; 64-LABEL: rotri64:
; 64:       # %bb.0:
; 64-NEXT:    rolq $59, %rdi
; 64-NEXT:    movq %rdi, %rax
; 64-NEXT:    retq
	%B = lshr i64 %A, 5
	%C = shl i64 %A, 59
	%D = or i64 %B, %C
	ret i64 %D
}

define i64 @rotl1_64(i64 %A) nounwind {
; 32-LABEL: rotl1_64:
; 32:       # %bb.0:
; 32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; 32-NEXT:    movl %ecx, %edx
; 32-NEXT:    shldl $1, %eax, %edx
; 32-NEXT:    shldl $1, %ecx, %eax
; 32-NEXT:    retl
;
; 64-LABEL: rotl1_64:
; 64:       # %bb.0:
; 64-NEXT:    rolq %rdi
; 64-NEXT:    movq %rdi, %rax
; 64-NEXT:    retq
	%B = shl i64 %A, 1
	%C = lshr i64 %A, 63
	%D = or i64 %B, %C
	ret i64 %D
}

define i64 @rotr1_64(i64 %A) nounwind {
; 32-LABEL: rotr1_64:
; 32:       # %bb.0:
; 32-NEXT:    movl {{[0-9]+}}(%esp), %edx
; 32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; 32-NEXT:    movl %ecx, %eax
; 32-NEXT:    shldl $31, %edx, %eax
; 32-NEXT:    shldl $31, %ecx, %edx
; 32-NEXT:    retl
;
; 64-LABEL: rotr1_64:
; 64:       # %bb.0:
; 64-NEXT:    rorq %rdi
; 64-NEXT:    movq %rdi, %rax
; 64-NEXT:    retq
	%B = shl i64 %A, 63
	%C = lshr i64 %A, 1
	%D = or i64 %B, %C
	ret i64 %D
}

define i32 @rotl32(i32 %A, i8 %Amt) nounwind {
; 32-LABEL: rotl32:
; 32:       # %bb.0:
; 32-NEXT:    movb {{[0-9]+}}(%esp), %cl
; 32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    roll %cl, %eax
; 32-NEXT:    retl
;
; 64-LABEL: rotl32:
; 64:       # %bb.0:
; 64-NEXT:    movl %esi, %ecx
; 64-NEXT:    roll %cl, %edi
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%shift.upgrd.1 = zext i8 %Amt to i32
	%B = shl i32 %A, %shift.upgrd.1
	%Amt2 = sub i8 32, %Amt
	%shift.upgrd.2 = zext i8 %Amt2 to i32
	%C = lshr i32 %A, %shift.upgrd.2
	%D = or i32 %B, %C
	ret i32 %D
}

define i32 @rotr32(i32 %A, i8 %Amt) nounwind {
; 32-LABEL: rotr32:
; 32:       # %bb.0:
; 32-NEXT:    movb {{[0-9]+}}(%esp), %cl
; 32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    rorl %cl, %eax
; 32-NEXT:    retl
;
; 64-LABEL: rotr32:
; 64:       # %bb.0:
; 64-NEXT:    movl %esi, %ecx
; 64-NEXT:    rorl %cl, %edi
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%shift.upgrd.3 = zext i8 %Amt to i32
	%B = lshr i32 %A, %shift.upgrd.3
	%Amt2 = sub i8 32, %Amt
	%shift.upgrd.4 = zext i8 %Amt2 to i32
	%C = shl i32 %A, %shift.upgrd.4
	%D = or i32 %B, %C
	ret i32 %D
}

define i32 @rotli32(i32 %A) nounwind {
; 32-LABEL: rotli32:
; 32:       # %bb.0:
; 32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    roll $5, %eax
; 32-NEXT:    retl
;
; 64-LABEL: rotli32:
; 64:       # %bb.0:
; 64-NEXT:    roll $5, %edi
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%B = shl i32 %A, 5
	%C = lshr i32 %A, 27
	%D = or i32 %B, %C
	ret i32 %D
}

define i32 @rotri32(i32 %A) nounwind {
; 32-LABEL: rotri32:
; 32:       # %bb.0:
; 32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    roll $27, %eax
; 32-NEXT:    retl
;
; 64-LABEL: rotri32:
; 64:       # %bb.0:
; 64-NEXT:    roll $27, %edi
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%B = lshr i32 %A, 5
	%C = shl i32 %A, 27
	%D = or i32 %B, %C
	ret i32 %D
}

define i32 @rotl1_32(i32 %A) nounwind {
; 32-LABEL: rotl1_32:
; 32:       # %bb.0:
; 32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    roll %eax
; 32-NEXT:    retl
;
; 64-LABEL: rotl1_32:
; 64:       # %bb.0:
; 64-NEXT:    roll %edi
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%B = shl i32 %A, 1
	%C = lshr i32 %A, 31
	%D = or i32 %B, %C
	ret i32 %D
}

define i32 @rotr1_32(i32 %A) nounwind {
; 32-LABEL: rotr1_32:
; 32:       # %bb.0:
; 32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    rorl %eax
; 32-NEXT:    retl
;
; 64-LABEL: rotr1_32:
; 64:       # %bb.0:
; 64-NEXT:    rorl %edi
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%B = shl i32 %A, 31
	%C = lshr i32 %A, 1
	%D = or i32 %B, %C
	ret i32 %D
}

define i16 @rotl16(i16 %A, i8 %Amt) nounwind {
; 32-LABEL: rotl16:
; 32:       # %bb.0:
; 32-NEXT:    movb {{[0-9]+}}(%esp), %cl
; 32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    rolw %cl, %ax
; 32-NEXT:    retl
;
; 64-LABEL: rotl16:
; 64:       # %bb.0:
; 64-NEXT:    movl %esi, %ecx
; 64-NEXT:    rolw %cl, %di
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%shift.upgrd.5 = zext i8 %Amt to i16
	%B = shl i16 %A, %shift.upgrd.5
	%Amt2 = sub i8 16, %Amt
	%shift.upgrd.6 = zext i8 %Amt2 to i16
	%C = lshr i16 %A, %shift.upgrd.6
	%D = or i16 %B, %C
	ret i16 %D
}

define i16 @rotr16(i16 %A, i8 %Amt) nounwind {
; 32-LABEL: rotr16:
; 32:       # %bb.0:
; 32-NEXT:    movb {{[0-9]+}}(%esp), %cl
; 32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    rorw %cl, %ax
; 32-NEXT:    retl
;
; 64-LABEL: rotr16:
; 64:       # %bb.0:
; 64-NEXT:    movl %esi, %ecx
; 64-NEXT:    rorw %cl, %di
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%shift.upgrd.7 = zext i8 %Amt to i16
	%B = lshr i16 %A, %shift.upgrd.7
	%Amt2 = sub i8 16, %Amt
	%shift.upgrd.8 = zext i8 %Amt2 to i16
	%C = shl i16 %A, %shift.upgrd.8
	%D = or i16 %B, %C
	ret i16 %D
}

define i16 @rotli16(i16 %A) nounwind {
; 32-LABEL: rotli16:
; 32:       # %bb.0:
; 32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    rolw $5, %ax
; 32-NEXT:    retl
;
; 64-LABEL: rotli16:
; 64:       # %bb.0:
; 64-NEXT:    rolw $5, %di
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%B = shl i16 %A, 5
	%C = lshr i16 %A, 11
	%D = or i16 %B, %C
	ret i16 %D
}

define i16 @rotri16(i16 %A) nounwind {
; 32-LABEL: rotri16:
; 32:       # %bb.0:
; 32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    rolw $11, %ax
; 32-NEXT:    retl
;
; 64-LABEL: rotri16:
; 64:       # %bb.0:
; 64-NEXT:    rolw $11, %di
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%B = lshr i16 %A, 5
	%C = shl i16 %A, 11
	%D = or i16 %B, %C
	ret i16 %D
}

define i16 @rotl1_16(i16 %A) nounwind {
; 32-LABEL: rotl1_16:
; 32:       # %bb.0:
; 32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    rolw %ax
; 32-NEXT:    retl
;
; 64-LABEL: rotl1_16:
; 64:       # %bb.0:
; 64-NEXT:    rolw %di
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%B = shl i16 %A, 1
	%C = lshr i16 %A, 15
	%D = or i16 %B, %C
	ret i16 %D
}

define i16 @rotr1_16(i16 %A) nounwind {
; 32-LABEL: rotr1_16:
; 32:       # %bb.0:
; 32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    rorw %ax
; 32-NEXT:    retl
;
; 64-LABEL: rotr1_16:
; 64:       # %bb.0:
; 64-NEXT:    rorw %di
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%B = lshr i16 %A, 1
	%C = shl i16 %A, 15
	%D = or i16 %B, %C
	ret i16 %D
}

define i8 @rotl8(i8 %A, i8 %Amt) nounwind {
; 32-LABEL: rotl8:
; 32:       # %bb.0:
; 32-NEXT:    movb {{[0-9]+}}(%esp), %cl
; 32-NEXT:    movb {{[0-9]+}}(%esp), %al
; 32-NEXT:    rolb %cl, %al
; 32-NEXT:    retl
;
; 64-LABEL: rotl8:
; 64:       # %bb.0:
; 64-NEXT:    movl %esi, %ecx
; 64-NEXT:    rolb %cl, %dil
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%B = shl i8 %A, %Amt
	%Amt2 = sub i8 8, %Amt
	%C = lshr i8 %A, %Amt2
	%D = or i8 %B, %C
	ret i8 %D
}

define i8 @rotr8(i8 %A, i8 %Amt) nounwind {
; 32-LABEL: rotr8:
; 32:       # %bb.0:
; 32-NEXT:    movb {{[0-9]+}}(%esp), %cl
; 32-NEXT:    movb {{[0-9]+}}(%esp), %al
; 32-NEXT:    rorb %cl, %al
; 32-NEXT:    retl
;
; 64-LABEL: rotr8:
; 64:       # %bb.0:
; 64-NEXT:    movl %esi, %ecx
; 64-NEXT:    rorb %cl, %dil
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%B = lshr i8 %A, %Amt
	%Amt2 = sub i8 8, %Amt
	%C = shl i8 %A, %Amt2
	%D = or i8 %B, %C
	ret i8 %D
}

define i8 @rotli8(i8 %A) nounwind {
; 32-LABEL: rotli8:
; 32:       # %bb.0:
; 32-NEXT:    movb {{[0-9]+}}(%esp), %al
; 32-NEXT:    rolb $5, %al
; 32-NEXT:    retl
;
; 64-LABEL: rotli8:
; 64:       # %bb.0:
; 64-NEXT:    rolb $5, %dil
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%B = shl i8 %A, 5
	%C = lshr i8 %A, 3
	%D = or i8 %B, %C
	ret i8 %D
}

define i8 @rotri8(i8 %A) nounwind {
; 32-LABEL: rotri8:
; 32:       # %bb.0:
; 32-NEXT:    movb {{[0-9]+}}(%esp), %al
; 32-NEXT:    rolb $3, %al
; 32-NEXT:    retl
;
; 64-LABEL: rotri8:
; 64:       # %bb.0:
; 64-NEXT:    rolb $3, %dil
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%B = lshr i8 %A, 5
	%C = shl i8 %A, 3
	%D = or i8 %B, %C
	ret i8 %D
}

define i8 @rotl1_8(i8 %A) nounwind {
; 32-LABEL: rotl1_8:
; 32:       # %bb.0:
; 32-NEXT:    movb {{[0-9]+}}(%esp), %al
; 32-NEXT:    rolb %al
; 32-NEXT:    retl
;
; 64-LABEL: rotl1_8:
; 64:       # %bb.0:
; 64-NEXT:    rolb %dil
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%B = shl i8 %A, 1
	%C = lshr i8 %A, 7
	%D = or i8 %B, %C
	ret i8 %D
}

define i8 @rotr1_8(i8 %A) nounwind {
; 32-LABEL: rotr1_8:
; 32:       # %bb.0:
; 32-NEXT:    movb {{[0-9]+}}(%esp), %al
; 32-NEXT:    rorb %al
; 32-NEXT:    retl
;
; 64-LABEL: rotr1_8:
; 64:       # %bb.0:
; 64-NEXT:    rorb %dil
; 64-NEXT:    movl %edi, %eax
; 64-NEXT:    retq
	%B = lshr i8 %A, 1
	%C = shl i8 %A, 7
	%D = or i8 %B, %C
	ret i8 %D
}

define void @rotr1_64_mem(i64* %Aptr) nounwind {
; 32-LABEL: rotr1_64_mem:
; 32:       # %bb.0:
; 32-NEXT:    pushl %esi
; 32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    movl (%eax), %ecx
; 32-NEXT:    movl 4(%eax), %edx
; 32-NEXT:    movl %edx, %esi
; 32-NEXT:    shldl $31, %ecx, %esi
; 32-NEXT:    shldl $31, %edx, %ecx
; 32-NEXT:    movl %ecx, 4(%eax)
; 32-NEXT:    movl %esi, (%eax)
; 32-NEXT:    popl %esi
; 32-NEXT:    retl
;
; 64-LABEL: rotr1_64_mem:
; 64:       # %bb.0:
; 64-NEXT:    rorq (%rdi)
; 64-NEXT:    retq

  %A = load i64, i64 *%Aptr
  %B = shl i64 %A, 63
  %C = lshr i64 %A, 1
  %D = or i64 %B, %C
  store i64 %D, i64* %Aptr
  ret void
}

define void @rotr1_32_mem(i32* %Aptr) nounwind {
; 32-LABEL: rotr1_32_mem:
; 32:       # %bb.0:
; 32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    rorl (%eax)
; 32-NEXT:    retl
;
; 64-LABEL: rotr1_32_mem:
; 64:       # %bb.0:
; 64-NEXT:    rorl (%rdi)
; 64-NEXT:    retq
  %A = load i32, i32 *%Aptr
  %B = shl i32 %A, 31
  %C = lshr i32 %A, 1
  %D = or i32 %B, %C
  store i32 %D, i32* %Aptr
  ret void
}

define void @rotr1_16_mem(i16* %Aptr) nounwind {
; 32-LABEL: rotr1_16_mem:
; 32:       # %bb.0:
; 32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    rorw (%eax)
; 32-NEXT:    retl
;
; 64-LABEL: rotr1_16_mem:
; 64:       # %bb.0:
; 64-NEXT:    rorw (%rdi)
; 64-NEXT:    retq
  %A = load i16, i16 *%Aptr
  %B = shl i16 %A, 15
  %C = lshr i16 %A, 1
  %D = or i16 %B, %C
  store i16 %D, i16* %Aptr
  ret void
}

define void @rotr1_8_mem(i8* %Aptr) nounwind {
; 32-LABEL: rotr1_8_mem:
; 32:       # %bb.0:
; 32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; 32-NEXT:    rorb (%eax)
; 32-NEXT:    retl
;
; 64-LABEL: rotr1_8_mem:
; 64:       # %bb.0:
; 64-NEXT:    rorb (%rdi)
; 64-NEXT:    retq
  %A = load i8, i8 *%Aptr
  %B = shl i8 %A, 7
  %C = lshr i8 %A, 1
  %D = or i8 %B, %C
  store i8 %D, i8* %Aptr
  ret void
}
