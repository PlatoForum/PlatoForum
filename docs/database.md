## Models ##

The models being used are as follow:

* Users: contains the comments that have been created by a particular user; his/her likes and dislikes

* Topics: contains a set of comments; the comments are subdivided into different disjoint stances by clustering algorithm

* Stances: each comment is assigned to a particular stance determined by clustering algorithm

* Comments: a comment may be subdivided into premise, body, and conclusion, each consists of one or several points; a comment may be liked or disliked by other users; a comment and be responded by other comments

* Likes: a relationship between a user and a comment

* Dislikes: a relationship between a user and a comment which is opposite of like

* Updates: a user's action that corresponds to an update of the graph structure; it can be a new comment, a comment that responds to another comment, a like, or a dislike

