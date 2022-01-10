library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity vertical_sync is
 Generic  (
     vsync_duration   : integer := 328;
     vserr_duration   : integer := 56;
     period_duration  : integer := 5   -- max 7
     );
 Port (
     rst      : in  STD_LOGIC;
     clk      : in  STD_LOGIC;
     enable_i : in  STD_LOGIC;
     sync_o   : out STD_LOGIC;
     done_o   : out STD_LOGIC
     );
end vertical_sync;

architecture Behavioral of vertical_sync is
   type state_type is (st_idle,st_vsync,st_vserr);
   type register_type is record
      counter  : std_logic_vector(8 downto 0);
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
                  v.state   := st_vsync;
                  v.sync    := '0';
                  v.enable  := '1';
               else
                  v.state   := r.state;
                  v.sync    := r.sync;
                  v.enable  := '0';
               end if;
             v.done := '0';

            when st_vsync =>
               if conv_integer(r.counter) = vsync_duration then
                  v.state   := st_vserr;
                  v.period  := r.period;
                  v.sync    := '1';
                  v.counter := (others=> '0');
                  v.done    := r.done;
                  v.enable  := r.enable;
               else
                  v.state   := r.state;
                  v.period  := r.period;
                  v.sync    := r.sync;
                  v.counter := r.counter + 1;
                  v.done    := r.done;
                  v.enable  := r.enable;
               end if; 

            when st_vserr =>
               if conv_integer(r.counter) = vserr_duration then
                  if conv_integer(r.period) = period_duration then
                     v.state   := st_idle;
                     v.period  := (others=> '0');
                     v.sync    := '0';
                     v.counter := (others=> '0');
                     v.done    := '1';
                     v.enable  := '0';
                  else
                     v.state   := st_vsync;
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
               r.period <= (others=>'0');
            elsif rising_edge(clk) then
               r <= rin;
            end if;
      end process;
end architecture;

