/*

The example script calculates "structural simiarity" of graph nodes.  jaccard similarity (otherwise known as the structural similarity) of nodes in a network graph.
Input: graph file 
$: cat graph.tsv
A C
B C
C D
C E
E F
C H
G H
C G
D E
A G
B G

Output: Jaccard similarity of each pair of nodes 
*/

edges     = LOAD '/tmp/graph.tsv'  USING PigStorage(' ') AS (v1:chararray, v2:chararray);

A = GROUP edges by v1; 

-- node, bag{neighbors} 
B = FOREACH A GENERATE group, $1.v2 as neighbors;
/*
DESCRIBE B;
B: {group: chararray,neighbors: {(v2: chararray)}}
*/
-- C is a duplicate of B, so Pig won't be confused for the CROSS statement. 
C = FOREACH B GENERATE *;

-- generate pairs of nodes with their bags of neighboring nodes 
BCcross = CROSS B, C;
/*
DESCRIBE BCcross;
BCcross: {B::group: chararray,B::neighbors: {(v2: chararray)},C::group: chararray,C::neighbors: {(v2: chararray)}}
*/

BC = FOREACH BCcross GENERATE $0 AS Bv1, $1 AS Bneig, $2 AS Cv2, $3 AS Cneig;
/*
(A,{(C),(G)},A,{(C),(G)})
(A,{(C),(G)},B,{(C),(G)})
(A,{(C),(G)},C,{(D),(E),(H),(G)})
(A,{(C),(G)},D,{(E)})
(A,{(C),(G)},E,{(F)})
(A,{(C),(G)},G,{(H)})
(B,{(C),(G)},A,{(C),(G)})
(B,{(C),(G)},B,{(C),(G)})
(B,{(C),(G)},C,{(D),(E),(H),(G)})
...
*/

-- Now, we want to get the Intersect of the neighbor sets 
-- DataFu provides set operation UDFs
 

