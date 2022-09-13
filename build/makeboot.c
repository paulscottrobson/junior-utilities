//
//		Convert a binary file into a bootable file.
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//
//		Space for expansion
//
static unsigned char image[65536];
//
//		The kernal image - this is downloaded and converted in the makefile. Trying to minimise files required !
//
static unsigned char _KernalImage[16384] = {
	#include "kernel.h"
};

int main(int argc,char *argv[]) {
	if (argc != 3)
		exit(fprintf(stderr,"makeboot <binary> <bootable>\n"));
	//
	//		Erase image
	//
	for (int i = 0;i < sizeof(image);i++) image[i] = 0;
	//
	//		Signature of basic02 at $8000
	//
	image[0] = 0x4C;											// This is JMP $8010
	image[1] = 0x10;
	image[2] = 0x80;
	strcpy(image+4,"BASIC02");									// This identifies it as BASIC02 (conning the Kernal)
	//
	//		Append the binary
	//
	printf("Trying to load %s\n",argv[1]);
	FILE *f = fopen(argv[1],"rb");
	if (f == NULL) exit(fprintf(stderr,"failed"));
	int count = fread(image+0x10,1,0x4000,f); 					// Read into $8010
	printf("Read %d bytes.\n",count);
	fclose(f);
	//
	//		Copy the Kernal in.
	//
	for (int i = 0;i < 16384;i++) {
		image[i+16384] = _KernalImage[i];
	}
	//
	//		Write the final image out.
	//
	f = fopen(argv[2],"wb");
	fwrite(image,1,0x8000,f);
	fclose(f);
	printf("Written image %s\n",argv[2]);
	return 0;
}