library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity equalizing_pulse is
 Generic  (
     eq_high_duration : integer  := 357 ;
     eq_low_duration  : integer  := 27 ;
     period_duration  : integer  := 5
     );
 Port (
     rst      : in  STD_LOGIC;
     clk      : in  STD_LOGIC;
     enable_i : in  STD_LOGIC;
     slc_i    : in  STD_LOGIC;
     sync_o   : out STD_LOGIC;
     done_o   : out STD_LOGIC
     );
end equalizing_pulse;

architecture Behavioral of equalizing_pulse is
   type state_type is (st_idle,st_eq_low,st_eq_high,st_no_data);
   type register_type is record
      counter  : std_logic_vector(10 downto 0);
      period   : std_logic_vector(2 downto 0);
      done     : std_logic;
      sync     : std_logic;
      enable   : std_logic;
      state    : state_type;
   end record;
   signal r,rin : register_type;
   begin
      sync_o <= r.sync;
      done_o <= r.done;

      comb: process(enable_i,r)
         variable v : register_type;

      begin
            v := r;

            case r.state is

               when st_idle =>
                  if enable_i = '1' then
                     v.state  := st_eq_low;
                     v.sync   := '0';
                     v.enable := '1';
                  else
                     v.state  := r.state;
                     v.sync   := r.sync;
                     v.enable := '0';
                  end if;
                  v.done := '0';

               when st_eq_low =>
                  if conv_integer(r.counter) = eq_low_duration then
                     if slc_i = '1' and conv_integer(r.period) = period_duration then
                        v.state   := st_no_data;
                        v.period  := (others=> '0');
                        v.sync    := '1';
                        v.counter := (others=> '0');
                        v.done    := '0';
                        v.enable  := r.enable;
                     elsif slc_i = '0' and conv_integer(r.period) = period_duration then
                        v.state   := st_eq_high;
                        v.period  := r.period;
                        v.sync    := '1';
                        v.counter := (others=> '0');
                        v.done    := r.done;
                        v.enable  := r.enable;
                     else
                        v.state   := st_eq_high;
                        v.period  := r.period;      
                        v.sync    := '1';
                        v.counter := (others=> '0');
                        v.done    := r.done;        
                        v.enable  := r.enable;      
                     end if;
                  else
                     v.state   := r.state;
                     v.period  := r.period;
                     v.sync    := r.sync;
                     v.counter := r.counter + 1;
                     v.done    := r.done;
                     v.enable  := r.enable;
                  end if; 

               when st_eq_high =>
                  if conv_integer(r.counter) = eq_high_duration then        
                     if conv_integer(r.period) = period_duration and slc_i = '0' then
                        v.state   := st_idle;        
                        v.period  := (others=> '0'); 
                        v.sync    := '0';            
                        v.counter := (others=> '0'); 
                        v.done    := '1';
                        v.enable  := '0';
                     elsif conv_integer(r.period) = period_duration and slc_i = '1' then
                        v.state   := st_eq_low;   
                        v.period  := r.period;
                        v.sync    := '0';         
                        v.counter := (others=> '0'); 
                        v.done    := r.done;   
                        v.enable  := r.enable; 
                     else
                        v.state   := st_eq_low;    
                        v.period  := r.period + 1; 
                        v.sync    := '0';          
                        v.counter := (others=> '0');
                        v.done    := r.done;       
                        v.enable  := r.enable;     
                     end if;                   
                  else                      
                     v.state   := r.state;  
                     v.period  := r.period; 
                     v.sync    := r.sync;   
                     v.counter := r.counter + 1;     
                     v.done    := r.done;            
                     v.enable  := r.enable;          
                  end if;        

               when st_no_data =>
                  if conv_integer(r.counter) = 741 then 
                     v.state   := st_idle;    
                     v.period  := (others=> '0');
                     v.sync    := '0';           
                     v.counter := (others=> '0');
                     v.done    := '1';           
                     v.enable  := '0';           
                  else
                     v.state   := r.state;
                     v.period  := r.period;
                     v.sync    := '1';
                     v.counter := r.counter + 1;
                     v.done    := r.done;
                     v.enable  := r.enable;
                  end if;   
            end case;  

          rin <= v;
         end process;

         seq: process(clk,rst)
            begin
               if rst = '1' then
                  r.state   <= st_idle;
                  r.counter <= (others=>'0');
                  r.done    <= '0';
                  r.sync    <= '0';
                  r.enable  <= '0';
                  r.period  <= (others=>'0');
               elsif rising_edge(clk) then
                  r <= rin;
               end if;
         end process;
end architecture;

