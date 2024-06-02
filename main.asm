.model small
.stack 100h
.data

MaxItemCount equ 40

ItemList dw 00, 01, 02, 03, 04, 05, 06, 07, 08, 09
            db "M.board   ",  "Memory    ", "CPU       ", "GPU       ", "Power Unit", "Comp. case", "Fans      ", "HDD       ", "SSD       ", "Monitor   "
            dw 2, 9, 1, 2, 3, 8, 6, 3, 8, 10, 12, 13, 6, 17, 4, 19, 9, 2, 7, 5, 2, 1, 0, 0, 1, 1, 2, 1, 2, 0, '$'

ItemAmount dw 2
ItemName equ 20
ItemNumber equ 2
ItemPrice equ 2
ItemInfo dw 2, 1, 0, 2, 1, 0, 40, 10, 19, 13, '$' 
ItemCost dw 5, 8, 4, 2, 4, 9, 8, 1, 8, 10, '$'
TotalSold dw 0

BlankCharacter db '                           ','$'

NL equ 13           
NLF equ 10           
TS equ 9           
BS equ 32        

MainMenuTopHorizontal db NL, '   | Item INVENTORY SYSTEM |       ', NL, NLF, '=====================================', NL, NLF, NLF, '1. Display Item', NL, NLF, '2. Add Item', NL, NLF, '3. Sell Item', NL, NLF, '4. Generate Item Report', NL, NLF, '0. Go Out of Program', NL, NLF, '=====================================', NL, NLF, '$'
InputMessageError db NL, NLF, 'Incorrect selection. Please choose only number.', NL, NLF, '$'

ItemsTopHorizontal db NL, NLF, '              | Item DISPLAY |          ', NL, NLF, '==============================================', NL, NLF, 'Number', TS, 'Name', TS, TS, 'Price', TS, 'Quantity', NL, NLF, '$'
ResupplyNeedMsg db '==============================================', NL, NLF, ' Items in low quantity, please ReItem item  ', NL, NLF, '==============================================', NL, NLF, '1. Go to Main Page', NL, NLF, '0. Go Out of Program', NL, NLF, 'Please make your selection: $'


ItemNumberSupply dw ?
ItemNumberSupplyID dw ?



ResupplyTopHorizontal db '==============================================', NL, NLF, TS, TS, BS, BS, 'ADD ITEMS', NL, NLF, '==============================================', NL, NLF, 'Enter item Number : $'
ResupplyPromt db NL, NLF, 'What amount to replenish (1-9):  $'
ResupplyMsgSuccess db NL, NLF, '      Item replenished Done!', NL, NLF, '$'





SellItemTopHorizontal db '==============================================', NL, NLF, TS, TS, BS, BS, 'SELL Item', NL, NLF, '==============================================', NL, NLF, 'Enter item number : $'
SellItemPromt db NL, NLF, 'Enter the quantity to sell (1-9): $'
SellItemMsgSuccess db NL, NLF, '           Item sold Done!', NL, NLF, '$'
SellItemMsgFailure db NL, NLF, ' Failed to sell Item. Insufficient quantity!', NL, NLF, '$'




ReportTopHorizontal db NL, NLF, '        | Item SUMMARY REPORT SYSTEM |', NL, NLF, '==============================================', NL, NLF, 'Number', TS, 'Item', TS, TS, 'Quantity Sold', TS, 'Totally', NL, NLF, '$'
ReportTitleHorizontal db '==============================================', NL, NLF, '         DAILY SALES SUMMARY REPORT', NL, NLF, '==============================================', NL, NLF, '1. Go to Main Page', NL, NLF, '0. Go Out of Program', NL, NLF , NL, NLF, 'Please make your selection: $'




UserInput db NL, NLF, 'Please make your selection:  $'
choose_off db NL, NLF, ' ----  Good bye, Item inventory system most welcome   ----','$'





.code
main proc
  mov ax, @data 
  mov ds, ax 
  
  call ShowMain
  
  mov ah, 01h 
  int 21h

  cmp al, '1'
  je showItemMenu
  
  cmp al, '2'
  je ReplenishItem_menu
  
  cmp al, '3'
  je SellItemMenu
  
  cmp al, '4'
  je GenerateReportMenu
  
  cmp al, '0'
  je EndMenu

  jmp main



showItemMenu:
    call CleanPage
    call showItem
    call seller_navi
    ret

ReplenishItem_menu:
    call CleanPage
    call showItem
    call ReplenishItem
    ret

SellItemMenu:
    call CleanPage
    call showItem
    call SellItem
    ret

GenerateReportMenu:
    call GenerateReport
    call report_navi
    ret

EndMenu:
    call CleanPage
    call EndSystem
    ret



seller_navi:
    lea dx, ResupplyNeedMsg
    mov ah, 09h
    int 21h

    mov ah, 01h 
    int 21h

    cmp al, '0'
    je EndMenu

    cmp al, '1'
    je main

    jmp main

    ret

report_navi:
    lea dx, ReportTitleHorizontal
    mov ah, 09h
    int 21h

    mov ah, 01h 
    int 21h

    cmp al, '0'
    je EndMenu

    cmp al, '1'
    je main

    jmp main

    ret


ShowInteger:
    push bx
    mov bx, 10
    xor cx, cx

    BecomeLoopInner:
        xor dx, dx
        div bx
        add dl, '0'
        push dx
        inc cx
        cmp ax, 0
        jne BecomeLoopInner

    ShowSecondLoop:
        pop dx
        mov ah, 02
        int 21h
        dec cx
        cmp cx, 0
        jne ShowSecondLoop
        pop bx
        ret


