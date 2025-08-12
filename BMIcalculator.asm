; BMI Calculator - x86-64 macOS NASM
; Calculates BMI = (10000 * weight) / (height^2)
; Inputs weight (kg), height (cm) as integers

section .data
    ; CORRECTED: Removed the trailing ', 0' from strings whose length is
    ; calculated with 'equ'. The 'write' syscall uses the explicit length in RDX,
    ; and printing a null byte can cause terminal errors.
    prompt_weight db "Enter weight in kg: "
    prompt_weight_len equ $ - prompt_weight

    prompt_height db "Enter height in cm: "
    prompt_height_len equ $ - prompt_height

    result_msg db "Your BMI is: "
    result_msg_len equ $ - result_msg

    newline db 10

section .bss
    weight_buf resb 32
    height_buf resb 32
    result_buf resb 32

section .text
    global _start

_start:
    ; Print prompt for weight
    mov rsi, prompt_weight
    mov rdx, prompt_weight_len
    call print

    ; Read weight input
    mov rdi, weight_buf
    call read_input

    ; Convert weight string to int (RAX)
    mov rsi, weight_buf
    call str_to_int
    mov r8, rax             ; save weight in r8

    ; Print prompt for height
    mov rsi, prompt_height
    mov rdx, prompt_height_len
    call print

    ; Read height input
    mov rdi, height_buf
    call read_input

    ; Convert height string to int (RAX)
    mov rsi, height_buf
    call str_to_int
    mov r9, rax             ; save height in r9

    ; Calculate BMI = (10000 * weight) / (height * height)
    mov rax, r8             ; weight
    imul rax, 10000         ; 10000 * weight

    mov rcx, r9             ; height
    imul rcx, rcx           ; height * height

    xor rdx, rdx            ; clear rdx before div
    div rcx                 ; rax = BMI

    ; Convert BMI integer (rax) to string in result_buf
    mov rdi, result_buf
    call int_to_str

    ; Print "Your BMI is: "
    mov rsi, result_msg
    mov rdx, result_msg_len
    call print

    ; Print BMI string
    mov rsi, result_buf
    call print_cstr

    ; Print newline
    mov rsi, newline
    mov rdx, 1
    call print

    ; Exit
    call exit

; --------------- Helpers ----------------

; Print string (RSI = ptr, RDX = length)
print:
    mov rax, 0x2000004       ; write syscall
    mov rdi, 1               ; stdout
    syscall
    ret

; Print null-terminated string (RSI)
print_cstr:
    push rsi
    xor rcx, rcx
.find_len:
    cmp byte [rsi + rcx], 0
    je .done
    inc rcx
    jmp .find_len
.done:
    mov rdx, rcx
    pop rsi
    call print
    ret

; Read input to buffer (RDI)
read_input:
    mov rsi, rdi
    mov rdx, 32
    mov rax, 0x2000003       ; read syscall
    mov rdi, 0               ; stdin
    syscall
    ; Replace newline with null terminator
    mov byte [rsi + rax - 1], 0
    ret

; Convert null-terminated string at RSI to int (RAX)
str_to_int:
    xor rax, rax
.loop:
    movzx rcx, byte [rsi]
    cmp rcx, 0
    je .done
    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx
    inc rsi
    jmp .loop
.done:
    ret

; Convert integer in RAX to null-terminated string at RDI
int_to_str:
    mov rbx, rdi
    add rdi, 31              ; buffer end
    mov byte [rdi], 0        ; null terminator
    dec rdi

    mov rcx, 10
.convert_loop:
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    test rax, rax
    jnz .convert_loop
    ; This handles the case where RAX is 0 correctly
    cmp rax, 0
    jne .not_zero_special
    cmp qword [rbx], 0 ; Check if original value was 0
    jne .not_zero_special
    mov byte [rdi], '0'
    dec rdi
.not_zero_special:

    inc rdi
    ; copy result to start of buffer
    mov rsi, rdi
    mov rdi, rbx
.copy_loop:
    mov al, [rsi]
    mov [rdi], al
    inc rsi
    inc rdi
    cmp al, 0
    jne .copy_loop
    ret

; Exit program cleanly
exit:
    mov rax, 0x2000001       ; exit syscall
    xor rdi, rdi             ; status 0
    syscall
