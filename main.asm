; 64KB space for program
.model small
; 256 bytes stack
.stack 100h

; Data segment
.data

; Constants
MAX_ITEMS equ 40    ; Maximum number of items

; Item attributes definitions
ItemAmount dw 2                     
ItemNameLength equ 20               
ItemID equ 2                        
ItemValue equ 2                     
ItemData dw 2, 1, 0, 2, 1, 0, 40, 10, 19, 13, '$' 
ItemPriceList dw 5, 8, 4, 2, 4, 9, 8, 1, 8, 10, '$' ;
TotalSales dw 0                     

LowStockHeader db 10, '==============| LOW STOCK ITEMS |==============', 10 
               db '==============================================', 10 
               db 'ID', 9, 'Name', 9, 9, 'Quantity', 10,10, '$'

; Main menu attributes definitions
MainMenu db 10,10,10, "------------------------", 10 
         db "--- Inventory System ---", 10           
         db "------------------------", 10,10        
         db "1. Display Items", 10                   
         db "2. Add Item", 10                        
         db "3. Sell Item", 10
         db "4. Display Low Stock Items", 10      ; New option added                  
         db "0. Exit Program", 10,10                 
         db "------------------------", '$'    

;Item`s header and columns
ItemList dw 00, 01, 02, 03, 04, 05, 06, 07, 08, 09
         db "M.board   ", "Memory    ", "CPU       ", "GPU       ", "Power Unit", "Comp. case", "Fans      ", "HDD       ", "SSD       ", "Monitor   "
         dw 10, 1, 10, 2, 10, 3, 10, 4, 10, 5, 1500, 800, 2000, 1700, 800, 600, 400, 1200, 1500, 1300, 2, 1, 0, 0, 1, 1, 2, 1, 2, 0, '$'
ItemHeader db 10, '==============| INVENTORY |==============', 10 
           db '==============================================', 10 
           db 'ID', 9, 'Name', 9, 9, 'Price', 9, 'Quantity', 10,10, '$' 

SupplyMessage db '==============================================', 10,10 
              db ' Items are low in stock, please supply some.', 10,10        
              db '==============================================', 10,10   
              db '1. Main Menu', 10,10                                    
              db '0. Exit Program', 10,10                                 
              db 'Please select an option: $'                             

ItemToSupply dw ?                    ; Variable for item to supply
ItemSupplyID dw ?                    ; Variable for supply item ID

;Supply definitions / Add items procedure
SupplyHeader db '==============================================', 10,10 
             db 9, 9, 32, 32, 'ADD ITEMS', 10,10                         
             db '==============================================', 10,10   
             db 'Enter item ID: $'                                       
SupplyPrompt db 10,10, 'Enter quantity to supply from 1 to 9: $' 
SupplySuccess db 10,10, ' Item supplied successfully.', 10, '$' 

;Sell Menu Definitions
SellHeader db '==============================================', 10,10 
           db 9, 9, 32, 32, 'SELL ITEM', 10,10                         
           db '==============================================', 10,10   
           db 'Enter item ID: $'                                        ;
SellPrompt db 10,10, 'Enter quantity to sell from 1 to 9: $' 
SellSuccess db 10,10, ' Item sold successfully.', 10, '$'    
SellFailure db 10,10, ' Insufficient quantity to sell.', 10, '$' 

;Additional definitions
InputError db 10, 'Invalid option selected.', 10, '$' ; Input error message
UserInputPrompt db 10,10, 'Please select an option: $' ; User input prompt
ExitMsgMessage db 10,10, '=======| Thank you for using the inventory system |=======','$' ; ExitMsg message
BlankSpace db '                           ','$' ; Blank space string


;Code segment
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
  
  cmp al, '4'
  jmp DisplayLowStockItems ; jump to DisplayLowStockItems

  cmp al, '0'         
  je ExitProgram      ; jump to ExitProgram

  jmp main            ; Similar to break(), jumps back to main function

;ShowItems Procedure Segment
ShowItems:              
    call Refresh
    call DisplayItems
    call NavigateAfterDisplay
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

AddItemsMenu:
    call Refresh
    call DisplayItems
    call SupplyItems
    ret

SellItemsMenu:
    call Refresh
    call DisplayItems
    call SellItems
    ret

ExitProgram:
    call Refresh
    call ExitMsg
    ret

PrintInt:
    push bx
    mov bx, 10
    xor cx, cx

LOOP:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    cmp ax, 0
    jne Loop

OutLoop:
    pop dx
    mov ah, 02
    int 21h
    dec cx
    cmp cx, 0
    jne OutLoop
    pop bx
    ret

CheckVal:
    mov bx, ax
    cmp bx, 5
    jle MarkValue
    ret

PrintStr:
    push ax 
    push bx
    push cx
    mov bx, dx 
    mov cx, 10 

StrLoop:
    mov dl, [bx] 
    int 21h 
    inc bx 
    loop StrLoop 

RestoreStack:
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

MarkRestoreStack:
    pop cx 
    pop bx
    pop ax
    ret

DisplayMainMenu:
    call Refresh
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

ItemsLoop:
    mov ax, [si]
    cmp ax, 10
    ja ItemsEnd
    call PrintInt
    call PrintTab

    mov dx, offset ItemList + 20
    add dx, bp
    call PrintStr
    call PrintTab

    mov ax, [si + 140]
    call PrintInt
    call PrintTab

    mov ax, [si + 120]
    call CheckVal

    mov ax, [si + 120]
    call PrintInt
    call PrintNewLine
    add bp, 10
    add si, 2
    jmp ItemsLoop
ItemsEnd:
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
    
    call Refresh
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
    js InsufficientAmount

    mov word ptr [si], bx
    jmp ItemSold

InsufficientAmount: 
    mov bx, [si]
    mov word ptr [si], bx
    call Refresh
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
    call TotalSold
    call Refresh
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
    
TotalSold: 
    mov ax, ItemAmount 
    sub ax, 120 
    mov ItemAmount, ax
    lea si, ItemList 
    add si, ItemAmount
    mov ax, [si]
    add cx, ax 
    mov word ptr [si], cx
    ret

DisplayLowStockItems:
    ; Clear the screen
    call Refresh
    
    ; Display the Low Stock Header
    lea dx, LowStockHeader
    mov ah, 09h
    int 21h

    ; Initialize pointers and counters
    mov bp, 0
    lea si, ItemList

LowStockLoop:
    ; Load the current item quantity into ax
    mov ax, [si + 120]

    ; Compare the quantity to the low stock threshold (let's say 5)
    cmp ax, 5
    ja SkipLowStockItem  ; If quantity is greater than 5, skip the item

    ; Print the item ID
    mov ax, [si]
    call PrintInt
    call PrintTab

    ; Print the item name
    mov dx, offset ItemList + 20
    add dx, bp
    call PrintStr
    call PrintTab

    ; Print the item quantity
    mov ax, [si + 120]
    call PrintInt
    call PrintNewLine

SkipLowStockItem:
    ; Move to the next item in the list
    add bp, 10
    add si, 2

    ; Check if we have processed all items
    mov ax, [si]
    cmp ax, 10
    ja LowStockEnd

    ; Continue the loop
    jmp LowStockLoop

LowStockEnd:
    ; Navigate after displaying low stock items
    call NavigateAfterDisplay
    ret

ExitMsg:
  lea dx, ExitMsgMessage
  mov ah, 09h
  int 21h  
  mov ah, 4ch
  int 21h

Refresh:
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
