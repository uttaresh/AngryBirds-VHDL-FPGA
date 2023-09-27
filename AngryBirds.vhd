-- Top Level Entity for Angry Birds Final Project
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AngryBirds is
	Port ( sw : in std_logic_vector(2 downto 0);
           Clk : in std_logic;
           ps2clk : in std_logic;
           ps2data: in std_logic;
           Reset : in std_logic;
           Red   : out std_logic_vector(9 downto 0);
           Green : out std_logic_vector(9 downto 0);
           Blue  : out std_logic_vector(9 downto 0);
           VGA_clk : out std_logic; 
           sync : out std_logic;
           blank : out std_logic;
           vs : out std_logic;
           hs : out std_logic;
           
           AhexL : out std_logic_vector (6 downto 0); -- LEFT REG
		   AhexU : out std_logic_vector (6 downto 0);
		   
		   BhexL : out std_logic_vector (6 downto 0); -- RIGHT REG
		   BhexU : out std_logic_vector (6 downto 0);
		   
		   angleSign : out std_logic;
		   ChexL : out std_logic_vector (6 downto 0); -- ANGLE
		   ChexU : out std_logic_vector (6 downto 0);
		   
		   DhexL : out std_logic_vector (6 downto 0); -- ANGLE
		   DhexU : out std_logic_vector (6 downto 0) );
end AngryBirds;

architecture Behavioral of AngryBirds is

-- control is the state machine and its signals
component control is 
	Port (  -- Inputs
		Reset    : in std_logic;
		Space    : in std_logic;
		vsSig      : in std_logic;
		hit      : in std_logic;
		miss     : in std_logic;
		
		which_pigs : in std_logic_vector(2 downto 0);
		
		-- Outputs
		C, M     : out std_logic);
end component control;

-- check_piggies checks if all piggies are dead
component check_piggies is
	Port(	Clk       : in std_logic;
			pig_count : in std_logic_vector(1 downto 0);

			done : out std_logic);
end component check_piggies;

-- "bird" component from Lab 8 does our bird's projectile motion
component Progressor is
    Port ( M, up, Reset : in std_logic;
           init_vel_x, init_vel_y : in std_logic_vector (8 downto 0);
           frame_clk : in std_logic;
           
           	Pig1X, Pig1Y, Pig1_Size : in std_logic_vector(9 downto 0);
			Pig2X, Pig2Y, Pig2_Size : in std_logic_vector(9 downto 0);
			Pig3X, Pig3Y, Pig3_Size : in std_logic_vector(9 downto 0);
           
           
           hit, miss : out std_logic;
           which_pigs : out std_logic_vector(2 downto 0);
           BirdX : out std_logic_vector(9 downto 0);
           BirdY : out std_logic_vector(9 downto 0);
           BirdS : out std_logic_vector(9 downto 0));
end component;

-- Slingshot is the entity that is used to calculate the launch trajectory
component Slingshot is
	Port (	C, Slingshot_Clk, Reset : in std_logic;
			w, s : in std_logic;	-- w for increase, s for decrease angle
			a, d : in std_logic;	-- d for increase velocity, a for decrease velocity
			
			vel : out std_logic_vector(2 downto 0);
			vel_x, vel_y	: out std_logic_vector(8 downto 0);
			angle: out std_logic_vector (7 downto 0) ); -- The launch angle and velocity, as displayed on 7-seg LEDs
end component Slingshot;

component ThirtyHz is 
	port(	RST		:	in std_logic;
			CLK_IN	:	in std_logic;
			ThirtyHz_clk:	out std_logic	);
end component ThirtyHz;

component vga_controller is
    Port ( clk : in std_logic;
           reset : in std_logic;
           hs : out std_logic;
           vs : out std_logic;
           pixel_clk : out std_logic;
           blank : out std_logic;
           sync : out std_logic;
           DrawX : out std_logic_vector(9 downto 0);
           DrawY : out std_logic_vector(9 downto 0));
end component;


