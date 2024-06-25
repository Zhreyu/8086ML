.model small
.stack 100h
.data
    ; Training data: X coordinate, Y coordinate, Class (0 or 1)
    train_data dw 1, 2, 0
               dw 2, 3, 0
               dw 3, 1, 0
               dw 6, 5, 1
               dw 7, 8, 1
               dw 8, 7, 1
    train_count dw 6

    test_x dw ?
    test_y dw ?
    k_value dw 3  ; Number of neighbors to consider

    distances dw 6 dup(?)  ; To store calculated distances
    prompt_x db 'Enter X coordinate: $'
    prompt_y db 'Enter Y coordinate: $'
    result_msg db 'Predicted class: $'

    buffer db 5 dup('$')

.code
main proc
    mov ax, @data
    mov ds, ax

main_loop:
    ; Get test point coordinates
    call get_test_point

    ; Calculate distances
    call calculate_distances

    ; Find k nearest neighbors and classify
    call knn_classify

    ; Display result
    call display_result

    ; Ask if user wants to classify another point
    mov ah, 9
    mov dx, offset continue_msg
    int 21h

    mov ah, 1
    int 21h
    cmp al, 'y'
    je main_loop

    ; Exit program
    mov ah, 4Ch
    int 21h
main endp

get_test_point proc
    ; Prompt for X
    mov ah, 9
    mov dx, offset prompt_x
    int 21h

    call read_number
    mov [test_x], ax

    ; Prompt for Y
    mov ah, 9
    mov dx, offset prompt_y
    int 21h

    call read_number
    mov [test_y], ax

    ret
get_test_point endp

read_number proc
    xor ax, ax
    xor cx, cx
read_loop:
    mov ah, 1
    int 21h
    cmp al, 13  ; Check for Enter key
    je end_read
    sub al, '0'
    xor ah, ah
    push ax
    mov ax, 10
    mul cx
    mov cx, ax
    pop ax
    add cx, ax
    jmp read_loop
end_read:
    mov ax, cx
    ret
read_number endp

calculate_distances proc
    mov cx, [train_count]
    xor si, si
    xor di, di
dist_loop:
    ; Calculate (x2-x1)^2
    mov ax, [train_data + si]
    sub ax, [test_x]
    imul ax
    mov bx, ax

    ; Calculate (y2-y1)^2
    mov ax, [train_data + si + 2]
    sub ax, [test_y]
    imul ax

    ; Sum of squares (approximate distance)
    add ax, bx
    mov [distances + di], ax

    add si, 6  ; Move to next training point
    add di, 2  ; Move to next distance slot
    loop dist_loop
    ret
calculate_distances endp

knn_classify proc
    mov cx, [k_value]
    xor bx, bx  ; Class 0 count
    xor dx, dx  ; Class 1 count
knn_loop:
    ; Find minimum distance
    mov si, 0
    mov di, 2
    mov ax, [distances]
    mov [distances], 0FFFFh  ; Mark as visited
    push cx
    mov cx, [train_count]
    dec cx
min_loop:
    cmp [distances + di], ax
    jae next_dist
    mov ax, [distances + di]
    mov si, di
next_dist:
    add di, 2
    loop min_loop
    pop cx

    ; Count class of nearest neighbor
    mov di, si
    shr di, 1  ; Convert to index in train_data
    imul di, 6
    add di, 4  ; Point to class of this data point
    mov ax, [train_data + di]
    test ax, ax
    jz inc_class0
    inc dx  ; Class 1
    jmp next_k
inc_class0:
    inc bx  ; Class 0
next_k:
    mov [distances + si], 0FFFFh  ; Mark as visited
    loop knn_loop

    ; Determine final class
    cmp bx, dx
    ja class0
    mov ax, 1  ; Class 1
    jmp end_classify
class0:
    xor ax, ax  ; Class 0
end_classify:
    mov [buffer], al  ; Store result
    ret
knn_classify endp

display_result proc
    ; Display result message
    mov ah, 9
    mov dx, offset result_msg
    int 21h

    ; Display class
    mov al, [buffer]
    add al, '0'
    mov ah, 0Eh
    int 10h

    ; New line
    mov ah, 2
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h

    ret
display_result endp

continue_msg db 'Classify another point? (y/n): $'

end main