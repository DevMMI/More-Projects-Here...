Mohamed Mohamud 4699696
Chris Grenfell 4909076

To run our code you must first place the c file, makefile, and configuration files in their own directories.
You must change the server configuration file to reflect the image input directory in the dir field.
You must also change the client.config and server.config port numbers to be both valid (with the server computer) and equivalent.
You may change the chunk_size field to reflect in what size byte chunks you would like to transfer images.
the usage for the c files is ./server server.config and ./client client.config
If you do not specify an image type in the image type field of the client.config file, it will default to active mode
where is will request index numbers from the transmitted csv file.