component Color_Mapper is
    Port ( BirdX : in std_logic_vector(9 downto 0);
           BirdY : in std_logic_vector(9 downto 0);
                     
			Pig1X, Pig1Y, Pig1_Size : in std_logic_vector(9 downto 0);
			Pig2X, Pig2Y, Pig2_Size : in std_logic_vector(9 downto 0);
			Pig3X, Pig3Y, Pig3_Size : in std_logic_vector(9 downto 0);
			
			which_pigs : in std_logic_vector(2 downto 0);
           
           DrawX : in std_logic_vector(9 downto 0);
           DrawY : in std_logic_vector(9 downto 0);
           Bird_size : in std_logic_vector(9 downto 0);
           Red   : out std_logic_vector(9 downto 0);
           Green : out std_logic_vector(9 downto 0);
           Blue  : out std_logic_vector(9 downto 0));
end component;


-- Buffer for ps2 clock that tells us when we're on the falling edge
component synch is
	Port (	slowClk, ps2Clk	:	in std_logic;
			fall_edge		:	out std_logic );
end component;

-- Slows down clock to what we need to input into synch buffer
component clkSlower is
	port(	RST		:	in std_logic;
			CLK_IN	:	in std_logic;
			slow_clk:	out std_logic);
end component;

-- Reads incoming bits from keyboard and outputs in vector format
component scanner is 
	port ( ps2Data,fall_edge,rst: in std_logic;
		   left_reg, right_reg : out std_logic_vector(7 downto 0);
		   ready : out std_logic);
end component;

-- Detects the vectors from the scanner and decides what direction is on
component direction_detector is 
	Port ( left_reg, right_reg: in std_logic_vector(7 downto 0);
		   vsClk : in std_logic;
		   w,a,s,d,space : out std_logic) ;
end component;

-- Used for debugging
component HexDriver is
	Port(Input: in std_logic_vector (3 downto 0);
		 Output: out std_logic_vector (6 downto 0));
end component HexDriver;


-- A hell lotta signals!
signal Reset_h, ready_sig : std_logic;
signal DrawXSig, DrawYSig, BirdXSig, BirdYSig, BirdSSig : std_logic_vector(9 downto 0);
signal left_reg_sig, right_reg_sig, angle_sig, abs_angle : std_logic_vector(7 downto 0);
signal w_sig,a_sig,s_sig,d_sig, space_sig : std_logic;
signal vsSig,ThirtyHz_sig, hsSig, slow_clock_sig, slowest_clock_sig, fall_edge_sig, slower_clock_sig : std_logic;


-- Signals from Progressor
signal hit_sig, miss_sig : std_logic;
signal which_pigs_sig : std_logic_vector(2 downto 0);

signal vel_sig : std_logic_vector(2 downto 0);
signal init_vel_x_sig, init_vel_y_sig : std_logic_vector(8 downto 0);

-- Control signals:
signal M_sig, C_sig, Rst_sig : std_logic;

-- Pig attribute signals with their values:
signal Pig1X_sig : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(590,10);
signal Pig1Y_sig : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(370,10);
signal Pig1_Size_sig : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(10,10);

signal Pig2X_sig : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(520,10);
signal Pig2Y_sig : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(400,10);
signal Pig2_Size_sig : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(20,10);

signal Pig3X_sig : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(410,10);
signal Pig3Y_sig : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(440,10);
signal Pig3_Size_sig : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(35,10);

begin

Reset_h <= not Reset; -- The push buttons are active low

-- Port map everything... uhhhhh....

control_instance : control
	Port map(  -- Inputs
				Reset => Reset_h,
				Space => space_sig,
				vsSig => vsSig,
				hit => hit_sig,
				miss => miss_sig,
				
				which_pigs => which_pigs_sig,
				
				-- Outputs
				C => C_sig,
				M  => M_sig);

clkSlower_instance : clkSlower
	Port map(RST=>'0',
			 CLK_IN=>Clk,
			 slow_clk=>slow_clock_sig);

slowerClkSlower_instance : clkSlower
	Port map(RST=>'0',
			 CLK_IN=>ThirtyHz_sig,
			 slow_clk=>slower_clock_sig);
			 
slowestClkSlower_instance : clkSlower
	Port map(RST=>'0',
			 CLK_IN=>slower_clock_sig,
			 slow_clk=>slowest_clock_sig);

ThirtyHz_instance : ThirtyHz 
	port map(	RST=>'0',
				CLK_IN=>Clk,
				ThirtyHz_clk=>ThirtyHz_sig	);

synch_instance : synch
	Port map(slowClk=>slow_clock_sig,
			 ps2Clk=>ps2clk,
			 fall_edge=>fall_edge_sig);

