library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity counter_2proc is
 Port (
     rst      : in  STD_LOGIC;
     clk      : in  STD_LOGIC;
     enable_i : in  STD_LOGIC;
     sync_o   : out STD_LOGIC  
     );
end counter_2proc;

architecture Behavioral of counter_2proc is
   type register_type is record
      counter  : std_logic_vector(7 downto 0);
      done     : std_logic;
      sync     : std_logic;
      enable   : std_logic;
   end record;
   signal r,rin : register_type;

   begin
      sync_o <= r.sync ;
      comb: process (enable_i,r)
         variable v : register_type;
      begin
         v := r;
         if r.enable = '1' then 
            v.counter := r.counter+1; 
         else
            v.counter := (others=>'0'); 
         end if;

         if conv_integer(r.counter) = 133 then
            v.done := '1';
         else
            v.done := '0';
         end if;

         if (conv_integer(r.counter) >= 1) and (conv_integer(r.counter) < 19) then
            v.sync := '1';
         elsif (conv_integer(r.counter) >= 76) and (conv_integer(r.counter) < 133) then
            v.sync := '1';
         else 
            v.sync := '0';
         end if;
         if (conv_integer(r.counter) >= 134) then
            v.enable := '0';
         elsif enable_i = '1' and (conv_integer(r.counter) < 134) then
            v.enable := '1';
         else
            v.enable := r.enable;
         end if;
        rin <= v;
      end process;

   seq: process(clk,rst)
   begin
      if rst='1' then
         r.counter <= (others=>'0');
         r.done    <= '0';
         r.sync    <= '0';
         r.enable  <= '0';
      elsif rising_edge(clk) then
         r <= rin;
      end if;
   end process;
end architecture;
