library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity horizontal_blanking is
 Generic (
      fp_duration    : integer := 17;
      hsync_duration : integer := 56;  
      bp_duration    : integer := 56
     );
 Port (
     rst      : in  STD_LOGIC;
     clk      : in  STD_LOGIC;
     enable_i : in  STD_LOGIC;
     sync_o   : out STD_LOGIC;
     done_o   : out STD_LOGIC 
     );
end horizontal_blanking;

architecture Behavioral of horizontal_blanking is
   type state_type is (st_idle,st_fp,st_hsync,st_bp);
   type register_type is record
      counter  : std_logic_vector(7 downto 0);
      done     : std_logic;
      sync     : std_logic;
      enable   : std_logic;
      state   : state_type;
   end record;
   signal r,rin : register_type;
   begin

      sync_o <= r.sync ;
      done_o <= r.done ;

      comb: process (enable_i,r)
         variable v : register_type;
      begin
         v := r;  
         case r.state is 
            when st_idle =>
               if enable_i = '1' then
                  v.state   := st_fp;
                  v.sync    := '1';
                  v.enable  := '1';
               else
                  v.state   := r.state;
                  v.sync    := r.sync;
                  v.enable  := r.enable;
               end if;
               v.done := '0';

            when st_fp =>
               if conv_integer(r.counter) = fp_duration then
                  v.state   := st_hsync;
                  v.sync    := '0';
                  v.counter := (others=>'0');
               else
                  v.state   := r.state;
                  v.sync    := r.sync;
                  v.counter := r.counter + '1';
               end if;

            when st_hsync =>
               if conv_integer(r.counter) = hsync_duration then
                  v.state   := st_bp;
                  v.sync    := '1';
                  v.counter := (others=>'0');
               else 
                  v.state   := r.state;
                  v.sync    := r.sync;
                  v.counter := r.counter + '1';
               end if; 

            when st_bp =>
               if conv_integer(r.counter) = bp_duration then
                  v.state   := st_idle;
                  v.sync    := '0';
                  v.enable  := '0';
                  v.counter := (others=>'0');
               else
                  v.state   := r.state;
                  v.sync    := r.sync;
                  v.counter := r.counter + '1';
                  v.enable  := r.enable;
               end if;

               if conv_integer(r.counter) >= bp_duration - 2 then
                  v.done    := '1';
                else
                  v.done := r.done;
                end if;

            when others =>
               v := r;

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
      elsif rising_edge(clk) then
         r <= rin;
      end if;
   end process;
end architecture;
