;Jambulov Timur TP07154 = CSLLT Individual Assignment Code = Inventory Management System
; 64KB space for program
.model small
; 256 bytes stack
.stack 100h

; Data segment
.data

; Constants
MAX_ITEMS equ 40    ; Maximum number of items

; Item attributes definitions
ItemCount dw 2                     
NameLength equ 20               
IDValue equ 2                        
ValueAmount equ 2                     
ProductData dw 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, '$'
PriceList dw 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, '$'
TotalRevenue dw 1                  

; headerline for low Stock items menu
LowStockMenu db 10, '==============| LOW STOCK ITEMS |==============', 10
             db '==============================================', 10 
             db 'ID', 9, 'Title', 9, 9, 'Amount', 10,10, '$'

; Main menu attributes definitions
MainOptions db 10,10,10, "============================", 10 
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


RestockMessage db '==========================================================', 10,10 
               db '===| Some items are low in stock, please supply more !|===', 10,10        
               db '==========================================================', 10,10   
               db '1. Leave to title/main menu', 10,10                                    
               db '0. Terminate program', 10,10                                 
               db 'Please select an option: $'                             

SupplyItem dw ?                    ; Variable for item to supply
SupplyItemID dw ?                  ; Variable for supply item ID

;Supply definitions / Add items procedure
RestockHeader db '==========================================================', 10,10 
               db 32, 32, 32, 32, 'ADD ITEMS', 10,10                         
               db '==========================================================', 10,10   
               db 'Input item ID: $'                                       
RestockPrompt db 10,10, 'Input amount to supply from 1 to 9: $' 
RestockSuccess db 10,10, ' Item supplied successfully.', 10, '$' 

;Sell Menu Definitions
SellMenuHeader db '==========================================================', 10,10 
               db 32, 32, 32, 32, 'SELL ITEM', 10,10                         
               db '==========================================================', 10,10   
               db 'Please provide/input item ID: $'                                        ;
SellPrompt db 10,10, 'Input amount to sell from 1 to 9: $' 
SellSuccess db 10,10, ' Item sold successfully.', 10, '$'    
SellFailure db 10,10, ' Insufficient amount to sell.', 10, '$' 

;Additional definitions
ErrorMsg db 10, 'Invalid option selected.', 10, '$' 
PromptMsg db 10,10, 'Please select an option: $' 
ExitMessage db 10,10, '=======| Thank you for choosing our shop! |=======','$' 
BlankLine db '                           ','$' 


;Code segment
.code
start PROC
;Getting the data segment address and loading into DS reg.
  mov ax, @data       
  mov ds, ax          
  
  call ShowMainMenu ; Call procedure to display the title/main menu
  
  mov ah, 01h         
  int 21h             ; Read user input and interrupt of reading

  ;Basically a switch statement implemented in Assembly
  cmp al, '1'         
  je DisplayItems     ; option jumping to DisplayItems
  
  cmp al, '2'         
  je RestockMenu      ; option jumping to RestockMenu
  
  cmp al, '3'         
  je SellMenu         ; option jumping to SellMenu
  
  cmp al, '4'
  jmp ShowLowStockItems ; option jumping to ShowLowStockItems

  cmp al, '0'         
  je ExitProgram      ; option jumping to ExitProgram

  jmp start           ; Similar to break(), jumps back to start function

;DisplayItems Procedure Segment