intiger5:
    mov bx, ax
    cmp bx, 5
    jle Marking
    ret

showText:
    push ax 
    push bx
    push cx
    mov bx, dx 
    mov cx, 10 

ShowLoop:
    mov dl, [bx] 
    int 21h 
    inc bx 
    loop ShowLoop 

finish:
    pop cx 
    pop bx
    pop ax
    ret




Marking:
    push ax 
    push bx
    push cx
    mov bx, dx 
    mov cx, 10 

ShowLoop3:
    mov dl, [bx] 
    mov ah, 09h
    mov al, dl 
    mov bl, 0Eh 
    int 10h
    inc bx 
    loop ShowLoop3 

finish3:
    pop cx 
    pop bx
    pop ax
    ret



ShowMain:
    call CleanPage
    lea dx, MainMenuTopHorizontal
    mov ah, 09h
    int 21h
    
    lea dx, UserInput
    mov ah, 09h
    int 21h
    ret




showItem:
    mov dx, offset ItemsTopHorizontal
    mov ah, 09
    int 21h
    
    mov bp, 0
    lea si, ItemList

LoopBegin:
    mov ax, [si]
    cmp ax, 10
    ja done
    call ShowInteger
    call ShowBS

    mov dx, offset ItemList + 20
    add dx, bp
    call showText
    call ShowBS

    mov ax, [si + 140]
    call ShowInteger
    call ShowBS

    mov ax, [si + 120]
    call intiger5

    mov ax, [si + 120]
    call ShowInteger
    call ShowNext
    add bp, 10
    add si, 2
    jmp LoopBegin
done:
    ret




ReplenishItem:
    lea dx, ResupplyTopHorizontal
    mov ah, 09h
    int 21h 
    mov ah, 01
    int 21h
    sub al, 30h 
    add al, al
    sub ax, 136

    mov ItemNumberSupply, ax 
    lea dx, ResupplyPromt
    mov ah, 09h 
    int 21h

    mov ah, 01
    int 21h
    sub al, 30h
    sub ax, 256
    mov cx, ax
    lea si, ItemList
    add si, ItemNumberSupply
    add cx, [si]
    mov word ptr [si], cx 
    
    call CleanPage
    call ShowNext
    call ShowBegin
    lea dx, ResupplyMsgSuccess
    mov ah, 09h 
    int 21h 
    call ShowBegin
    call showItem
    call seller_navi
    ret



SellItem:
    lea dx, SellItemTopHorizontal
    mov ah, 09h
    int 21h 

    mov ah, 01
    int 21h

    sub al, 30h
    add al, al 
    sub ax, 136 
    mov ItemNumberSupply, ax 

    lea dx, SellItemPromt
    mov ah, 09h 
    int 21h

    mov ah, 01
    int 21h
    sub al, 30h
    sub ax, 256
    mov cx, ax

    lea si, ItemList
    add si, ItemNumberSupply
    mov bx, [si] 
    sub bx, cx
    cmp bx, 0
    js NewAmout

    mov word ptr [si], bx
    jmp SoldAmount

NewAmout: 
    mov bx, [si]
    mov word ptr [si], bx
    call CleanPage
    call ShowNext
    call ShowBegin
    lea dx, SellItemMsgFailure
    mov ah, 09h 
    int 21h 
    call ShowBegin
    call ShowNext
    call showItem
    call seller_navi
    ret 

SoldAmount:

    call sold_finish
    call CleanPage
    call ShowNext
    call ShowBegin
    lea dx, SellItemMsgSuccess
    mov ah, 09h
    int 21h

    call ShowBegin
    call ShowNext
    call showItem
    call seller_navi
    ret
    

sold_finish: 
    mov ax, ItemAmount 
    sub ax, 120 
    mov ItemAmount, ax
    lea si, ItemList 
    add si, ItemAmount
    mov ax, [si]
    add cx, ax 
    mov word ptr [si], cx
    ret
  ret


GenerateReport:
    call CleanPage
    mov dx, offset ReportTopHorizontal
    mov ah, 09
    int 21h
    
    mov bp, 0
    lea si, ItemList
    mov bx, offset ItemInfo
    mov di, offset ItemCost 


    LoopBegin2:
        mov ax, [si] 
        cmp ax, 10 
        ja done2 
        call ShowInteger 
        call ShowBS

        mov dx, offset ItemList + 20 
        add dx, bp 
        call showText 
        call ShowBS


        mov ax, [bx] 
        call ShowInteger 
        call ShowExtraBS
        

        mov cx, [bx]
        mov ax, [di]
        mul cx
        call ShowInteger
        call ShowNext

        add bp, 10
        add si, 2 
        add bx, 2
        add di, 2
        jmp LoopBegin2 
        
    done2:
    ret


EndSystem:
  lea dx, choose_off
  mov ah, 09h
  int 21h  
  mov ah, 4ch
  int 21h




CleanPage:
    mov ah, 06h
    mov al, 0
    mov bh, 07h
    mov cx, 0
    mov dx, 184Fh
    int 10h
    ret

ShowLine:
    lea dx, BlankCharacter
    mov ah, 09h
    int 21h
    ret

ShowBS:
    mov dl, 9
    mov ah, 02
    int 21h
    ret

ShowExtraBS:
    mov dl, 9
    mov ah, 02
    int 21h
    int 21h
    ret

ShowNext:
    mov dl, 0ah
    mov ah, 02
    int 21h
    ret

ShowBegin:
    lea dx, BlankCharacter
    mov ah, 09h 
    int 21h 
    ret


main endp
end main
