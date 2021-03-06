header_VmJumpIfGreater
vm_jump_if_greater PROC
	push ebp
	mov ebp, esp	
	
	; pop the value
	push [ebp+arg0]
	call_vm_stack_pop_enc

	; read the carry flag
	mov ebx, [ebp+arg0]
	mov ebx, (VmContext PTR [ebx]).flags
	test ebx, VM_CARRY_FLAG
	jnz finish

	; modify the vm IP
	mov ebx, [ebp+arg0]
	mov (VmContext PTR [ebx]).ip, eax

finish:	
	mov esp, ebp
	pop ebp
	ret
vm_jump_if_greater ENDP
header_marker