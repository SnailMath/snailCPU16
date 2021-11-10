#include <stdio.h>
#include <stdint.h>

#define RAM_SIZE 0x4000
#define PROG_START 0x100

#define MODE_BIG_ENDIAN 0
#define MODE_LITTLE_ENDIAN 1

#define ADDR_PC    0
#define ADDR_PORT  1
#define ADDR_DEBUG 2
#define ADDR_QUIT  3

#define CMD_MOV   0
#define CMD_ADD   1
#define CMD_XOR   2
#define CMD_AND   3
#define CMD_SHIFT 4
#define CMD_MIF   5

//#define DEBUG

class cpu {
public:
	uint16_t pc = PROG_START;
	bool flag = false;
	bool running = true;
	uint16_t memory[RAM_SIZE];
	void init(){
		//clear the ram
		for(int i=0;i<0x4000;i++)
			memory[i]=0;
		//The start address
		pc = PROG_START; 
		flag = false;
	}
	void load(const char* filename, int mode){ //load from a file, mode 0 big endian, mode 1 little endian
		FILE *fp = fopen(filename, "rb");
		long index = PROG_START;
		while(true){
			int c1 = fgetc(fp); //first byte
			int c2 = fgetc(fp); //second byte
			if(c2==EOF)break; //break if the file is over
			if(index==RAM_SIZE){printf("The file ist too big, the ram is full.\n");break;}//error if the ram is full and ther is still stuff from the file...
			if(mode==MODE_LITTLE_ENDIAN){//little endian
				memory[index] = c2<<8 | c1 ;
			}else{//big endian
				memory[index] = c1<<8 | c2 ;
			}
#ifdef DEBUG
			printf("%04X ", memory[index]);
#endif
			index++;
		}
#ifdef DEBUG
		print("\n");
#endif
		printf("Loaded %d words from 0x%04X to 0x%04X\n", (int)index-PROG_START, PROG_START, (unsigned int)index);
		fclose(fp);
	}
	void write(uint16_t address, uint16_t val){
#ifdef DEBUG
		printf("Write %d to %04X\n", val, address);
#endif
		memory[address] = val;
		if(address<0x100)switch(address){
			case ADDR_PC: //change the pc (aka jump)
				pc = val;
			break;
			case ADDR_PORT: //output to the port(aka screen)
				putc(val, stdout);
			break;
			case ADDR_DEBUG: //output to the port(aka screen)
				printf("%04X\n", val);
			break;
			case ADDR_QUIT: //stop the execution
				running = false;
			break;
		}	
		
	}
	uint16_t read(uint16_t address){
		if(address<0x100)switch(address){
			case ADDR_PC:
#ifdef DEBUG
				printf("Read %d from %04X\n", pc, address);
#endif
				return pc;
			case ADDR_PORT:
				
			break;
		}	
#ifdef DEBUG
		printf("Read %d from %04X\n", memory[address], address);
#endif
		return(memory[address]);
	}
	void step(int s){
		for(;s>0&&running;s--){
#ifdef DEBUG
		printf("Executing 1 cycle...\n");
#endif
		//#xecute a single step of the cpu
			uint16_t cmd  = memory[pc++];
			uint16_t arg1 = memory[pc++];
			uint16_t arg2 = memory[pc++];
#ifdef DEBUG
			printf("cmd=%02X arg1=%02X arg2=%02X\n", cmd, arg1, arg2);
#endif
			switch(cmd){
				case CMD_MOV :
					write(arg2, read(arg1));
				break;
				case CMD_ADD :
				{
					long result = read(arg1) + read(arg2);
					write(arg2, result);
					flag = result & (1<<16); //The carry bit is saved as the flag
				}
				break;
				case CMD_XOR :
					write(arg2, read(arg1) ^ read(arg2));
				break;
				case CMD_AND :
					write(arg2, read(arg1) & read(arg2));
				break;
				case CMD_SHIFT :
				{
					int16_t  shift = read(arg1);
					uint16_t value = read(arg2);
					if(shift>0){
						flag = value & (1<<15); //The leftmost bit is saved as the flag
						write(arg2, value << shift);
					}else{
						flag = value & (1<< 0); //The rightmost bit is saved as the flag
						write(arg2, value >> -shift);
					}
				}
				break;
				case CMD_MIF :
					if(flag)
						write(arg2, read(arg1));
				break;
			}
#ifdef DEBUG
		printf("Executed 1 cycle.\n");
#endif
		}
	}
	
};





int main(int argc, char* argv[]){
	if(argc!=2){
		printf("Usage: %s program.bin\n(The program is loaded from 0x%04X onwards.)", argv[0], PROG_START); return(-1);
	}
	cpu c; //Create cpu object
	c.init(); //Init the cpu
	c.load(argv[1],MODE_BIG_ENDIAN);
	while(c.running){
		c.step(1);
	}
    
}
