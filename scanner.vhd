--Scanner 
---------------------------------------------------------------------------
--     Scanner.vhd                                                         --
--      Uttaresh Mehta and Lauren White                                  --
--      Spring 2013                                                      --
--                                                                       --
---------------------------------------------------------------------------  
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

entity  scanner is 
	port ( ps2Data,fall_edge,rst: in std_logic;
		   left_reg, right_reg : out std_logic_vector(7 downto 0);
		   ready	: out std_logic);
	end scanner;
	
	
architecture Behavioral of scanner is 
signal data_bridge : std_logic_vector(21 downto 0);

begin
	scanning: process( fall_edge, rst, ps2Data)	 --This is a 22 bit shift register
	begin
		
		if (rst = '1') then
			data_bridge <= "0000000000000000000000";	
		elsif (rising_edge(fall_edge)) then		
			data_bridge <= ps2Data & data_bridge (21 downto 1); --Concatenating the previous data with the incoming bit from the keyboard
		end if;	
	end process;
	left_reg <= data_bridge(19 downto 12); --Stores make code
	right_reg <= data_bridge(8 downto 1);  --Stores Break code
end Behavioral;
	
	