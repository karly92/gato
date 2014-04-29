$jug=""
class Etapa_actual
 
#
  #crea el metodo tanto como para acceder, como para modificar las variables
 # attr_accessor :jugador_actual, :tablero, :movimiento
#metodo constructor
  def initialize(jugador_actual, tablero)
    @jugador_actual = jugador_actual
    @tablero = tablero
    @movimiento = []
  end

  def jugador_actual
    return @jugador_actual
  end
  def tablero
    return @tablero
  end

  def movimiento
    return @movimiento
  end

  def nivel
   #nivel va a ser igual o al estado final o a uno no final
   @nivel || (@nivel=nivel_final || nivel_no_final)
  end

  #solo se usa para el movimiento de la pc
  def jugada_max
      movimiento.max_by{|x| x.nivel} #Devuelve el objeto de enumeración que da el valor máximo
  end

  def nivel_final
    if juego_terminado
      return 0 if gato
     #  ganar == "X" ? 1 : -1
       if ganar=="X"
          ganar=1
        else
          ganar=-1
        end
      end
      
    #if juego_terminado
    #  return 0 if gato
    #      ganar == "X" ? 1 : -1
    #end
  end

  def juego_terminado
    if ganar or gato #si alguien gano o el juego  se empato
      return true
    end
   # ganar or gato
  end

  def gato # si la longitud de las casillas del tablero una vez quitadas las nulas es 9 y si no hay ganador entonces no es empate
    #compact crea una copia del arreglo sin las posiciones nulas
    if tablero.compact.length==9 and ganar.nil? #solo nil.nil? es true 
   # tablero.compact.length == 9 && ganar.nil?
        return true
    else
        return false
    end
  end
 # si el jugador es la pc entonces siempre escoje el movimiento maximo 
  def nivel_no_final
    #collect llama al bloque una vez por cada elemento del mismo y crea un nuevo arreglo que contiene los valores retornados
    #nivels = movimiento.collect{ |valor_pos| valor_pos.nivel }
    
    if jugador_actual == 'O'
      movimiento.collect{ |valor_pos| valor_pos.nivel }.min
      #nivels.max
    else
      movimiento.collect{ |valor_pos| valor_pos.nivel }.max
    end
  end  

  def ganar
    #arreglo que contine las combinaciones de posiciones en las cuales se gana
    @ganar = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7], [2,5,8],[0,4,8],[6,4,2]]
    #se llama al bloque una vez por cada elemento del mismo y crea un nuevo arreglo que contiene los valores retornados
    @ganar.collect{|c|
      ( tablero[c[0]] == tablero[c[1]] &&
        tablero[c[1]] == tablero[c[2]] &&
        tablero[c[0]] ) || nil}.compact.last
      #se eliminan los  nulos del arreglo y se toma el primer elemento ya sea X o O
      #compara si l posicion 0 es igual a la 1 y asi en cada linea si es X o O en todas 
      #y toma el primer o ultimo da lo mismoelemento ya sea X o O
  end
end

class GameTree
  def generate(ini)
    initial_valor_pos = Etapa_actual.new(ini, Array.new(9))
    generate_movimiento(initial_valor_pos)
    initial_valor_pos
  end

  def generate_movimiento(valor_pos)
    next_player = (valor_pos.jugador_actual == 'X' ? 'O' : 'X')
    valor_pos.tablero.each_with_index do |player_at_position, position|
      if !player_at_position
      #unless player_at_position
        next_tablero = valor_pos.tablero.dup
        next_tablero[position] = valor_pos.jugador_actual

        next_valor_pos = Etapa_actual.new(next_player, next_tablero)
        valor_pos.movimiento << next_valor_pos
        generate_movimiento(next_valor_pos)
      end
    end
  end
end

class Gato
  def initialize
    puts "Modo de Juego: \n Pulsa 1 para iniciar primero \n Pulsa otra tecla para que la maquina inicie"
      @ans = gets#obtiene lo que el usuario teclea
      if @ans.downcase.strip == '1'
         @valor_pos = @initial_valor_pos = GameTree.new.generate("O")
         pinta_tablero
      else
         @valor_pos = @initial_valor_pos = GameTree.new.generate("X")
      end
  end

  def siguiente
    if @valor_pos.juego_terminado
      describe_final_valor_pos
      puts "¿Quieres Intentar nuevamente? s/n"
      aux1 = gets#obtiene lo que el usuario teclea
      if aux1.downcase.strip == 's'
        @valor_pos = @initial_valor_pos
         if(@ans.strip == '1')
          pinta_tablero
          movimiento_jugador
          siguiente
         else 
          siguiente
         end
      else
        exit
      end
    end
    
    if @valor_pos.jugador_actual == 'X'
      puts "\n"
      @valor_pos = @valor_pos.jugada_max
      puts "TURNO DE LA PC"
      pinta_tablero
      siguiente
      else 
      movimiento_jugador
      pinta_tablero
      puts ""
      siguiente
    end
  end
  
  def pinta_tablero
    linea = ""
    (0..8).each{|c|
      linea.concat(" #{@valor_pos.tablero[c] || " "} ")
      if(c==2 or c==5)
         linea.concat("\n --  --  --\n")
      elsif c==8
         linea.concat("")
      else
         linea.concat("|")
      end        
    }
    puts linea
  end

  def movimiento_jugador
    puts "INTRODUCE LA POSICION DEL TABLERO A JUGAR O PRESIONA x SI QUIERES SALIR"
    posicion = gets#obtiene el numero introducido por el jugador
    if (posicion.strip=='0' or posicion.strip=='1' or posicion.strip=='2' or posicion.strip=='3' or posicion.strip=='4' or posicion.strip=='5' or  posicion.strip=='6' or posicion.strip=='7' or posicion.strip=='8')
          tirar = @valor_pos.movimiento.find{ |c| c.tablero[posicion.to_i] == 'O' }
          if tirar
            @valor_pos = tirar 
          else
            puts "NO PUEDES TIRAR EN ESTA POSICION"
            movimiento_jugador
          end
    elsif (posicion.downcase.strip=='x')
            exit
    else  
      puts "Elige una opcion valida"
      movimiento_jugador
    end
  end

  def describe_final_valor_pos
    if @valor_pos.gato
      puts "GATO"
    elsif @valor_pos.ganar == 'X'
      puts "PERDISTE :("
    else
      puts "GANASTE :) WII!!!!!"
    end
  end
end

juego=Gato.new()
def juego.sale_del_juego
    puts "Presiona x si quieres abandonar el juego"
    salir= gets
    if salir.downcase.strip == 'x'
        exit
    end
end
#juego.sale_del_juego
juego.siguiente

#Gato.new.siguiente


#puts Etapa_actual.new('X', Array.new(9)).jugada_max.class

