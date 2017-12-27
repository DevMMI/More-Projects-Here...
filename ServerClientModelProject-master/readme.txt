Mohamed Mohamud 
Chris Grenfell 

What this accomplishes: Server runs idle until the client begins requesting image files relative to how it is configured. If the client.config file specifies a specific directory, the client will download images of that filetype. If the config file is missing any imagetype (jpg, png, tiff), then the client must enter the index of the specific file that it is requesting. The default server config will download images of type jpg. 

You must also change the client.config and server.config port numbers to be both valid (with the server computer) and equivalent.
You may change the chunk_size field to reflect in what size byte chunks you would like to transfer images.
the usage for the .c files is ./server server.config and ./client client.config
If you do not specify an image type in the image type field of the client.config file, it will default to active mode
where is will request index numbers from the transmitted csv file.

