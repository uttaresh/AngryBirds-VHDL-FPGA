-- clkSlower is used to divide the original clock
-- by 512 to slow it down
---------------------------------------------------------------------------
--      clkSlower.vhd                                                         --
--      Uttaresh Mehta and Lauren White                                  --
--      Spring 2013                                                      --
--                                                                       --
---------------------------------------------------------------------------  

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

-- Declare entity:
entity clkSlower is 
	port(	RST		:	in std_logic;
			CLK_IN	:	in std_logic;
			slow_clk:	out std_logic	);
end clkSlower;

-- Define behavior:
architecture behavior of clkSlower is

signal tmp_ctr	:	std_logic_vector(9 downto 0);
signal tmp_clk	:	std_logic;

begin

	next_count:process(RST,CLK_IN,tmp_ctr) -- this is a counter that counts to  512. 
	                                       --The 512th bit is used as a signal.This is necessary to divide the system clock
	begin
		if (RST = '1') then
			tmp_clk <= '0';
		elsif (rising_edge(CLK_IN)) then
			tmp_ctr <= tmp_ctr + '1';   
		end if;
	end process;
	slow_clk <= tmp_ctr(9); --Take the 10th bit, 2^9 and use it as signal for the slower clock

end behavior;
