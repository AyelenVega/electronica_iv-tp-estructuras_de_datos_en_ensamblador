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

.equ Arreglo_base, 0
.equ Arreglo_tamanio_elementos, 4
.equ Arreglo_numero_elementos, 8

/**
 * @brief Inicializa un descriptor que describe un arreglo con una direccion de
 * memoria base, tamaño de elemento y número de elementos dados
 * 
 * @param descriptor Puntero al descriptor a inicializar 
 * @param base Dirección base del arreglo
 * @param tamanoElemento Tamaño del elemento
 * @param numElementos Número de elementos
 */
defun Arreglo_init
    /*
    R0 puntero a descriptor
    R1 direccion base del arreglo
    R2 numero de elementos
    */
    str R1,[R0, #Arreglo_base]
    str R2,[R0, #Arreglo_tamanio_elementos]
    str R3,[R0, #Arreglo_numero_elementos]
    bx lr
endfun Arreglo_init

/**
 * @brief Retorna un puntero a un elemento del arreglo descrito
 * 
 * @param descriptor Descriptor de arreglo inicializado con Arreglo_init
 * @param indice
 * @return void* Puntero al elemento indicado por indice, NULL si no existe el
 * elemento (NULL es la dirección 0)
 */
defun Arreglo_apunta
    /*
    R0 descpritor
    R1 indice
    */
    ldr R2,[R0, #Arreglo_numero_elementos]
    cmp R1, R2
    bhs 0f
    ldr R2,[R0, #Arreglo_tamanio_elementos]
    ldr R0,[R0, #Arreglo_base]
    mla R0, R2, R1, R0
    b 1f
    0:
        mov r0,#0
        b 1f
    1: 
        bx lr    

endfun Arreglo_apunta

/**
 * @brief Lee el valor de un elemento del arreglo descrito, copiándolo en el
 * espacio de memoria proporcionado. Supone que la región de memoria tiene
 * tamaño suficiente
 * 
 * @param descriptor Descriptor del arreglo
 * @param indice Índice del elemento a leer
 * @param destino Puntero a la regió de memoria donde copiar el valor
 * @return int 0 si la operación pudo realizarse, -1 si el elemento no existe
 */
defun Arreglo_lee
    /*
    R0 decriptor
    R1 indice
    R2 puntero a destino
    */

    ldr R3,[R0, #Arreglo_numero_elementos]
    cmp R1, R3
    bhs 1f
    ldr R3,[R0, #Arreglo_tamanio_elementos]
    ldr R0,[R0, #Arreglo_base]
    mla R0, R3, R1, R0
    add R3, R0
    0:
        cmp R0, R3
        bhs 2f
        ldrb R1,[R0],#1
        strb R1,[R2],#1
        b 0b
    1:
        mov R0,#-1
        b 3f
    2:
        mov R0,#0
        b 3f
    3:    
        bx lr

endfun Arreglo_lee

/**
 * @brief Escribe el valor proporcionado en el arreglo descrito
 * 
 * @param descriptor Descriptor de arreglo
 * @param indice Índice del elemento a escribir
 * @param origen Puntero a región conteniendo los datos a escribir
 * @return int 0 si efectuó la operación, -1 si no existe el elemento en el
 * arreglo
 */
defun Arreglo_escribe
    /*
    R0 decriptor
    R1 indice
    R2 puntero a base
    */

    ldr R3,[R0, #Arreglo_numero_elementos]
    cmp R1, R3
    bhs 1f
    ldr R3,[R0, #Arreglo_tamanio_elementos]
    ldr R0,[R0, #Arreglo_base]
    mla R0, R3, R1, R0
    add R3, R0
    0:
        cmp R0, R3
        bhs 2f
        ldrb R1,[R2],#1
        strb R1,[R0],#1
        b 0b
    1:
        mov R0,#-1
        b 3f
    2:
        mov R0,#0
        b 3f
    3:    
        bx lr

endfun Arreglo_escribe

/**
 * @brief Intercambia los valores de dos elementos del arreglo
 * 
 * @param descriptor Descriptor de arreglo
 * @param indice_1 Primer índice
 * @param indice_2 Segundo índice
 * @return int 0 si tuvo exito, -1 si algún elemento no existe
 */
defun Arreglo_intercambia
    push {r4-r6, lr}
    mov R4,R0
    mov R5,R1
    mov R6,R2
    bl Arreglo_apunta
    mov R5,R0
    mov R0,R4
    mov R1,R6
    bl Arreglo_apunta
    mov R6,R0
    ldr R0,[R4,#Arreglo_tamanio_elementos]
    add R0,R5
    cbz R5,2f
    cbz R6,2f
    0:
        cmp R5,R0
        bhs 1f
        ldrb R1,[R5]
        ldrb R2,[R6]
        strb R2,[R5],#1
        strb R1,[R6],#1
        b 0b
    1:
        mov R0,#0
        b fin
    2:
        mov r0,#-1
   
    fin: 
        pop {r4-r6, pc}

endfun Arreglo_intercambia