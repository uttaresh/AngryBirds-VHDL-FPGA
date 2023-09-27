-- ThirtyHz is used to provide a 30Hz clock, i.e. half the monitor rate
---------------------------------------------------------------------------
--      ThirtyHz.vhd                                                    --
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
entity ThirtyHz is 
	port(	RST		:	in std_logic;
			CLK_IN	:	in std_logic;
			ThirtyHz_clk:	out std_logic	);

end ThirtyHz;

-- Define behavior:
architecture behavior of ThirtyHz is

signal tmp_ctr	:	std_logic;
signal tmp_clk	:	std_logic;

begin

	next_count:process(RST,CLK_IN,tmp_ctr) -- this is a counter that counts to  512. 
	                                       --The 512th bit is used as a signal.This is necessary to divide the system clock
	begin
		if (RST = '1') then
			tmp_clk <= '0';
		elsif (rising_edge(CLK_IN)) then
			tmp_ctr <= not(tmp_ctr);  
		end if;
	end process;
	ThirtyHz_clk <= tmp_ctr;
end behavior;
