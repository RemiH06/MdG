Dado el grafo completar la matriz (el grafo estaba en el proyector)

| #   | A   | B   | C   | D   | E   | F   | G   |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A   | 0   | 0   | 1   | 0   | 0   | 1   | 0   |
| B   | 0   | 0   | 1   | 1   | 0   | 0   | 0   |
| C   | 0   | 0   | 0   | 0   | 0   | 1   | 0   |
| D   | 1   | 0   | 0   | 0   | 1   | 1   | 0   |
| E   | 0   | 1   | 0   | 1   | 0   | 0   | 0   |
| F   | 0   | 0   | 0   | 1   | 0   | 0   | 0   |
| G   | 0   | 1   | 0   | 0   | 1   | 0   | 0   |

Lista de adyacencia
A [C,F]
B [C,D]
C [F]
D [A,E,F]
E [B,D]
F [D]
G [B,E]

Pares ordenados
(A,C), (A,F), (B,C), (B,D), (C,F), (D,A), (D,E), (D,F), (E,B), (E,D), (F,D), (G,B), (G,E)

Un grafo homogéneo es uno en el que todos los nodos y relaciones son de los mismos tipos