.model small
.stack 100h
.data
    ; Data points (area, price)
    areas dw 260, 300, 320, 360, 400
    prices dw 5500, 5650, 6100, 6800, 7250  ; Prices divided by 100 for simplicity
    n dw 5  ; Number of data points
    sum_x dw ?
    sum_y dw ?
    sum_xy dw ?
    sum_x_squared dw ?
    slope dw ?
    intercept dw ?
    prompt db 'Enter area (200-400): $'
    result_msg db 'Predicted price: $'
    input dw ?
    
    result dw ?   ; Predicted value
    buffer db 10 dup('$')  ; Buffer for number to string conversion
.code
main proc
    mov ax, @data
    mov ds, ax
    call calculate_regression
    call predict_price
    ; Exit program
    mov ah, 4Ch
    int 21h
main endp

calculate_regression proc
    ; Calculate sums
    mov cx, [n]
    mov si, 0
    xor ax, ax  ; sum_x
    xor bx, bx  ; sum_y
    mov word ptr [sum_xy], 0
    mov word ptr [sum_x_squared], 0

sum_loop:
    ; sum_x
    mov dx, [areas + si]
    add ax, dx
    
    ; sum_y
    add bx, [prices + si]
    
    ; sum_xy
    push ax
    mov ax, dx
    mul word ptr [prices + si]
    add word ptr [sum_xy], ax
    pop ax
    
    ; sum_x_squared
    push ax
    mov ax, dx
    mul dx
    add word ptr [sum_x_squared], ax
    pop ax
    
    add si, 2
    loop sum_loop

    mov [sum_x], ax
    mov [sum_y], bx

    ; Calculate slope
    mov ax, [n]
    mul word ptr [sum_xy]
    mov cx, ax
    mov dx, dx  ; Save high word of n * sum_xy
    
    mov ax, [sum_x]
    mul word ptr [sum_y]
    sub cx, ax
    sbb dx, dx  ; Borrow from high word if necessary
    ; CX:DX now holds the numerator

    push cx
    push dx

    mov ax, [n]
    mul word ptr [sum_x_squared]
    mov cx, ax
    mov bx, dx  ; Save high word of n * sum_x_squared
    
    mov ax, [sum_x]
    mul ax
    sub cx, ax
    sbb bx, dx  ; Borrow from high word if necessary
    ; CX:BX now holds the denominator

    pop ax  ; High word of numerator
    pop dx  ; Low word of numerator

    idiv cx  ; Assume denominator fits in CX for simplicity
    mov [slope], ax  ; Slope * 100

    ; Calculate intercept
    mov ax, [sum_y]
    cwd
    idiv word ptr [n]
    mov bx, ax  ; Average y

    mov ax, [sum_x]
    cwd
    idiv word ptr [n]  ; Average x
    imul word ptr [slope]
    mov cx, ax

    mov ax, bx
    sub ax, cx
    mov [intercept], ax  ; Intercept * 100

    ret
calculate_regression endp

predict_price proc
    ; Display prompt
    mov ah, 9
    mov dx, offset prompt
    int 21h

    ; Read user input
    mov cx, 0
    mov [input], 0
read_loop:
    mov ah, 1
    int 21h
    cmp al, 13  ; Check for Enter key
    je end_read
    sub al, '0'
    mov ah, 0
    mov bx, [input]
    imul bx, 10
    add bx, ax
    mov [input], bx
    inc cx
    cmp cx, 3
    jl read_loop
end_read:

    ; Perform linear regression: y = mx + b
    mov ax, [input]
    imul word ptr [slope]
    add ax, [intercept]
    mov [result], ax

    ; Display result message
    mov ah, 9
    mov dx, offset result_msg
    int 21h

    ; Convert result to string
    mov ax, [result]
    mov bx, 100
    xor cx, cx
    mov si, offset buffer

convert_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz convert_loop

print_loop:
    pop dx
    add dl, '0'
    mov [si], dl
    inc si
    loop print_loop

    ; Add decimal point and trailing zeros if needed
    mov byte ptr [si-2], '.'
    cmp byte ptr [si-1], '$'
    jne print_result
    mov byte ptr [si-1], '0'
    mov byte ptr [si], '0'

print_result:
    ; Display result
    mov ah, 9
    mov dx, offset buffer
    int 21h

    ret
predict_price endp

end main