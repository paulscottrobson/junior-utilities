#
#		Convert C256jr.bin to an includable data file.
#
import os
src = [x for x in open("build"+os.sep+"C256jr.bin","rb").read(-1)]
h = open("build"+os.sep+"kernel.h","w")
h.write(",".join([str(x) for x in src]))
h.close()