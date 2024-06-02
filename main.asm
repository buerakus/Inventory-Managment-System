.model small
.stack 100h
.data

MAX_ITEMS equ 40

ItemList dw 00, 01, 02, 03, 04, 05, 06, 07, 08, 09
            db "M.board   ",  "Memory    ", "CPU       ", "GPU       ", "Power Unit", "Comp. case", "Fans      ", "HDD       ", "SSD       ", "Monitor   "
            dw 10, 1, 10, 2, 10, 3, 10, 4, 10, 5, 1500, 800, 2000, 1700, 800, 600, 400, 1200, 1500, 1300, 2, 1, 0, 0, 1, 1, 2, 1, 2, 0, '$'

ItemAmount dw 2
ItemNameLength equ 20
ItemID equ 2
ItemValue equ 2
ItemData dw 2, 1, 0, 2, 1, 0, 40, 10, 19, 13, '$' 
ItemPriceList dw 5, 8, 4, 2, 4, 9, 8, 1, 8, 10, '$'
TotalSales dw 0

BlankSpace db '                           ','$'

MainMenu db 10,10,10, "------------------------", 10, "--- Inventory System ---", 10, "------------------------", 10,10, "1. Display Items", 10, "2. Add Item", 10, "3. Sell Item", 10, "0. Exit Program", 10,10, "------------------------", '$'

InputError db 10, 'Invalid option selected.', 10, '$'

ItemHeader db 10, '==============| INVENTORY |==============', 10, '==============================================', 10, 'ID', 9, 'Name', 9, 9, 'Price', 9, 'Quantity', 10, 10, '$'
RestockMessage db '==============================================', 10, 10, ' Items are low in stock, please restock.', 10, 10, '==============================================', 10, 10, '1. Main Menu', 10, 10, '0. Exit Program', 10, 10, 'Please select an option: $'

ItemToRestock dw ?
ItemRestockID dw ?

RestockHeader db '==============================================', 10, 10, 9, 9, 32, 32, 'ADD ITEMS', 10, 10, '==============================================', 10, 10, 'Enter item ID: $'
RestockPrompt db 10, 10, 10, 10, 'Enter quantity to restock from 1 to 9: $'
RestockSuccess db 10, 10, 10, 10, ' Item restocked successfully.', 10, '$'

SellHeader db '==============================================', 10, 10, 9, 9, 32, 32, 'SELL ITEM', 10, 10, '==============================================', 10, 10, 'Enter item ID: $'
SellPrompt db 10, 10, 10, 10, 'Enter quantity to sell from 1 to 9: $'
SellSuccess db 10, 10, 10, 10, ' Item sold successfully.', 10, '$'
SellFailure db 10, 10, 10, 10, ' Insufficient quantity to sell.', 10, '$'

UserInputPrompt db 10, 10, 10, 10, 'Please select an option: $'
GoodbyeMessage db 10, 10, 10, 10, '=======| Thank you for using the inventory system |=======','$'

.code
main PROC
  mov ax, @data 
  mov ds, ax 
  
  call DisplayMainMenu
  
  mov ah, 01h 
  int 21h

  cmp al, '1'
  je ShowItems
  
  cmp al, '2'
  je AddItemsMenu
  
  cmp al, '3'
  je SellItemsMenu
  
  cmp al, '0'
  je ExitProgram

  jmp main

ShowItems:
    call ClearScreen
    call DisplayItems
    call NavigateAfterDisplay
    ret

AddItemsMenu:
    call ClearScreen
    call DisplayItems
    call RestockItems
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
    lea dx, RestockMessage
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

RestockItems:
    lea dx, RestockHeader
    mov ah, 09h
    int 21h 
    mov ah, 01
    int 21h
    sub al, 30h 
    add al, al
    sub ax, 136

    mov ItemToRestock, ax 
    lea dx, RestockPrompt
    mov ah, 09h 
    int 21h

    mov ah, 01
    int 21h
    sub al, 30h
    sub ax, 256
    mov cx, ax
    lea si, ItemList
    add si, ItemToRestock
    add cx, [si]
    mov word ptr [si], cx 
    
    call ClearScreen
    call PrintNewLine
    call PrintBlank
    lea dx, RestockSuccess
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
    mov ItemToRestock, ax 

    lea dx, SellPrompt
    mov ah, 09h 
    int 21h

    mov ah, 01
    int 21h
    sub al, 30h
    sub ax, 256
    mov cx, ax

    lea si, ItemList
    add si, ItemToRestock
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
