--Direction Detector :D

---------------------------------------------------------------------------
--      DirectionDetector.vhd                                           --
--      Lauren White and Uttaresh Mehta                                 --
--      Spring 2013                                                      --
--                                                                       --
---------------------------------------------------------------------------  
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity direction_detector is
	port ( left_reg,right_reg: in std_logic_vector (7 downto 0);
		   vsClk : in std_logic;
		   w,a,s,d, space : out std_logic);
end direction_detector;

architecture behavioral of direction_detector is
	begin
		translation : process (right_reg,left_reg)
	begin
		if (right_reg = x"F0") then  --Here, we have to check to see if a key has been released. If it has, we want to bounce!
			w<='0';
			a<='0';
			s<='0';
			d<='0';
			space<='0';			

		-- If the right reg is not reading a F0 , then we are free to move. The contents of the
		--register is checked here to see which direction to move in
		else        
	        case left_reg is
			when x"1D"=> -- W: x1D
				w<='1';
				a<='0';
				s<='0';
				d<='0';
				space<='0';			
			when x"1C"=> -- A: x1C
				w<='0';
				a<='1';
				s<='0';
				d<='0';
				space<='0';			
			when x"1B"=> -- S: x1B
				w<='0';
				a<='0';
				s<='1';
				d<='0';
				space<='0';			
			when x"23"=> -- D: x23
				w<='0';
				a<='0';
				s<='0';
				d<='1';
				space<='0';			
			when x"29" => ---Space: x29
				w<='0';
				a<='0';
				s<='0';
				d<='0';
				space<='1';
			when others=> -- If neither of the four make codes are pressed, we do not want the keyboard to respond
				w<='0';
				a<='0';
				s<='0';
				d<='0';
				space<='0';			
			end case;
	
		end if;
end process;
end behavioral;					