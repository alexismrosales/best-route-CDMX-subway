%=====================================================================================
%   Ejercicio elaborado por Jorge Alexis Márquez Rosales
%   Fecha de entrega: 20 de octubre de 2022.
%
%   EXAMEN #3. Grafo del sistema Metro de la CdMx.
%   Representar el mapa completo del sistema Metro y programar los
%   predicados necesarios para informar a un usuario sobre la mejor
%   y peor ruta (en tiempo) entre dos estaciones cualesquiera...
%   
%   Predicados relevantes:
%   rutaH(+Inicio,+Destino,-Rutas,-Tiempos,-LineasMetro).
%   ruta_corta(+Rutas,+Tiempo,-MejorRuta,-MejorTiempo).
%   ruta_larga(+Rutas,+Tiempo,-PeorRuta,-PeorTiempo).
%   desplegar_ruta_mejor(+Estación1,+Estación2,-MejorRuta,-MejorTiempo,-LineasMejorRutas).
%   desplegar_ruta_peor(+Estación1,+Estación2,-PeorRuta,-PeorTiempo,-LineasPeorRutas).
%   mostrar_estaciones(+MejorRuta,+LineasMejorRuta,+MejorTiempo,+1).
%=====================================================================================
use_module(datos).
%grado/2. El predicado se encarga de encontrar o grado de la arista (estación) dada
grado(Estación,Grado) :- findall(1,sigue(Estación,_,_),L),
                            length(L,Grado).
%navegar/6. Se recorre por diferentes caminos para encontrar las rutas posibles, calculand
%calculando el tiempo del tramo solamente, sin tiempos iniciales ni finales.
navegar(A,A,_,[A],[A],_,0).
navegar(A,B,_,[A,B],[Línea],Sumatoria,Sumatoria1):- A \== B, sigue(A,B,Línea),
                                                        valor_parámetro(tiempo_tramo, X),
                                                            grado(B,Y),
                                                                Sumatoria1 is Sumatoria + X * Y .
                                                                                                              
navegar(A,B,Mem,[A|Ruta],[Línea|Líneas],Sumatoria,Peso):- A \== B,  sigue(A,Z,Línea),
                                                            Z \== B,
                                                                \+member(Z,Mem),
                                                                    valor_parámetro(tiempo_tramo, X),
                                                                        grado(Z,Y),
                                                                            Dato is X * Y,
                                                                                Sumatoria1 is Sumatoria + Dato,
                                                                                    navegar(Z,B,[Z|Mem],Ruta,Líneas,Sumatoria1,Peso).

%limpiar_duplicados/2. Dada una lista se buscan los elementos que aún no estén en la lista
%y se devuelve una nueva lista sin elementos repetidos.
limpiar_duplicados([], []).
limpiar_duplicados([A|B], R) :-  member(A, B), !,
                                    limpiar_duplicados(B, R).
limpiar_duplicados([A|B], [A|R]) :- limpiar_duplicados(B, R).

%transbordos/2. Devuelve el tiempo que gasta en transbordos.
transbordos(Lista,Peso):- length(Lista,X), 
                            X1 is X-1,
                                valor_parámetro(tiempo_transbordo, Y),
                                     Peso is Y * X1.
%rutaH/5. Para sumar todos los tiempos que son necesarios para los diferentes recorridos se 
%llama al predicado navegar/6 y se suman todos los tiempos restantes para obtener el tiempo
%final.
rutaH(Inicio,Destino,Ruta,Tiempo,Lineas):- navegar(Inicio,Destino,[],Ruta,Lineas,0,Tiempo_Normal),
                                            limpiar_duplicados(Lineas,Lineas_depuradas),
                                                transbordos(Lineas_depuradas,Tiempo_transbordo),
                                                    valor_parámetro(tiempo_inicial, Tiempo_inicial),
                                                        valor_parámetro(tiempo_final,Tiempo_final),
                                                            Tiempo is Tiempo_Normal + Tiempo_transbordo + Tiempo_inicial + Tiempo_final.

