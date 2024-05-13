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
            ldrb r3, [r1]       
            strb r3, [r0]
            add r1,#1
            add r0,#1      
            subs r2, r2, #1        
            bne copia_izquierda_a_derecha      
            b fin

    copia_derecha_a_izquierda:
            add r4,r1,r2
            add r5,r0,r2
            bucle:
                ldrb r3,[r4]    
                strb r3,[r5]  
                sub r4,#1
                sub r5,#1 
                subs r2, r2, #1        
                bne bucle     
            b fin            
    fin:
        bx lr    