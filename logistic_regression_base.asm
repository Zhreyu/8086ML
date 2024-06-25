.model small
.stack 100h
.data
    ; Sample 4x4 image (16 bytes)
    image db 100, 150, 200, 180
          db 120, 130, 190, 210
          db 110, 140, 160, 170
          db 90, 100, 130, 150

    ; Logistic regression weights (16 weights + 1 bias)
    weights dw 10, 20, 15, 5
            dw -5, 25, 30, 10
            dw 15, -10, 5, 20
            dw -15, 10, 5, 30
    bias dw -2000  ; Bias term

    result dw ?    ; Logistic regression output
    threshold dw 0 ; Classification threshold (0 for 0.5 in fixed-point)

    msg_class0 db 'Image classified as class 0$'
    msg_class1 db 'Image classified as class 1$'

.code
main proc
    mov ax, @data
    mov ds, ax

    ; Calculate weighted sum
    xor dx, dx  ; DX:AX will store the sum
    mov cx, 16  ; Counter for 16 pixels
    mov si, offset image
    mov di, offset weights

sum_loop:
    xor ax, ax
    mov al, [si]  ; Load pixel value
    imul word ptr [di]  ; Multiply by weight
    add dx, ax    ; Add to sum (ignore overflow for simplicity)
    inc si        ; Move to next pixel
    add di, 2     ; Move to next weight
    loop sum_loop

    ; Add bias
    add dx, [bias]

    ; Apply sigmoid function approximation
    ; We'll use a simple step function for this example
    ; If dx >= 0, result is 1, else 0
    mov [result], 0
    cmp dx, 0
    jl print_result
    mov [result], 1

print_result:
    mov ax, [result]
    cmp ax, [threshold]
    jbe class0

class1:
    mov dx, offset msg_class1
    jmp display

class0:
    mov dx, offset msg_class0

display:
    mov ah, 9
    int 21h

    ; Exit program
    mov ah, 4Ch
    int 21h
main endp

end main