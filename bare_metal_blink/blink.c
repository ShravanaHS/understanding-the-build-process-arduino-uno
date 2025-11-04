#include <stdint.h>

#define builtled *((volatile uint8_t*) 0x25)  // 0x25 is PORTB
#define portb *((volatile uint8_t*) 0x24)   // 0x24 is DDRB

int main(void) {
    
    portb = 32; // sets PB5 (bit 5) as an output

    while(1) {
        
        builtled = 32; // Set LED ON
        
        for (long i = 0; i <= 100000; i++) {
            builtled = 32; // Keep setting it ON
        }
        
        builtled = 0; // Set LED OFF
      
        for (long i = 0; i <= 1000000; i++) {
            builtled = 0; // Keep setting it OFF
        }
    }
}