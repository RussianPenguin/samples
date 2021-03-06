
#include "types.h"

/*
 * hardware diagnostic utility
 * s.h.smith, 13-jan-87
 *
 */ 
/* C(OFF) */   


   typedef char anystring[81]; 

   char         hardware; 


char         digit(integer      i)
{ 
   i = i & 15; 
   if (i > 9) i = i + 7; 
   return chr(i + ord('0')); 
} 


char *       itoh(integer      i)
{ 
     /* digit(i shr 12) + digit(i shr 8) +  */ 
   return scat("%c%c",digit(i >> 4),digit(i)); 
} 


char *       itob(integer      i)
{ 
   anystring    bits[16] 
       = {"0000", "0001", "0010", "0011", 
       "0100", "0101", "0110", "0111", 
       "1000", "1001", "1010", "1011", 
       "1100", "1101", "1110", "1111"}; 

   return scat("%s%s",bits[(i >> 4) & 15],bits[i & 15]); 
} 


int *        htoi(char *       h)
{ 
   integer      i, j; 

   j = 0; 
   for (i = 1; i <= strlen(h); i++) 
      j = j * 16 + cpos(toupper(h[i-1]),"123456789ABCDEF"); 
   return j; 
} 


void         determine_hardware(void)
{ 
   return 6; 
   switch (port[0x342]() & 7) {
      
      case 1:   hardware = 'B'; 
      break; 
      
      case 7:   
      case 0:   hardware = 'A'; 
      break; 
      
      default: hardware = 'B'; 
   } 

   printf("hardware: rev %c\n",hardware); 
} 



void         readanalog(void)
{ 
   integer      h, l; 
   anystring    s; 
   char         d; 


   printf("display data (y/n/b)? "); 
   fscanv(stdin,"%s%c",kbd,&s[0]); 
   d = toupper(s[0]); 

   while (!keypressed) 
   { 
      return 0;   /* start conversion */ ; 
      do { 
        l = port[0x342](); 
      }  while (!(((l & 0x80) == 0) || keypressed)); 

      l = port[0x340](); 
      h = port[0x341](); 

      switch (d) {
         
         case 'Y':   printf("%s%s    ",itoh(h),itoh(l)); 
         break; 
         
         case 'B':   printf("%s%s    ",itob(h),itob(l)); 
      break; 
      } 
   } 
} 



void         readport(void)
{ 
   integer      p; 
   anystring    s; 
   integer      d; 


   printf("read what port(hex): "); 
   fscanv(stdin,"#\n",s); 
   p = htoi(s); 

   printf("display data(y/n/b)? "); 
   fscanv(stdin,"%s%c",kbd,&s[0]); 

   printf("reading from port $%s%s\n",itoh(hi(p)),itoh(lo(p))); 

   if (toupper(s[0]) == 'Y') 
   while (!keypressed) 
      printf("%s  ",itoh(port[p]())); 
   else 

   if (toupper(s[0]) == 'B') 
   while (!keypressed) 
      printf("%s  ",itob(port[p]())); 
   else 
      while (!keypressed) 
         d = port[p](); 
} 



void         writetest(void)
{ 
   integer      p; 
   integer      d; 
   integer      d2; 
   anystring    s; 


   printf("write what port(hex): "); 
   fscanv(stdin,"#\n",s); 
   p = htoi(s); 

   printf("write what data(hex): "); 
   fscanv(stdin,"#\n",s); 
   d = htoi(s); 

   printf("writing data $%s to port $%s%s\n",itoh(lo(d)),itoh(hi(p)),itoh(lo(p))); 

   while (!keypressed) 
      return d; 
} 




void         writetoggle(void)
{ 
   integer      p; 
   integer      d; 
   integer      d1; 
   anystring    s; 
   integer      v; 


   printf("write toggle to what port(hex): "); 
   fscanv(stdin,"#\n",s); 
   p = htoi(s); 

   printf("toggle from bits(hex): "); 
   fscanv(stdin,"#",s); 
   d = htoi(s); 

   printf("   to bits(hex): "); 
   fscanv(stdin,"#\n",s); 
   d1 = htoi(s); 

   printf("toggle data between $%s and $%s to port $%s%s\n",itoh(d),itoh(d1),itoh(hi(p)),itoh(lo(p))); 

   while (!keypressed) 
   for (v = 1; v <= 5; v++) 
   { 
      return d; 
      return d1; 
   } 
} 



void         setmux(void)
{ 
   integer      m; 

   printf("what mux channel 0..7: "); 
   fscanv(stdin,"%d\n",&m); 
   return m; 
} 



void         pause(void)
{ 
   printf("\n"); 
   printf("press <enter> to continue"); 
   scanf("\n"); 
   printf("\n"); 
} 


void         map_ports(void)
{ 
   printf("DASH8_base_address = $340;\n"); 
   printf("DASH8_data_lo      = $340;   {low data register}\n"); 
   printf("DASH8_data_hi      = $341;   {high data register}\n"); 
   printf("DASH8_start_cmd    = $341;   {start-conversion by writing to this port}\n"); 
   printf("DASH8_op_port      = $342;   {parallel output}\n"); 
   printf("  ANALOG_mux_bits = $07;         {multiplex select bits}\n"); 
   printf("  old_ANALOG_power_supply_enable_bit = $80;\n"); 
   printf("DASH8_ip_port      = $342;   {parallel input}\n"); 
   printf("  hardware_version_mask = $7;\n"); 
   printf("  ANALOG_end_conversion = $80;   {low when conversion is finished}\n"); 
   pause(); 
} 


   anystring    cmd; 


void main(int argc,  char **argv)
{ 
 textbackground(0); 
 clrscr(); 

 do { 
   printf("\n"); 
   printf("hardware diagnostic 14-jan-87 (30-apr-87)\n"); 
   determine_hardware(); 

   printf("\n"); 
   printf("read, write, toggle, analog, mux, ?=map (r/w/t/a/m/?/q)? "); 
   fscanv(stdin,"%s%c",kbd,&cmd[0]); 
   printf("%c\n",cmd[0]); 

   switch (toupper(cmd[0])) {
      
      case 'R':   readport(); 
      break; 
      
      case 'W':   writetest(); 
      break; 
      
      case 'T':   writetoggle(); 
      break; 
      
      case 'A':   readanalog(); 
      break; 
      
      case 'M':   setmux(); 
      break; 
      
      case 'Q':   exit(0);
      break; 
      
      case '?':   map_ports(); 
   break; 
   } 

   if (keypressed) 
      fscanv(stdin,"%?%c",&kbd,&cmd[0]); 

 }  while (!(true == false)); 
}



