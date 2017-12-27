all: image_manager.o


image_manager.o: image_manager.c image_manager.h
	cc -o image_manager image_manager.c -lpthread

clean:
	rm -f image_manager
