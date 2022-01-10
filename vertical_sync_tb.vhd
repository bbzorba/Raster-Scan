library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL ;
use IEEE.STD_LOGIC_UNSIGNED.ALL ;

entity vertical_sync_tb is

end vertical_sync_tb;

architecture Behavioral of vertical_sync_tb is

   signal clk_i            : std_logic;
   signal rst_i            : std_logic;
   signal en_i             : std_logic;
   signal done             : std_logic;
   constant clk_period : time := 82.538 ns;
begin
uut: entity work.vertical_sync
   generic map(
         vsync_duration   => 327,
         vserr_duration   => 56,
         period_duration  => 5
         ) 
   port map (
         rst      => rst_i,
         clk      => clk_i,
         enable_i => en_i ,
         sync_o   => open ,
         done_o   => done 
         );

rst_process : process
   begin
      rst_i <= '1';
      en_i  <= '0'; 
      wait until rising_edge(clk_i); wait for 1 ns;
      rst_i <='0';
      en_i  <= '0';
      wait until rising_edge(clk_i); wait for 1 ns;
      rst_i <='0';
      en_i  <= '1';
      wait until rising_edge(clk_i); wait for 1 ns;
      rst_i <='0';
      en_i  <= '0';
      wait for 1 ms;
end process;

clk_process : process
   begin
       clk_i <= '0';
       wait for clk_period/2;
       clk_i <= '1';
       wait for clk_period/2; 
end process;

end Behavioral;