%ruta_corta/4. Dados los diferentes tiempos se busca el menor y se devuelve el mejor tiempo así como su ruta.
ruta_corta([R],_,R,0).
ruta_corta(Rutas,TiempoRutas,R,RT):- min_list(TiempoRutas,RT),
                                        nth1(Posición,TiempoRutas,RT),
                                            nth1(Posición,Rutas,R).
%mejor_ruta/4. Obteniendo la ruta de menor tiempo se devuelve la mejor ruta y el tiempo que pasa expresado con
%horas y minutos.
mejor_ruta(Estación1,Estación2,Mejor,Tiempo):- findall(Mejor,rutaH(Estación1,Estación2,Mejor,TiempoX,_),Rutas),
                                                    findall(TiempoX,rutaH(Estación1,Estación2,Mejor,TiempoX,_),TiempoRutas),
                                                        ruta_corta(Rutas,TiempoRutas,Mejor,TiempoX),
                                                            Horas is floor(TiempoX/60),  
                                                                Minutos is TiempoX mod 60,
                                                                    string_concat(Horas, ' horas con ', String1), 
                                                                        string_concat(Minutos,' minutos',String2),
                                                                            string_concat(String1,String2,Tiempo).
%ruta_larga/4. Dados los diferentes tiempos se busca el mayor y se devuelve el peor tiempo así como su ruta.                               
ruta_larga([R],_,R,0).
ruta_larga(Rutas,TiempoRutas,R,RT):- max_list(TiempoRutas,RT),
                                        nth1(Posición,TiempoRutas,RT),
                                            nth1(Posición,Rutas,R).
%peor_ruta/4. Obteniendo la ruta de menor tiempo se devuelve la mejor ruta y el tiempo que pasa expresado con
%horas y minutos.                     
peor_ruta(Estación1,Estación2,Peor,Tiempo):- findall(Peor,rutaH(Estación1,Estación2,Peor,TiempoX,_),Rutas),
                                                    findall(TiempoX,rutaH(Estación1,Estación2,Peor,TiempoX,_),TiempoRutas),
                                                        ruta_larga(Rutas,TiempoRutas,Peor,TiempoX),
                                                            Horas is floor(TiempoX/60),
                                                              Minutos is TiempoX mod 60,
                                                                string_concat(Horas, ' horas con ', String1), 
                                                                    string_concat(Minutos,' minutos',String2),
                                                                        string_concat(String1,String2,Tiempo).
%ruta_desplegar_mejor/6. Con el mejor tiempo se busca la mejor ruta, en conjunto de las lineas por las que pasa
%para poder mostrarlas.
ruta_desplegar_mejor([R],_,_,R,0,[]).
ruta_desplegar_mejor(Rutas,TiempoRutas,Lineas,R,RT,[_,RL]):- min_list(TiempoRutas,RT),
                                                                nth1(Posición,TiempoRutas,RT),
                                                                    nth1(Posición,Rutas,R),
                                                                        nth1(Posición,Lineas,RL).
%ruta_desplegar_peor/6. Con el peor tiempo se busca la peor ruta, en conjunto de las lineas por las que pasa 
%para poder mostrarlas.
ruta_desplegar_peor([R],_,_,R,0,[]).
ruta_desplegar_peor(Rutas,TiempoRutas,Lineas,R,RT,[_,RL]):- max_list(TiempoRutas,RT),
                                                                nth1(Posición,TiempoRutas,RT),
                                                                    nth1(Posición,Rutas,R),
                                                                        nth1(Posición,Lineas,RL).
%Desplegar_ruta_mejor/5. Se busca la mejor ruta y su mejor tiempo en conjunto de las lineas por las que pasa.
desplegar_ruta_mejor(Estación1,Estación2,Mejor,Tiempo,Lineas):- findall(Mejor,rutaH(Estación1,Estación2,Mejor,TiempoX,LineasX),Rutas),
                                                                    findall(TiempoX,rutaH(Estación1,Estación2,Mejor,TiempoX,LineasX),TiempoRutas),
                                                                        findall(LineasX,rutaH(Estación1,Estación2,Mejor,Tiempo,LineasX),LineasRuta),
                                                                            ruta_desplegar_mejor(Rutas,TiempoRutas,LineasRuta,Mejor,TiempoX,LineasX),
                                                                                Horas is floor(TiempoX/60),
                                                                                    Minutos is TiempoX mod 60,
                                                                                        string_concat(Horas, ' horas con ', String1), 
                                                                                            string_concat(Minutos,' minutos',String2),
                                                                                                string_concat(String1,String2,Tiempo),
                                                                                                    flatten(LineasX,Lineas).
