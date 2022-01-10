library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL ;
use IEEE.STD_LOGIC_UNSIGNED.ALL ;

entity horizontal_blanking_tb is

end horizontal_blanking_tb;

architecture Behavioral of horizontal_blanking_tb is

   signal clk_i : std_logic;
   signal rst_i : std_logic;
   signal en_i  : std_logic;
   signal done  : std_logic;
   constant clk_period : time := 82.538 ns;
begin
uut: entity work.horizontal_blanking
   generic map(
      fp_duration    => 17,  
      hsync_duration => 56,
      bp_duration    => 56      
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


