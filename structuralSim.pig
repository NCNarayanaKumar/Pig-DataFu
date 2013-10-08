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
B = FOREACH A GENERATE group, $1.v2 as neighbors, COUNT(edges) AS cnt_v1;
/*
DESCRIBE B;
B: {group: chararray,neighbors: {(v2: chararray)},cnt_v1: long}
*/
-- C is a duplicate of B, so Pig won't be confused for the CROSS statement. 
C = FOREACH B GENERATE *;

-- generate pairs of nodes with their bags of neighboring nodes 
BCcross = CROSS B, C;
/*
DESCRIBE BCcross;
BCcross: {B::group: chararray,B::neighbors: {(v2: chararray)},B::cnt_v1: long,C::group: chararray,C::neighbors: {(v2: chararray)},C::cnt_v1: long}
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
-- Pig itself has COUNT(DIFF(A,B) 
/*
|Intersect(A,B)| = 0.5* (|A|+|B| - |DIFF(A,B)|)
Jaccard(A,B) = |Intersect(A,B)/(|A|+|B|-|Intersect(A,B)|) = (|A|+|B| - |DIFF(A,B)|)/(|A|+|B| + |DIFF(A,B)|)
*/
BC = FOREACH BCcross GENERATE $0 AS Bv1, $3 AS Cv2, COUNT(DIFF($1,$4)) AS cnt_diff, $2 AS cnt_v1, $5 AS cnt_v2;

/*
 ----------------------------------------------------------------------------------------------------------
| BC     | Bv1:chararray     | Cv2:chararray     | cnt_diff:long     | cnt_v1:long     | cnt_v2:long     |
----------------------------------------------------------------------------------------------------------
|        | A                 | A                 | 0                 | 2               | 2               |
----------------------------------------------------------------------------------------------------------
*/

X = FOREACH BC GENERATE Bv1, Cv2, cnt_v1, cnt_v2, (((double)cnt_v1+cnt_v2-cnt_diff)/((double)cnt_v1+cnt_v2+cnt_diff)) AS sim;

/*
(A,A,2,2,1.0)
(A,B,2,2,1.0)
(A,C,2,4,0.2)
(A,D,2,1,0.0)
(A,E,2,1,0.0)
*/
