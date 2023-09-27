-- D-Flip-flops
---------------------------------------------------------------------------
--      dff.vhd                                                         --
--      Uttaresh Mehta and Lauren White                                  --
--      Spring 2013                                                      --
--                                                                       --
---------------------------------------------------------------------------                                                                      --


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

-- Entity declaration:
entity ourDFF is
	port(	D, clk	: in std_logic;
			Q 		: out std_logic);
end ourDFF;
architecture behavior of ourDFF is
begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			Q <= D;
		end if;
	end process;
end behavior;