%Desplegar_ruta_peor/5. Se busca la peor ruta y su peor tiempo en conjunto de las lineas por las que pasa.
desplegar_ruta_peor(Estación1,Estación2,Peor,Tiempo,Lineas):- findall(Peor,rutaH(Estación1,Estación2,Peor,TiempoX,LineasX),Rutas),
                                                                    findall(TiempoX,rutaH(Estación1,Estación2,Peor,TiempoX,LineasX),TiempoRutas),
                                                                        findall(LineasX,rutaH(Estación1,Estación2,Peor,Tiempo,LineasX),LineasRuta),
                                                                            ruta_desplegar_peor(Rutas,TiempoRutas,LineasRuta,Peor,TiempoX,LineasX),
                                                                                Horas is floor(TiempoX/60),
                                                                                    Minutos is TiempoX mod 60,
                                                                                      string_concat(Horas, ' horas con ', String1), 
                                                                                          string_concat(Minutos,' minutos',String2),
                                                                                              string_concat(String1,String2,Tiempo),
                                                                                                flatten(LineasX,Lineas).
%concatenar/2. Dado un tiempo en minutos devuelve una cadena concatenada con la palabra minutos
concatenar(Tiempo,TR):- string_concat(Tiempo,' minutos',TR).

%mostrar_estaciones/4. Se vuelve a calcular el tiempo de las demas estaciones para imprimirlo en consola
mostrar_estaciones([Primera_estación|B],Lineas,Tiempo,Contador):- length(Lineas,Tamaño), Tamaño > Contador,
                                                                    write('Tramo '), write(Contador), write(':'),
                                                                        write(Primera_estación), write(','),
                                                                            nth1(1,B,Segunda_estación), write(Segunda_estación),
                                                                                grado(Segunda_estación,Grado),valor_parámetro(tiempo_tramo, Tiempo_tramo),
                                                                                    CNT is Contador-1,nth0(CNT,Lineas,Linea_anterior),nth0(Contador,Lineas,Linea_actual),
                                                                                        valor_parámetro(tiempo_transbordo, Tiempo_transbordo),
                                                                                            ((Linea_anterior \== Linea_actual, Contador > 1)-> Es_transbordo is Tiempo_transbordo; Es_transbordo is 0),
                                                                                                Tiempo_tramo_completo is Grado * Tiempo_tramo + Es_transbordo,
                                                                                                    write(', '),write(Tiempo_tramo_completo),write(' minutos'), nl,
                                                                                                        Contador1 is Contador+1,
                                                                                                            mostrar_estaciones(B,Lineas,Tiempo,Contador1), !.
mostrar_estaciones(_,Lineas,_,Contador):- length(Lineas,Tamaño), Tamaño > Contador. %Funciona para poder devolver verdadero

%reporte_viaje/2. Despliega toda la ruta que se tiene que hacer por estaciones junto al tiempo que toma cada uno.
reporte_viaje(Estación1,Estación2):- desplegar_ruta_mejor(Estación1,Estación2,Mejor,Tiempo,Lineas),
                                        write('Reporte total de viaje: '),write(Tiempo),nl,
                                            write('Inicio: '), nth1(1,Mejor,Inicio), write(Inicio),write(', '),
                                                valor_parámetro(tiempo_inicial, TInicial), concatenar(TInicial,TI), write(TI),nl,
                                                    mostrar_estaciones(Mejor,Lineas,Tiempo,1),
                                                        write('Final: '), length(Mejor,Último),nth1(Último,Mejor,Final), write(Final),write(', '),
                                                            valor_parámetro(tiempo_final, TFinal), concatenar(TFinal,TF), write(TF),nl.
