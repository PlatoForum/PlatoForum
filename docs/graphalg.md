# Graph Algorithm #
In order to classify comments into clusters, we need to define a *metric* or a
concept of distance between any two comments. By modeling each of _comments_ in
the database as a node in a complete graph, we naturally use the weight of an
edge between any two nodes to represent the associated similarity, an opposite
but equivalent concept to distance. The weight of a edge between two irrelevant
nodes is set to 0 in the beginning.  If a node is created to reply to another
node, the edge weight of these two nodes is initialized to 1. The weight of an
edge is updated under the following two conditions:

* the weight is increased by 1 if the corresponding nodes are both _like_ by a user.
* the weight is decreased by 1 if a user _like_ one node, but _dislike_ the other.

After building the adjacency matrix of nodes, we are ready to cluster nodes. A
naive approach is to use a modified version of _k-means_  algorithm. In usual,
at the end of each iteration in k-means algorithm, the centroid of each cluster
is updated by the average _position_ of all nodes in a cluster. However, in our
case, a node does not have coordinate, and the described method can not be
applied.  Instead, for each cluster, we find the node which has largest overall
edge weight sum, and use such node as the new centroid. The pseudo code of the
modified k-means is shown in the next section.

## Pseudo Code ##

    1. randomly pick up a set of initial centroids
    2. infinite loop:
    3.    put each node into the cluster in which the centroid has largest edge weight with the node. 
    4.    for each cluster, find a node with maximum edge weight sum as the new centroid.

## Caveat ##

The number of clusters is fixed. Need to find a way to solve this issue.