scanner_instance : scanner
	Port map(ps2Data=>ps2data,
			 fall_edge=>fall_edge_sig,
			 rst=>Reset_h,
			 left_reg=>left_reg_sig,
			 right_reg=>right_reg_sig,
			 ready=>ready_sig );

direction_detector_instance : direction_detector
	Port map(	left_reg=>left_reg_sig,
				right_reg=>right_reg_sig,
			 			
			 	vsClk=>vsSig,		
			 			 
				w=>w_sig,
				a=>a_sig,
				s=>s_sig,
				d=>d_sig,
				space=>space_sig);

Slingshot_instance: Slingshot
	Port map (	Slingshot_Clk => slowest_clock_sig,
				Reset => Reset_h,
				C => C_sig,
				w => w_sig,
				s => s_sig,
				a => a_sig,
				d => d_sig,	
				vel => vel_sig,	
				vel_x => init_vel_x_sig,
				vel_y => init_vel_y_sig,	
				angle => angle_sig ); 
angleSign <= angle_sig(7);



Progressor_instance : Progressor
	Port map (	M => M_sig,
				up => angle_sig(7),
				init_vel_x => init_vel_x_sig,
				init_vel_y => init_vel_y_sig, 
				 
				Reset => Reset_h,
				frame_clk => vsSig, -- 60 Hz clock signal

				Pig1X => Pig1X_sig,
				Pig1Y => Pig1Y_sig,
				Pig1_Size => Pig1_Size_sig,
				Pig2X => Pig2X_sig, 
				Pig2Y => Pig2Y_sig, 
				Pig2_Size => Pig2_Size_sig,
				Pig3X => Pig3X_sig, 
				Pig3Y => Pig3Y_sig, 
				Pig3_Size => Pig3_size_sig,


				hit =>hit_sig,
				miss =>miss_sig,
				which_pigs=>which_pigs_sig,

				BirdX => BirdXSig,  --   (This is why we registered it in the vga controller!)
				BirdY => BirdYSig,
				BirdS => BirdSSig);


vgaSync_instance : vga_controller
   Port map(clk => clk,
            reset => Reset_h,
            hs => hsSig,
            vs => vsSig,
            pixel_clk => VGA_clk,
            blank => blank,
            sync => sync,
            DrawX => DrawXSig,
            DrawY => DrawYSig);

Color_instance : Color_Mapper
   Port Map(BirdX => BirdXSig,
            BirdY => BirdYSig,
            
                      
			Pig1X => Pig1X_sig,
			Pig1Y => Pig1Y_sig,
			Pig1_Size => Pig1_Size_sig,
			Pig2X => Pig2X_sig, 
			Pig2Y => Pig2Y_sig, 
			Pig2_Size => Pig2_Size_sig,
			Pig3X => Pig3X_sig, 
			Pig3Y => Pig3Y_sig, 
			Pig3_Size => Pig3_size_sig,
            
            which_pigs => which_pigs_sig,
            
            DrawX => DrawXSig,
            DrawY => DrawYSig,
            Bird_size => BirdSSig,
            Red => Red,
            Green => Green,
            Blue => Blue);

vs <= vsSig;
hs <= hsSig;

	get_abs_angle : process (angle_sig)
	begin
		if (angle_sig(7)='1') then
			abs_angle <= not(angle_sig) + '1';
		else
			abs_angle <= angle_sig;
		end if;
	end process get_abs_angle;

HexAL : HexDriver
	Port map(Input => left_reg_sig(3 downto 0),
			 Output => AhexL);

HexAU : HexDriver
	port map(Input => left_reg_sig (7 downto 4),
			 Output => AhexU);
			 
HexBL : HexDriver
	Port map(Input => right_reg_sig(3 downto 0),
			 Output => BhexL);

HexBU : HexDriver
	port map(Input => right_reg_sig (7 downto 4),
			 Output => BhexU);

HexCL : HexDriver
	Port map(Input => abs_angle(3 downto 0),
			 Output => ChexL);

HexCU : HexDriver
	port map(Input => abs_angle (7 downto 4),
			 Output => ChexU);

HexDL : HexDriver
	Port map(Input => x"0",
			 Output => DhexL);

HexDU : HexDriver
	port map(Input => ('0' & vel_sig),
			 Output => DhexU);
			 
end Behavioral;

