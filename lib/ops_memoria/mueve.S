.syntax unified
.cpu cortex-m3
.thumb


.text

/**
 * @brief Copia los tamano valores desde origen a destino, si la memoria de
 * destino se solapa con la de origen al final destino tiene que tener la copia
 * completa de los datos (y en ese caso origen no la tendrá más)
 * 
 * @param destino puntero a base (menor dirección) de la región de destino
 * @param origen puntero a base de la región de origen
 * @param tamano tamano de las regiones
 */

    .type mueveMemoria, %function
    .global mueveMemoria

mueveMemoria:
    /*
    r0 = puntero a base de la región de destino
    r1 = puntero a base de la región de origen
    r2 = tamaño de las regiones
    */

    cmp r0, r1 
    beq fin                             
    blo copia_izquierda_a_derecha        //direccion de destino menor a la de origen
    bhi copia_derecha_a_izquierda        //direccion de destino mayor a la de origen

    copia_izquierda_a_derecha:  
        bucle_izquierda_a_derecha:
            ldrb r3, [r1], #1       
            strb r3, [r0], #1       
            subs r2, r2, #1        
            bne bucle_izquierda_a_derecha       
            b fin

    copia_derecha_a_izquierda:
        bucle_derecha_a_izquierda:
            ldrb r3, [r1],#-1     
            strb r3, [r0],#-1    
            subs r2, r2, #1        
            bne bucle_derecha_a_izquierda      
            b fin            
    fin:
        bx lr    