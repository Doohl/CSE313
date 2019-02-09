section .text
    global main
    extern printf
    extern putchar
    extern scanf
    extern exit

section .data
    input_msg: db "Enter a (unsigned) 32-bit integer: ", 0
    input_fmt: db "%d", 0

    output_dec: db "Decimal value (base-10): %d", 10, 0
    output_oct: db "Octal value (base-8): ", 0
    output_hex: db "Hexadecimal value (base-16): ", 0
    output_bin: db "Binary value (base-2): ", 0

    output_newline: db 10, 0

    digit_fmt: db "%d", 0    ; Output format for a single digit
    digit_newline: db "%d", 10, 0

    input_integer: times 4 db 0 ; 32 bit number used in input (4x8 bits = 32 bits)

    bin_buff: times 32 dd 0 ; Buffer for storing 32 'bits' in base-2
    oct_buff: times 11 dd 0 ; Buffer for storing 32 'bits' in octal
    hex_buff: times 8 dd 0  ; Buffer for storing 32 'bits' in hexadecimal

    ; Lookup table to convert integers into hexadecimal string representations
    ;   character = [hex_table + (integer * 1 byte)]
    hex_table: db "0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"

; Get a 32-bit integer from scanf; store in ESI register
input32:
    push    input_msg
    call    printf
    add     esp, 4          ; Remove argument from printf(input_msg)
    
    push    input_integer
    push    input_fmt
    call    scanf
    add     esp, 8          ; Remove arguments from scanf(input_fmt, &input_integer)

    ; move [input_integer] into ESI
    mov     esi, [input_integer]
    ret

; Just print a newline string
newline:
    push    output_newline
    call    printf
    add     esp, 4
    ret

; Convert integer in EAX to hexadecimal string
int_to_hex:
    mov     edx, [hex_table+eax]
    mov     eax, edx
    ret

; Write value in ESI register to printf
decimal_display:
    push    esi
    push    output_dec
    call    printf
    add     esp, 4          ; Remove first argument
    pop     esi             ; preserve esi
    ret

; Write value in ESI register as binary
binary_display:
    push    esi
    push    output_bin
    call    printf
    add     esp, 4
    pop     esi

    mov     ecx, 0  ; ecx = i = 0   
    mov     eax, esi
    push    esi     ; preserve ESI throughout the following calculations
    modulo_loop:
    mov     edx, 0
    mov     ebx, 2
    div     ebx     ; divide EAX by EBX; quotient stored in EAX, remainder (modulo) in EDX
    
    mov     [bin_buff+4*ecx], edx ; store value of edx into the binary buffer, offset 4 bytes every loop
    add     ecx, 1

    ; while(n != 0) -> continue running modulo loop

    cmp     eax, 0
    jne     modulo_loop

    ; if n == 0, iterate backwards through buffer and display
    mov     ecx, 31
    mov     eax, 0

    print_loop:
    mov     eax, [bin_buff+4*ecx]
    
    push    ecx
    push    eax
    push    digit_fmt
    call    printf
    add     esp, 4
    pop     eax
    pop     ecx

    sub     ecx, 1
    
    ; while(i >= 0) -> continue running print loop
    cmp     ecx, 0
    jge     print_loop

    ; if i < 0, we're done

    call    newline
    pop     esi
    ret

; Write value in ESI register as octal
octal_display:
    push    esi
    push    output_oct
    call    printf
    add     esp, 4
    pop     esi

    mov     ecx, 0  ; ecx = i = 0   
    mov     eax, esi
    push    esi     ; preserve ESI throughout the following calculations
    modulo_loop2:
    mov     edx, 0
    mov     ebx, 8
    div     ebx     ; divide EAX by EBX; quotient stored in EAX, remainder (modulo) in EDX
    
    mov     [oct_buff+4*ecx], edx ; store value of edx into the binary buffer, offset 4 bytes every loop
    add     ecx, 1

    ; while(n != 0) -> continue running modulo loop

    cmp     eax, 0
    jne     modulo_loop2

    ; if n == 0, iterate backwards through buffer and display
    mov     ecx, 10
    mov     eax, 0

    print_loop2:
    mov     eax, [oct_buff+4*ecx]
    
    push    ecx
    push    eax
    push    digit_fmt
    call    printf
    add     esp, 4
    pop     eax
    pop     ecx

    sub     ecx, 1
    
    ; while(i >= 0) -> continue running print loop
    cmp     ecx, 0
    jge     print_loop2

    ; if i < 0, we're done

    call    newline
    pop     esi
    ret

; Write value in ESI register as hexadecimal
hex_display:
    push    esi
    push    output_hex
    call    printf
    add     esp, 4
    pop     esi

    mov     ecx, 0  ; ecx = i = 0   
    mov     eax, esi
    push    esi     ; preserve ESI throughout the following calculations
    modulo_loop3:
    mov     edx, 0
    mov     ebx, 16
    div     ebx     ; divide EAX by EBX; quotient stored in EAX, remainder (modulo) in EDX
    
    mov     [hex_buff+4*ecx], edx ; store value of edx into the binary buffer, offset 4 bytes every loop
    add     ecx, 1

    ; while(n != 0) -> continue running modulo loop

    cmp     eax, 0
    jne     modulo_loop3

    ; if n == 0, iterate backwards through buffer and display
    mov     ecx, 7
    mov     eax, 0

    print_loop3:
    mov     eax, [hex_buff+4*ecx]
    
    ; integer in EAX becomes a character
    call    int_to_hex

    push    ecx
    push    eax
    call    putchar
    pop     eax
    pop     ecx

    sub     ecx, 1
    
    ; while(i >= 0) -> continue running print loop
    cmp     ecx, 0
    jge     print_loop3

    ; if i < 0, we're done

    call    newline
    pop     esi
    ret

main:
    call    input32         ; get a 32 bit integer

    call    decimal_display ; display integer in decimal

    call    binary_display  ; display integer in binary

    call    octal_display   ; display integer in octal

    call    hex_display     ; display integer in hexadecimal

    push    0
    call    exit
