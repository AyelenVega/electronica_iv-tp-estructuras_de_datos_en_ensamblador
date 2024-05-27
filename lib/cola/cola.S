.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.macro defun nombre
    .section .text.\nombre
    .global \nombre
    .type \nombre, %function
\nombre:
.endm

.macro endfun nombre
    .size \nombre, . - \nombre
.endm

.equ Cola_base,0
.equ Cola_limite,4
.equ Cola_escritura,8
.equ Cola_lectura,12
.equ Cola_llena,16 



/**
 * @brief Inicializa un descriptor de cola
 * 
 * @param descriptor Descriptor
 * @param base Dirección base de memoria
 * @param tamano Tamano de memoria para la cola
 */
defun Cola_init
    /*
    R0 descriptor
    R1 base
    R2 numero de elementos
    */
    add R3, R1, R2, lsl #2
    mov R12, #0
    str R1 ,[R0, #Cola_base]
    str R3 ,[R0, #Cola_limite]
    str R1 ,[R0, #Cola_escritura]
    str R1 ,[R0, #Cola_lectura]
    str R12,[R0, #Cola_llena]
    bx lr
endfun Cola_init

/**
 * @brief Pone un nuevo valor en cola.
 * 
 * @param descriptor Descriptor de cola
 * @param valor Valor a introducir
 * @return int 0 si la operación fue exitosa. -1 si la cola estaba llena.
 */
defun Cola_pone
    /*
    R0 descriptor
    R1 valor
    */
    push {r4-r5,lr}

    ldr R2 ,[R0,#Cola_limite]
    ldr R3 ,[R0,#Cola_escritura]
    ldr R4 ,[R0,#Cola_lectura]
    ldr R5 ,[R0,#Cola_base]
    ldr R12,[R0,#Cola_llena]
    /*
    pasos
    1- me fijo que la cola no este llena
    2- guardo el valor
    3- muevo puntero
    4- me fijo si estoy en el limite, en caso de estarlo mueve el puntero a la base
    5- me fijo si el puntero de escritura y lectura estan en el mismo lugar, en caso de estarlo, la cola esta llena
    */
    cmp R12,#0    
    bne 1f  
    str R1,[R3]  
    add R3,#4    
    cmp R3,R2    
    beq 2f 

    0:  
        cmp R3,R4    // Comparo puntero de escritura con puntero lectura
        beq 3f
        str R3,[R0,#Cola_escritura]
        mov R0,#0
        b fin

    1:  
        mov R0,#-1  // Si la cola esta llena devuelvo -1
        b fin

    2: 
        mov R3,R5   //Si el puntero de esctritura llego al limite, lo muevo a la base
        b 0b        //vuelvo para comparar pEscritura y pLectura

    3:   //Si pEscritura y pLectura son iguales, significa que la cola esta llena
        mov R12, #1             
        str R12,[R0,#Cola_llena]
        str R3,[R0,#Cola_escritura]
        mov R0,#0
        b fin
  
    fin:
        pop {r4-r5,pc}
endfun Cola_pone
/**
 * @brief Quita el elemento más antiguo de la cola y escribe su valor en 
 * destino.
 * 
 * @param descriptor Descriptor de cola
 * @param destino Puntero a variable donde guardar el valor quitado
 * @return int 0 si la operación tuvo éxito. -1 si la cola estaba vacía.
 */
defun Cola_quita
    /*
    R0 descriptor
    R1 destino
    */

    push {r4-r6,lr}

    ldr R2 ,[R0,#Cola_limite]
    ldr R3 ,[R0,#Cola_escritura]
    ldr R4 ,[R0,#Cola_lectura]
    ldr R5 ,[R0,#Cola_base]
    ldr R12,[R0,#Cola_llena]

    /*
    Pasos
    1- Si Cola_llena=1, hago Cola_llena=0. En caso de que Cola_llena = 0, me fijo si la cola estaba vacia. Si estaba vacia devuelvo -1, sino hago los siguientes pasos
    2- Copio el valor
    3- Muevo el puntero
    4- Me fijo si estoy en el limite, en caso de estarlo, muevo pLectura a la base

    */

    cmp R12,#1
    bne 1f
    mov R12,#0
    str R12,[R0,#Cola_llena]
    
    0:
        ldr R6,[R4]
        str R6,[R1]
        add R4,#4
        cmp R4,R2
        beq 2f
        str R4,[R0,#Cola_lectura]
        mov R0,#0
        b salida

    1:
        cmp R3,R4
        bne 0b
        mov R0,#-1
        b salida

    2:
        mov R4,R5
        str R4,[R0,#Cola_lectura]
        mov R0,#0
        b salida


    salida:    
        pop {r4-r6,pc}

endfun Cola_quita