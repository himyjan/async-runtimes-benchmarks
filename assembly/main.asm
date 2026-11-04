section .data
    msg db "All tasks completed", 10
    msglen equ $ - msg

section .bss
    num_tasks resq 1
    remaining resq 1
    next_task resq 1
    sem resq 1
    mutex resq 1

section .text
    global main
    extern pthread_create
    extern pthread_mutex_init
    extern pthread_mutex_lock
    extern pthread_mutex_unlock
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
    mov rdi, [mutex]
    call pthread_mutex_lock
    mov rax, [next_task]
    cmp rax, [num_tasks]
    jge .done_claim
    inc qword [next_task]
    mov rdi, [mutex]
    call pthread_mutex_unlock
    mov rdi, 10
    call sleep
    jmp worker
.done_claim:
    mov rdi, [mutex]
    call pthread_mutex_unlock
    lock dec qword [remaining]
    cmp qword [remaining], 0
    je .last_task
    RESTORE_REGS
    ret
.last_task:
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
    mov qword [next_task], 0

    lea rdi, [mutex]
    call pthread_mutex_init

    mov rdi, sem
    mov rsi, 0
    mov rdx, 0
    call sem_init

    ; Create 1000 worker threads
    mov rcx, 1000
.create_loop:
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
    jnz .create_loop

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
