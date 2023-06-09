all: mine_sweeper.asm
	yasm -felf64 -o mine_sweeper.o mine_sweeper.asm 
	ld -o mine_sweeper mine_sweeper.o ./libs/prng.o ./libs/print.o ./libs/read_key.o

prng.o: PRNG.asm
	yasm -felf64 -o ./libs/prng.o ./libs/PRNG.o

print.o: print.asm
	yasm -felf64 -o ./libs/print.o ./libs/print.o
	
read_key.o: read_key.o
	yasm -felf64 -o ./libs/read_key.o ./libs/read_key.o


	
