header_VmCall
vm_call PROC
	push ebp
	mov ebp, esp
	sub esp, 0Ch

	; pop the offset to call
	push [ebp+arg0]
	call_vm_stack_pop_enc
	mov [ebp+local0], eax

	; pop the number of argument to push in the new stack
	push [ebp+arg0]
	call_vm_stack_pop_enc
	mov [ebp+local2], eax

	; allocate space for the stack
	push VM_STACK_SIZE
	call_heap_alloc
	mov [ebp+local1], eax

	; init stack frame
	mov ebx, [ebp+arg0]	
	push (VmContext PTR [ebx]).stack_frame ; previous stack frame
	push eax ; new allocated stack frame
	call_vm_init_stack_frame
		
	; extract the arguments from the stack frame and 
	; temporary save them into the native stack
	mov ecx, [ebp+local2]
	test ecx, ecx
	jz save_previous_ip

get_arguments:	
	push ecx ; save counter
	push [ebp+arg0]
	call_vm_stack_pop_enc
	pop ecx ; restore counter
	push eax ; push argument in the native stack
	loop get_arguments

save_previous_ip:
	; save on top of the current stack frame the ip
	mov eax, [ebp+arg0]	
	push (VmContext PTR [eax]).ip
	push [ebp+arg0]
	call_vm_stack_push_enc

	; set the new stack frame as the current one
	mov eax, [ebp+local1]
	mov ebx, [ebp+arg0]	
	mov (VmContext PTR [ebx]).stack_frame, eax

	; push the arguments saved in the native 
	; stack in the new managed stack
	mov ecx, [ebp+local2]
	test ecx, ecx
	jz set_vm_ip_to_new_offset
set_arguments:
	mov [ebp+local2], ecx ; save counter
	push [ebp+arg0]
	call_vm_stack_push_enc
	mov ecx, [ebp+local2] ; restore counter
	loop set_arguments
		
set_vm_ip_to_new_offset:
	; move the sp to the specific offset
	mov ebx, [ebp+local0]
	mov eax, [ebp+arg0]
	mov (VmContext PTR [eax]).ip, ebx
	
	mov esp, ebp
	pop ebp
	ret
vm_call ENDP
header_marker