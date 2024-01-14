# best-route-mexico-city-subway
Using a model of Mexico City subway represented on a graph, the algorithm search the best route to go from a metro station to other not only taking the shortest route it also takes time parameters.

Map:


![Mexico city subway](https://metro-cdmx.com.mx/wp-content/uploads/2022/04/plano-metro-cdmx.png)
## Best route
The best route is calculated taking the following time parameters:
- initial time
- travel time
- transfer time
- final time


Notice that the implementation is very basic and it can take above 3-5 minutes searching the best route.


The predicate to be called to get the best route is reporte_viaje/2, by example:
```
reporte_viaje(balderas,olivos).
```
Where balderas is the intial subway station and olivos is the goal.


## Worst route
The worst route can be obtained, using peor_ruta/4 predicate, for example:
```
peor_ruta(balderas,olivos,W,T).
```
Where W is a list with the worst route and T is the time of that route.
