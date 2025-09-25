# comiksan

A new Flutter project.

## Getting Started
things i learned
why not directly frontend and 3rd party api because of
1,hard to catch errors and failures
2,rate limiting
3,risk of api keys being exposed
4,more control

why redis ?
because if the frontend requests each and every requests on server problem like overload,errors occur so instead we will use redis with this  we will have comicks stored on it so instead of calling each and every time ,redis will act as a layer between the server and the frontend and redis will have it ready when we need it,this also decreases the time it takes to get the result from the server directly.
or
cache frequent requests for speed


why controller?
as the name indicated it helps to control, more like request handler,for eg we have this chapter controller and its main function will be to handle the chapter,if new chapter are available add this.