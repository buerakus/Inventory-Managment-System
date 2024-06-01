.model small
.stack 100h
; Data segment
.data
    ; Main Menu byte array
    topLine db 10, "=============================="
    programName db 10, "=====Inventory System=====" 
    downLine db 10, "=============================="
    availableOptions db 10, " 1. Display inventory"
        db 10, " 2. Categorize"
        db 10, " 3. Add position"
        db 10, " 4. Modify position"
        db 10, " 5. Delete position"
        db 10, " 6. Buy item"
        db 10, " 7. Exit"
        db 10, "------------------------"
        db 10, "Please Select Your Choice: $"
    
    ; Invalid input message
    inputError db 10,10, "The input given is not a available option. Try again!"


; Code Segment
.code

Main proc

main endp

end main
