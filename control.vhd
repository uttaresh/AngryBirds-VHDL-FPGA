-- control is the entity that controls the state of the system, and
-- generates the required control signals for the different portions
-- of the AngryBirds system.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity control is 
	Port (  -- Inputs
		Reset    : in std_logic;
		Space    : in std_logic;
		vsSig      : in std_logic;
		hit      : in std_logic;
		miss     : in std_logic;
		
		which_pigs : in std_logic_vector(2 downto 0);
		
		-- Outputs
		C, M     : out std_logic );
end control;

--------------- Control Unit Behavior------------------
architecture Behavioral of control is

--Declare States
type cntrl_state is ( calculate, motion, check_piggies, win);

--Signal Declaration
signal state, next_state: cntrl_state;

begin
	control_reg : process ( Reset, vsSig)
	begin
	   if ( Reset = '1') then 
			state <= calculate;
       elsif (rising_edge(vsSig)) then
           state <= next_state;
       end if;
    end process;

	get_next_state : process ( Space, hit, miss, state)
	begin
	   case state is 
			when calculate => 
				if (Space = '1') then
				   next_state <= motion;
				else
					next_state <= calculate;
				end if;
			when motion =>
				if (hit ='1' ) then
				   next_state <= check_piggies;
				elsif ( miss ='1') then 
				   next_state <= calculate;
				else 
				   next_state <= motion; 
				end if;
			when check_piggies =>
				if (which_pigs = "111") then
					next_state <= win ;
				else
					next_state <= calculate;
				end if;
			when win =>
				if (Space = '1') then
					next_state <= calculate;
				else
					next_state <= win;
				end if;
		end case;
	end process;

	get_cntrl_out : process (hit, state)
	begin
	   case state is 
			when calculate =>
				C	<= '1';
				M	<= '0';
			when motion =>
				C	<= '0';
				M   <= '1';
			when check_piggies =>
				C	<= '1';
				M   <= '0';
			when win =>
				C	<= '0';
				M   <= '0';
		end case;
    end process;
end Behavioral;