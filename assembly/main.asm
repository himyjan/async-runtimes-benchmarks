section .data
    msg db "All tasks completed", 10
    msglen equ $ - msg

section .bss
    num_tasks resq 1
    remaining resq 1
    sem resq 1

section .text
    global main
    extern pthread_create
    extern sem_init
    extern sem_wait
    extern sem_post
    extern sleep
    extern printf

%macro SAVE_REGS 0
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
%endmacro

%macro RESTORE_REGS 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
%endmacro

worker:
    SAVE_REGS
    mov rdi, 10
    call sleep
    lock dec qword [remaining]
    cmp qword [remaining], 0
    je .done
    RESTORE_REGS
    ret
.done:
    mov rdi, [sem]
    call sem_post
    RESTORE_REGS
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov rdi, 100000
    mov [num_tasks], rdi
    mov [remaining], rdi

    mov rdi, sem
    mov rsi, 0
    mov rdx, 0
    call sem_init

    mov rcx, [num_tasks]
.create_loop:
    test rcx, rcx
    jz .create_done
    push rcx
    lea rdi, [rsp-8]
    mov qword [rsp-8], 0
    mov rsi, 0
    mov rdx, worker
    mov rcx, 0
    call pthread_create
    mov rsp, rbp
    pop rcx
    dec rcx
    jmp .create_loop
.create_done:

    mov rdi, [sem]
    mov rsi, -1
    call sem_wait

    mov rax, 1
    mov rdi, 1
    lea rsi, [msg]
    mov rdx, msglen
    syscall

    mov eax, 0
    leave
    ret
