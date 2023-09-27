-- Clock synch
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

entity synch is
	Port (	slowClk, ps2Clk	:	in std_logic;
			fall_edge		:	out std_logic );
end synch;

architecture Behavioral of synch is
-- D-Flip-flop component declaration:
component DFF is
	port(	D, clk	: in std_logic;
			Q 		: out std_logic);
end component;
signal q1,q2 : std_logic;
begin
	flip : DFF port map ( D=>ps2Clk, clk=>slowClk, Q=>q1);
	flop : DFF port map ( D=>q1, clk=>slowClk, Q=>q2);
	
	get_psclk:process(q1,q2)
	begin
		if (q2='1' and q1 ='0') then
			
				fall_edge <= '1';
			
		else
			fall_edge <= '0';
		end if;
	end process;
end Behavioral;