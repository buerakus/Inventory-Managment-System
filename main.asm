; 64KB space for program
.model small
; 256 bytes stack
.stack 100h

; Data segment
.data

; Constants
MAX_ITEMS equ 40    ; Maximum number of items

; Data Definitions
ItemAmount dw 2                     ; Initial item amount
ItemNameLength equ 20               ; Length of item name
ItemID equ 2                        ; Item ID
ItemValue equ 2                     ; Item value
ItemData dw 2, 1, 0, 2, 1, 0, 40, 10, 19, 13, '$' ; Item data values
ItemPriceList dw 5, 8, 4, 2, 4, 9, 8, 1, 8, 10, '$' ; Item price list
TotalSales dw 0                     ; Total sales amount

BlankSpace db '                           ','$' ; Blank space string

; Menu and Prompts
MainMenu db 10,10,10, "------------------------", 10 ; Main menu start
         db "--- Inventory System ---", 10           ; Main menu title
         db "------------------------", 10,10        ; Main menu separator
         db "1. Display Items", 10                   ; Menu option 1
         db "2. Add Item", 10                        ; Menu option 2
         db "3. Sell Item", 10                       ; Menu option 3
         db "0. Exit Program", 10,10                 ; Menu option 0
         db "------------------------", '$'          ; Main menu end

InputError db 10, 'Invalid option selected.', 10, '$' ; Input error message

ItemHeader db 10, '==============| INVENTORY |==============', 10 ; Item header start
           db '==============================================', 10 ; Item header separator
           db 'ID', 9, 'Name', 9, 9, 'Price', 9, 'Quantity', 10,10, '$' ; Item header columns

RestockMessage db '==============================================', 10,10 ; Restock message start
              db ' Items are low in stock, please restock.', 10,10        ; Restock message body
              db '==============================================', 10,10   ; Restock message separator
              db '1. Main Menu', 10,10                                    ; Restock menu option 1
              db '0. Exit Program', 10,10                                 ; Restock menu option 0
              db 'Please select an option: $'                             ; Restock menu prompt

ItemToRestock dw ?                    ; Variable for item to restock
ItemRestockID dw ?                    ; Variable for restock item ID

RestockHeader db '==============================================', 10,10 ; Restock header start
             db 9, 9, 32, 32, 'ADD ITEMS', 10,10                         ; Restock header title
             db '==============================================', 10,10   ; Restock header separator
             db 'Enter item ID: $'                                       ; Restock prompt

RestockPrompt db 10,10, 'Enter quantity to restock from 1 to 9: $' ; Restock quantity prompt
RestockSuccess db 10,10, ' Item restocked successfully.', 10, '$' ; Restock success message

SellHeader db '==============================================', 10,10 ; Sell header start
           db 9, 9, 32, 32, 'SELL ITEM', 10,10                         ; Sell header title
           db '==============================================', 10,10   ; Sell header separator
           db 'Enter item ID: $'                                        ; Sell prompt

SellPrompt db 10,10, 'Enter quantity to sell from 1 to 9: $' ; Sell quantity prompt
SellSuccess db 10,10, ' Item sold successfully.', 10, '$'    ; Sell success message
SellFailure db 10,10, ' Insufficient quantity to sell.', 10, '$' ; Sell failure message

UserInputPrompt db 10,10, 'Please select an option: $' ; User input prompt
GoodbyeMessage db 10,10, '=======| Thank you for using the inventory system |=======','$' ; Goodbye message


.code
main PROC
;Getting the data segment address and loading into data segment register
  mov ax, @data       
  mov ds, ax          
  
  call DisplayMainMenu ; Call procedure to display the main menu
  
  mov ah, 01h         
  int 21h             ; Read user input and interrupt of reading

  ;Basically a switch statement implemented in Assembly
  cmp al, '1'         
  je ShowItems        ; jump to ShowItems
  
  cmp al, '2'         
  je AddItemsMenu     ; jump to AddItemsMenu
  
  cmp al, '3'         
  je SellItemsMenu    ; jump to SellItemsMenu
  
  cmp al, '0'         
  je ExitProgram      ; jump to ExitProgram

  jmp main            ; Similar to break(), jumps back to main function

;ShowItems Procedure Segment
ShowItems:              
    call ClearScreen
    call DisplayItems
    call NavigateAfterDisplay
    ret

AddItemsMenu:
    call ClearScreen
    call DisplayItems
    call SupplyItems
    ret

SellItemsMenu:
    call ClearScreen
    call DisplayItems
    call SellItems
    ret

ExitProgram:
    call ClearScreen
    call Goodbye
    ret

NavigateAfterDisplay:
    lea dx, SupplyMessage
    mov ah, 09h
    int 21h

    mov ah, 01h 
    int 21h

    cmp al, '0'
    je ExitProgram

    cmp al, '1'
    je main

    jmp main

    ret

PrintInteger:
    push bx
    mov bx, 10
    xor cx, cx

