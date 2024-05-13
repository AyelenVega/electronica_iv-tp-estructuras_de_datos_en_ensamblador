.syntax unified
.cpu cortex-m3
.thumb

.text

/**
 * @brief Compara dos regiones de memoria byte a byte como valores *sin signo*. 
 * Retorna 0 si son iguales, -1 si en la primera diferencia el valor de
 * izquierda es el menor y 1 si en la primera diferencia el valor de la
 * izquierda es mayor
 * 
 * @param izquierda Dirección base de la primera región
 * @param derecha Dirección base de la segunda región
 * @param tamano tamaño de las regiones
 * @return int 
 */

    .type comparaMemoria, %function
    .global comparaMemoria

comparaMemoria:
    /* 
    r0 = dirección base de la primera region (izquierda)
    r1 = dirección base de la segunda region (derecha)
    r2 = tamaño de las regiones
    */

    bucle_comparacion:
        ldrb r3, [r0]  
        ldrb r4, [r1]
        add r0,#1
        add r1,#1  
        cmp r3, r4         
        blo izquierda_menor 
        bhi izquierda_mayor 
        subs r2, r2, #1    
        bne bucle_comparacion 

    movs r0, #0
    bx lr

    izquierda_menor:
        movs r0, #-1
        bx lr
    izquierda_mayor:
        movs r0, #1
        bx lr    
