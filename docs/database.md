## Models ##

The models being used are as follow:

* Users: contains the comments that have been created by a particular user; his/her likes and dislikes; his/her aliases associated with particular topics
    * Login credentials (omniauth)
    * Proxies: user's alias associated with a particular topic; all the authored comments under the topic are organized under proxy
        * Approvals/Disapprovals: links to the comments liked/disliked by the user

* Topics: contains a set of comments; the comments are subdivided into different disjoint stances by clustering algorithm
    * Stances: each comment is assigned to a particular stance determined by clustering algorithm

* Comments: a comment may be subdivided into premise, body, and conclusion, each consists of one or several points; a comment may be liked or disliked by other users; a comment and be responded by other comments
    * Likes/Dislikes: links to the users' proxies who approves/dispproves this comment
    * Responses: links to the comments that are authored in response to this comment

* Updates: a user's action that corresponds to an update of the graph structure; it can be a new comment, a comment that responds to another comment, a like, or a dislike