InnerLoop:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    cmp ax, 0
    jne InnerLoop

PrintLoop:
    pop dx
    mov ah, 02
    int 21h
    dec cx
    cmp cx, 0
    jne PrintLoop
    pop bx
    ret

CheckValue5:
    mov bx, ax
    cmp bx, 5
    jle MarkValue
    ret

PrintString:
    push ax 
    push bx
    push cx
    mov bx, dx 
    mov cx, 10 

StringLoop:
    mov dl, [bx] 
    int 21h 
    inc bx 
    loop StringLoop 

Done:
    pop cx 
    pop bx
    pop ax
    ret

MarkValue:
    push ax 
    push bx
    push cx
    mov bx, dx 
    mov cx, 10 

MarkLoop:
    mov dl, [bx] 
    mov ah, 09h
    mov al, dl 
    mov bl, 0Eh 
    int 10h
    inc bx 
    loop MarkLoop 

MarkDone:
    pop cx 
    pop bx
    pop ax
    ret

DisplayMainMenu:
    call ClearScreen
    lea dx, MainMenu
    mov ah, 09h
    int 21h
    
    lea dx, UserInputPrompt
    mov ah, 09h
    int 21h
    ret

DisplayItems:
    mov dx, offset ItemHeader
    mov ah, 09
    int 21h
    
    mov bp, 0
    lea si, ItemList

ItemLoop:
    mov ax, [si]
    cmp ax, 10
    ja ItemsDone
    call PrintInteger
    call PrintTab

    mov dx, offset ItemList + 20
    add dx, bp
    call PrintString
    call PrintTab

    mov ax, [si + 140]
    call PrintInteger
    call PrintTab

    mov ax, [si + 120]
    call CheckValue5

    mov ax, [si + 120]
    call PrintInteger
    call PrintNewLine
    add bp, 10
    add si, 2
    jmp ItemLoop
ItemsDone:
    ret

SupplyItems:
    lea dx, SupplyHeader
    mov ah, 09h
    int 21h 
    mov ah, 01
    int 21h
    sub al, 30h 
    add al, al
    sub ax, 136

    mov ItemToSupply, ax 
    lea dx, SupplyPrompt
    mov ah, 09h 
    int 21h

    mov ah, 01
    int 21h
    sub al, 30h
    sub ax, 256
    mov cx, ax
    lea si, ItemList
    add si, ItemToSupply
    add cx, [si]
    mov word ptr [si], cx 
    
    call ClearScreen
    call PrintNewLine
    call PrintBlank
    lea dx, SupplySuccess
    mov ah, 09h 
    int 21h 
    call PrintBlank
    call DisplayItems
    call NavigateAfterDisplay
    ret

SellItems:
    lea dx, SellHeader
    mov ah, 09h
    int 21h 

    mov ah, 01
    int 21h

    sub al, 30h
    add al, al 
    sub ax, 136 
    mov ItemToSupply, ax 

    lea dx, SellPrompt
    mov ah, 09h 
    int 21h

    mov ah, 01
    int 21h
    sub al, 30h
    sub ax, 256
    mov cx, ax

    lea si, ItemList
    add si, ItemToSupply
    mov bx, [si] 
    sub bx, cx
    cmp bx, 0
    js InsufficientQuantity

    mov word ptr [si], bx
    jmp ItemSold

InsufficientQuantity: 
    mov bx, [si]
    mov word ptr [si], bx
    call ClearScreen
    call PrintNewLine
    call PrintBlank
    lea dx, SellFailure
    mov ah, 09h 
    int 21h 
    call PrintBlank
    call PrintNewLine
    call DisplayItems
    call NavigateAfterDisplay
    ret 

ItemSold:
    call UpdateTotalSales
    call ClearScreen
    call PrintNewLine
    call PrintBlank
    lea dx, SellSuccess
    mov ah, 09h
    int 21h

    call PrintBlank
    call PrintNewLine
    call DisplayItems
    call NavigateAfterDisplay
    ret
    
UpdateTotalSales: 
    mov ax, ItemAmount 
    sub ax, 120 
    mov ItemAmount, ax
    lea si, ItemList 
    add si, ItemAmount
    mov ax, [si]
    add cx, ax 
    mov word ptr [si], cx
    ret

Goodbye:
  lea dx, GoodbyeMessage
  mov ah, 09h
  int 21h  
  mov ah, 4ch
  int 21h

ClearScreen:
    mov ah, 06h
    mov al, 0
    mov bh, 07h
    mov cx, 0
    mov dx, 184Fh
    int 10h
    ret

PrintTab:
    mov dl, 9
    mov ah, 02
    int 21h
    ret

PrintNewLine:
    mov dl, 0ah
    mov ah, 02
    int 21h
    ret

PrintBlank:
    lea dx, BlankSpace
    mov ah, 09h 
    int 21h 
    ret

main endp
end main
