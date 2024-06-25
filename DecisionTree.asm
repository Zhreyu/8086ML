.model small
.stack 100h
.data
    temp_prompt db 'Enter temperature (0-100): $'
    humid_prompt db 'Enter humidity (0-100): $'
    rain_msg db 'Prediction: It will rain$'
    no_rain_msg db 'Prediction: It will not rain$'
    continue_msg db 'Make another prediction? (y/n): $'
    
    temp dw ?
    humid dw ?

.code
main proc
    mov ax, @data
    mov ds, ax

predict_loop:
    ; Get temperature
    mov dx, offset temp_prompt
    mov ah, 9
    int 21h
    call read_number
    mov [temp], ax

    ; Get humidity
    mov dx, offset humid_prompt
    mov ah, 9
    int 21h
    call read_number
    mov [humid], ax

    ; Make prediction
    call decision_tree

    ; Ask to continue
    mov dx, offset continue_msg
    mov ah, 9
    int 21h
    mov ah, 1
    int 21h
    cmp al, 'y'
    je predict_loop

    ; Exit program
    mov ah, 4Ch
    int 21h
main endp

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

decision_tree proc
    ; Check if temperature > 70
    mov ax, [temp]
    cmp ax, 70
    jg high_temp

    ; Temperature <= 70
    mov ax, [humid]
    cmp ax, 80
    jg predict_rain
    jmp predict_no_rain

high_temp:
    ; Temperature > 70
    mov ax, [humid]
    cmp ax, 60
    jg predict_rain
    jmp predict_no_rain

predict_rain:
    mov dx, offset rain_msg
    jmp display_prediction

predict_no_rain:
    mov dx, offset no_rain_msg

display_prediction:
    mov ah, 9
    int 21h
    
    ; New line
    mov ah, 2
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h

    ret
decision_tree endp

end main