;clears display, shows items and handles user`s choice after 
DisplayItems:              
    call ClearScreen
    call ListItems
    call AfterDisplayNav
    ret
;after successful execution, prompts user to either leave to main menu or exit the program
AfterDisplayNav:
    ;load and display restock message
    lea dx, RestockMessage
    mov ah, 09h
    int 21h

    ;prompt user for input
    mov ah, 01h
    int 21h

    ;check user input and navigate accordingly
    cmp al, '0'
    je TerminateProgram
    cmp al, '1'
    je RestartProgram
    jmp RestartProgram

TerminateProgram:
    call ExitProgram
    ret

RestartProgram:
    call start
    ret

;Menu functions, clears display, shows items and proceeds to the related procedures
RestockMenu:
    call ClearScreen
    call ListItems
    call RestockItems
    ret

SellMenu:
    call ClearScreen
    call ListItems
    call SellItems
    ret

;program exit procedure
ExitProgram:
    call ClearScreen
    call ShowExitMessage
    ret
;Check if ax value is greater than 5
ValidateValue:
    mov bx, ax
    cmp bx, 5
    jle HighlightValue
    ret
; ax value < 5, highlight the number on the display, thus marking the number of items that are low in stock
HighlightValue:
    push ax 
    push bx
    push cx
    mov bx, dx 
    mov cx, 10 

HighlightLoop:
    mov dl, [bx] 
    mov ah, 09h
    mov al, dl 
    mov bl, 0Eh 
    int 10h
    inc bx 
    loop HighlightLoop 

RestoreHighlight:
    pop cx 
    pop bx
    pop ax
    ret
;print strings(10 chars) by saving ax, bx, cx registers, printing out each character and restoring registers
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

RestorePrint:
    pop cx 
    pop bx
    pop ax
    ret
;GUI procedures
ShowMainMenu:
    call ClearScreen
    lea dx, MainOptions
    mov ah, 09h
    int 21h
    
    lea dx, PromptMsg
    mov ah, 09h
    int 21h
    ret

;display GUI for items and item menu
ListItems:
    mov dx, offset ItemHeader
    mov ah, 09
    int 21h
    
    mov bp, 0
    lea si, ItemList
;iterate through items
ItemLoop:
    mov ax, [si]
    cmp ax, 10
    ja EndItemLoop
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
    call ValidateValue

    mov ax, [si + 120]
    call PrintInteger
    call PrintNewLine
    add bp, 10
    add si, 2
    jmp ItemLoop
EndItemLoop:
    ret

;restock items = prompt user for item id, amount, add to total item number
RestockItems:
    lea dx, RestockHeader
    mov ah, 09h
    int 21h 
    mov ah, 01
    int 21h
    sub al, 30h 
    add al, al
    sub ax, 136

    mov SupplyItem, ax 
    lea dx, RestockPrompt
    mov ah, 09h 
    int 21h

    mov ah, 01
    int 21h
    sub al, 30h
    sub ax, 256
    mov cx, ax
    lea si, ItemList
    add si, SupplyItem
    add cx, [si]
    mov word ptr [si], cx 
    
    call ClearScreen
    call PrintNewLine
    call PrintBlankLine
    lea dx, RestockSuccess
    mov ah, 09h 
    int 21h 
    call PrintBlankLine
    call ListItems
    call AfterDisplayNav
    ret

;procedure SellItems = prompt user to item id, prompt for amount, deduct amount from total number of items
SellItems:
    lea dx, SellMenuHeader
    mov ah, 09h
    int 21h 

    mov ah, 01
    int 21h

    sub al, 30h
    add al, al 
    sub ax, 136 
    mov SupplyItem, ax 

    lea dx, SellPrompt
    mov ah, 09h 
    int 21h

    mov ah, 01
    int 21h
    sub al, 30h
    sub ax, 256
    mov cx, ax

    lea si, ItemList
    add si, SupplyItem
    mov bx, [si] 
    sub bx, cx
    cmp bx, 0
    js InsufficientStock

    mov word ptr [si], bx
    jmp SoldItem

;if selling amount > total amount, restore original item number, send error msg and return to menu
InsufficientStock: 
    mov bx, [si]
    mov word ptr [si], bx
    call ClearScreen
    call PrintNewLine
    call PrintBlankLine
    lea dx, SellFailure
    mov ah, 09h 
    int 21h 
    call PrintBlankLine
    call PrintNewLine
    call ListItems
    call AfterDisplayNav
    ret 

;successful sale = update total sales, refresh, success msg, updated item list, back to menu
SoldItem:
    call UpdateTotalSales
    call ClearScreen
    call PrintNewLine
    call PrintBlankLine
    lea dx, SellSuccess
    mov ah, 09h
    int 21h

    call PrintBlankLine
    call PrintNewLine
    call ListItems
    call AfterDisplayNav
    ret

;updates total items sold amount and adjusts item amount
UpdateTotalSales: 
    mov ax, ItemCount 
    sub ax, 120 
    mov ItemCount, ax
    lea si, ItemList 
    add si, ItemCount
    mov ax, [si]
    add cx, ax 
    mov word ptr [si], cx
    ret

;displays items with low stock
ShowLowStockItems:
    call ClearScreen
    lea dx, LowStockMenu
    mov ah, 09h
    int 21h
    mov bp, 0
    lea si, ItemList

LowStockLoop:
    mov ax, [si + 120]
    cmp ax, 5
    ja SkipLowStockItem  
    mov ax, [si]
    call PrintInteger
    call PrintTab
    mov dx, offset ItemList + 20
    add dx, bp
    call PrintString
    call PrintTab
    mov ax, [si + 120]
    call PrintInteger
    call PrintNewLine

SkipLowStockItem:
    add bp, 10
    add si, 2
    mov ax, [si]
    cmp ax, 10
    ja EndLowStockLoop
    jmp LowStockLoop

EndLowStockLoop:
    call AfterDisplayNav
    ret

;displays exit message and terminates the program
ShowExitMessage:
  lea dx, ExitMessage
  mov ah, 09h
  int 21h  
  mov ah, 4ch
  int 21h

;clears the display by scrolling the window
ClearScreen:
    mov ah, 06h
    mov al, 0
    mov bh, 07h
    mov cx, 0
    mov dx, 184Fh
    int 10h
    ret

;converting int value to str value using ax register and prints on display
PrintInteger:
    push bx
    mov bx, 10
    xor cx, cx
;converts value, push into stack in reverse order
IntReverseLoop:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    cmp ax, 0
    jne IntReverseLoop
;outputs digits of int pushed into stack, reversing second time, output appear in correct order
IntOutLoop:
    pop dx
    mov ah, 02
    int 21h
    dec cx
    cmp cx, 0
    jne IntOutLoop
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

PrintBlankLine:
    lea dx, BlankLine
    mov ah, 09h 
    int 21h 
    ret

start endp
end start
