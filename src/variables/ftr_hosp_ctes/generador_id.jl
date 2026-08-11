using SHA

function get_ctes_id(fecha, tipo, episodio)
    #Generamos HASH para obtener ID determinista
    hash = sha256("$fecha|$tipo|$episodio")

    #SHA-256 genera un vector de 32 bytes (256 bits)
    #Cogemos 8 bytes (64 bits) para crear el ID
    bits = hash[1:8]

    #Interpretamos los bytes siempre en el mismo orden
    #ntoh permite obtener el mismo resultado en cualquier arquitectura
    uint = ntoh(reinterpret(UInt64, bits)[1])

    #Ponemos numero en negativo forzando a 1 el bit 63
    uint |= UInt64(1) << 63

    #Interpretamos los 64 bits como un Int64
    return reinterpret(Int64, uint)
end