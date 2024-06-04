;Jambulov Timur TP07154 = CSLLT Individual Assignment Code = Inventory Managment System
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
ItemData dw 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, '$'
ItemPriceList dw 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, '$'
TotalSales dw 0                     

; Low Stock Item menu header
LowStockHeader db 10, '==============| LOW STOCK ITEMS |==============', 10 
               db '==============================================', 10 
               db 'ID', 9, 'Title', 9, 9, 'Amount', 10,10, '$'

; Main menu attributes definitions
MainMenu db 10,10,10, "============================", 10 
         db "=== TIMUR`S PCPARTS SHOP ===", 10           
         db "============================", 10,10        
         db "1. Display Items", 10                   
         db "2. Add Item", 10                        
         db "3. Sell Item", 10
         db "4. Display Low Stock Items", 10                      
         db "0. Exit Program", 10,10                 
         db "========================", '$'    

;Item`s header and columns
ItemList dw 00, 01, 02, 03, 04, 05, 06, 07, 08, 09
         db "M.board   ", "Memory    ", "CPU       ", "GPU       ", "Power Unit", "Comp. case", "Fans      ", "HDD       ", "SSD       ", "Monitor   "
         dw 10, 1, 10, 2, 10, 3, 10, 4, 10, 5, 1500, 800, 2000, 1700, 800, 600, 400, 1200, 1500, 1300, 2, 1, 0, 0, 1, 1, 2, 1, 2, 0, '$'
ItemHeader db 10, '================| TIMUR`S PCPARTS SHOP |==================', 10 
           db '==========================================================', 10 
           db 'ItemID', 9, 'Name', 9, 9, 'Price', 9, 'Amount', 10,10, '$' 


SupplyMessage db '==========================================================', 10,10 
              db '===| Some items are low in stock, please supply more !|===', 10,10        
              db '==========================================================', 10,10   
              db '1. Main Menu', 10,10                                    
              db '0. Exit Program', 10,10                                 
              db 'Please select an option: $'                             

ItemToSupply dw ?                    ; Variable for item to supply
ItemSupplyID dw ?                    ; Variable for supply item ID

;Supply definitions / Add items procedure
SupplyHeader db '==========================================================', 10,10 
             db 9, 9, 32, 32, 'ADD ITEMS', 10,10                         
             db '==========================================================', 10,10   
             db 'Input item ID: $'                                       
SupplyPrompt db 10,10, 'Input amount to supply from 1 to 9: $' 
SupplySuccess db 10,10, ' Item supplied successfully.', 10, '$' 

;Sell Menu Definitions
SellHeader db '==========================================================', 10,10 
           db 32, 32, 32, 32, 'SELL ITEM', 10,10                         
           db '==========================================================', 10,10   
           db 'Input item ID: $'                                        ;
SellPrompt db 10,10, 'Input amount to sell from 1 to 9: $' 
SellSuccess db 10,10, ' Item sold successfully.', 10, '$'    
SellFailure db 10,10, ' Insufficient amount to sell.', 10, '$' 

;Additional definitions
InputError db 10, 'Invalid option selected.', 10, '$' 
UserInputPrompt db 10,10, 'Please select an option: $' 
ExitMsgMessage db 10,10, '=======| Thank you for choosing our shop! |=======','$' 
BlankSpace db '                           ','$' 


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
  je ShowItems        ; option jumping to ShowItems
  
  cmp al, '2'         
  je AddItemsMenu     ; option jumping to AddItemsMenu
  
  cmp al, '3'         
  je SellItemsMenu    ; option jumping to SellItemsMenu
  
  cmp al, '4'
  jmp DisplayLowStockItems ; option jumping to DisplayLowStockItems

  cmp al, '0'         
  je ExitProgram      ; option jumping to ExitProgram

  jmp main            ; Similar to break(), jumps back to main function

;ShowItems Procedure Segment

;clears display, shows items and handles user`s choice after 
ShowItems:              
    call Refresh
    call DisplayItems
    call NavigateAfterDisplay
    ret
;after successful execution, promts user to either leave to main menu or leave from program
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

;Menu functions, clears display, shows items and proceed to the related procedures
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

;program exit procedure
ExitProgram:
    call Refresh
    call ExitMsg
    ret
;Check if ax value is greater than 5
CheckVal:
    mov bx, ax
    cmp bx, 5
    jle MarkValue
    ret
;If value ax value less than 5, highlight the number onto display, thus allowing to have marked number of items that are low in stock
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
;print strings(10 chars) by saving ax, bx, cx registers, printing out each character and restoring registers
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
;GUI functions
DisplayMainMenu:
    call Refresh
    lea dx, MainMenu
    mov ah, 09h
    int 21h
    
    lea dx, UserInputPrompt
    mov ah, 09h
    int 21h
    ret

;display GUI for items and item menu
DisplayItems:
    mov dx, offset ItemHeader
    mov ah, 09
    int 21h
    
    mov bp, 0
    lea si, ItemList
;iterate through items
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

;supply items = promt user for item id, amount, add to total item number
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

;sell items = promt user to item id, promt for amount, deduct amount from total number of items
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

;if sell amount > total amount, restore original item number, send error msg and return to menu
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

;successful sale = update total sales, refresh, success msg, updated itemlist, back to menu
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

;updates the total sold amount and adjusts item amount
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

;displays items with low stock
DisplayLowStockItems:
    call Refresh
    lea dx, LowStockHeader
    mov ah, 09h
    int 21h
    mov bp, 0
    lea si, ItemList

LowStockLoop:
    mov ax, [si + 120]
    cmp ax, 5
    ja SkipLowStockItem  
    mov ax, [si]
    call PrintInt
    call PrintTab
    mov dx, offset ItemList + 20
    add dx, bp
    call PrintStr
    call PrintTab
    mov ax, [si + 120]
    call PrintInt
    call PrintNewLine

SkipLowStockItem:
    add bp, 10
    add si, 2
    mov ax, [si]
    cmp ax, 10
    ja LowStockEnd
    jmp LowStockLoop

LowStockEnd:
    call NavigateAfterDisplay
    ret

;displays exit message and terminates the program
ExitMsg:
  lea dx, ExitMsgMessage
  mov ah, 09h
  int 21h  
  mov ah, 4ch
  int 21h

;clears the display by scrolling the window
Refresh:
    mov ah, 06h
    mov al, 0
    mov bh, 07h
    mov cx, 0
    mov dx, 184Fh
    int 10h
    ret

;converting int value to str value using ax register and prints on display
PrintInt:
    push bx
    mov bx, 10
    xor cx, cx
;converts value, push into stack in reverse order
InLoopReverse:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    cmp ax, 0
    jne InLoopReverse
;outputs digits of int pushed into stack, reversing second time, output appear in correct order
OutLoop:
    pop dx
    mov ah, 02
    int 21h
    dec cx
    cmp cx, 0
    jne OutLoop
    pop bx
    ret
;helper functions
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
