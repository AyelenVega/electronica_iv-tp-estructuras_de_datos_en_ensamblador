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

.equ Pila_base,0
.equ Pila_limite,4
.equ Pila_puntero,8

/**
 * @brief Inicializa un descriptor de pila. Inicialmente la pila está vacía
 * 
 * @param descriptor Descriptor a inicializar
 * @param base Dirección base (menor dirección) de la pila
 * @param capacidad Capacidad de la pila (en elementos)
 */
defun Pila_init
    /*
    R0 puntero a descriptor
    R1 direccion base de la pila
    R2 numero de elementos
    */
    add R3, R1, R2, lsl #2
    str R1,[R0, #Pila_base]
    str R3,[R0, #Pila_limite]
    str R1,[R0, #Pila_puntero]
    bx lr
endfun Pila_init

/**
 * @brief Ingresa un valor en la pila descrita
 * 
 * @param descriptor Descriptor de pila
 * @param valor Valor a ingresar
 * @return int 0 si la operación se realizó, -1 si la pila estaba llena
 */
defun Pila_push
    /*
    R0 descriptor
    R1 valor
    */
    ldr R2,[R0,#Pila_puntero]
    ldr R3,[R0,#Pila_limite] 
    0:
        cmp R2,R3
        bhs 1f
        str R1,[R2]
        add R2,#4
        str R2,[R0, #Pila_puntero]
        mov R0,#0
        b fin
    1:
        mov r0,#-1
        b fin
    fin: 
        bx lr
endfun Pila_push

/**
 * @brief Quita el último elemento de la pila descrita y copia su valor en
 * destino
 * 
 * @param descriptor Descriptor de pila
 * @param destino Dirección de la variable de destino
 * @return int 0 si la operación se realizó, -1 si la pila estaba vacía
 */
defun Pila_pop
    /*
    R0 descriptor
    R1 direccion destino
    */

    ldr R2,[R0,#Pila_puntero]
    ldr R3,[R0,#Pila_base] 
    0:
        cmp R2, R3
        bls 1f
        sub R2,R2,#4
        ldr R12,[R2]
        str R12,[R1]
        str R2,[R0,#Pila_puntero]
        mov R0, #0
        b 2f

    1:
        mov r0,#-1
    2:    
        bx lr
endfun Pila_pop
