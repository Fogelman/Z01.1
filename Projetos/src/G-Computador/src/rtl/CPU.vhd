-- Elementos de Sistemas
-- developed by Luciano Soares
-- file: CPU.vhd
-- date: 4/4/2017

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity CPU is
  port(
    clock:       in  STD_LOGIC;                        -- sinal de clock para CPU
    reset:       in  STD_LOGIC;                        -- reinicia toda a CPU (inclusive o Program Counter)
    inM:         in  STD_LOGIC_VECTOR(15 downto 0);    -- dados lidos da memória RAM
    instruction: in  STD_LOGIC_VECTOR(17 downto 0);    -- instrução (dados) vindos da memória ROM
    outM:        out STD_LOGIC_VECTOR(15 downto 0);    -- dados para gravar na memória RAM
    writeM:      out STD_LOGIC;                        -- faz a memória RAM gravar dados da entrada
    addressM:    out STD_LOGIC_VECTOR(14 downto 0);    -- envia endereço para a memória RAM
    pcout:       out STD_LOGIC_VECTOR(14 downto 0)     -- endereço para ser enviado a memória ROM
    );
end entity;

architecture arch of CPU is

  component Mux16 is
    port (
      a:   in  STD_LOGIC_VECTOR(15 downto 0);
      b:   in  STD_LOGIC_VECTOR(15 downto 0);
      sel: in  STD_LOGIC;
      q:   out STD_LOGIC_VECTOR(15 downto 0));
  end component;

  component ALU is
    port (
      x,y:   in STD_LOGIC_VECTOR(15 downto 0);
      zx:    in STD_LOGIC;
      nx:    in STD_LOGIC;
      zy:    in STD_LOGIC;
      ny:    in STD_LOGIC;
      f:     in STD_LOGIC;
      no:    in STD_LOGIC;
      zr:    out STD_LOGIC;
      ng:    out STD_LOGIC;
      saida: out STD_LOGIC_VECTOR(15 downto 0));
  end component;

  component Register16 is
    port(
      clock:   in std_logic;
      input:   in STD_LOGIC_VECTOR(15 downto 0);
      load:    in std_logic;
      output: out STD_LOGIC_VECTOR(15 downto 0));
  end component;

  component PC is
    port(
      clock     : in  STD_LOGIC;
      increment : in  STD_LOGIC;
      load      : in  STD_LOGIC;
      reset     : in  STD_LOGIC;
      input     : in  STD_LOGIC_VECTOR(15 downto 0);
      output    : out STD_LOGIC_VECTOR(15 downto 0));
  end component;

  component ControlUnit is
    port(
      instruction                 : in STD_LOGIC_VECTOR(17 downto 0);
      zr,ng                       : in STD_LOGIC;
      muxALUI_A                   : out STD_LOGIC;
      muxAM                       : out STD_LOGIC;
      muxAMD_ALU                  : out STD_LOGIC;
      muxSD_ALU                   : out STD_LOGIC;                     -- mux que seleciona entre reg. S
      zx, nx, zy, ny, f, no       : out STD_LOGIC;
      loadA, loadD, loadS, loadM, loadPC : out STD_LOGIC);
  end component;

  -- Controles
  signal c_muxALUI_A  : STD_LOGIC;
  signal c_muxAM      : STD_LOGIC;
  signal c_muxAMD_ALU : STD_LOGIC;
  signal c_muxSD_ALU  : STD_LOGIC;
  signal c_zx         : STD_LOGIC;
  signal c_nx         : STD_LOGIC;
  signal c_zy         : STD_LOGIC;
  signal c_ny         : STD_LOGIC;
  signal c_f          : STD_LOGIC;
  signal c_no         : STD_LOGIC;
  signal c_loadA      : STD_LOGIC;
  signal c_loadD      : STD_LOGIC;
  signal c_loadS      : STD_LOGIC;
  signal c_loadPC     : STD_LOGIC;
  signal c_zr         : std_logic := '0';
  signal c_ng         : std_logic := '0';

  -- Sinais de dados
  signal s_muxALUI_Aout   : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
  signal s_muxAM_out      : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
  signal s_muxAMD_ALUout  : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
  signal s_muxSDout       : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
  signal s_regAout        : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
  signal s_regDout        : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
  signal s_regSout        : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
  signal s_ALUout         : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');
  signal s_pcout          : STD_LOGIC_VECTOR(15 downto 0):=(others=>'0');

  signal instruction_slice          : STD_LOGIC_VECTOR(17 downto 0):=(others=>'0');

begin
  muxALUI_port: Mux16 PORT MAP(
              a => s_ALUout,
              b => instruction(15 downto 0),
              sel => c_muxALUI_A,
              q => s_muxALUI_Aout
              );

  muxAM_port: Mux16 PORT MAP(
              a => s_regAout,
              b => inM,
              sel => c_muxAM,
              q =>s_muxAM_out
              );

  muxAMD_ALU_port: Mux16 PORT MAP(
              a => s_regDout,
              b => s_muxAM_out,
              sel => c_muxAMD_ALU,
              q => s_muxAMD_ALUout
              );

  muxSD_ALU_port: Mux16 PORT MAP(
              a => s_regSout,
              b => s_regDout,
              sel => c_muxSD_ALU,
              q => s_muxSDout
              );

  RgA: Register16 PORT MAP (
              clock => clock,
              input => s_muxALUI_Aout,
              load =>c_loadA,
              output => s_regAout
              );

  RgS: Register16 PORT MAP (
              clock => clock,
              input =>s_ALUout,
              load =>c_loadS,
              output => s_regSout
              );

  RgD: Register16 PORT MAP (
              clock => clock,
              input => s_ALUout,
              load => c_loadD,
              output => s_regDout
              );

  ALU_port: ALU PORT MAP(
              x => s_muxSDout,
              y =>s_muxAMD_ALUout,
              zx => c_zx,
              nx => c_nx,
              zy => c_zy,
              ny => c_ny,
              f => c_f,
              no => c_no,
              zr => c_zr,
              ng => c_ng,
              saida => s_ALUout
              );

  PC_port: PC PORT MAP(
              clock => clock,
              increment => '1',
              load => c_loadPC,
              reset => reset,
              input => s_regAout,
              output => s_pcout
              );

  CU: ControlUnit PORT MAP (
              instruction => instruction,
              zr => c_zr,
              ng => c_ng,
              muxALUI_A => c_muxALUI_A,
              muxAM => c_muxAM,
              muxAMD_ALU => c_muxAMD_ALU,
              muxSD_ALU => c_muxSD_ALU,
              zx => c_zx,
              nx => c_nx,
              zy => c_zy,
              ny => c_ny,
              f => c_f,
              no => c_no,
              loadA => c_loadA,
              loadD => c_loadD,
              loadS => c_loadS,
              loadM => writeM,
              loadPC => c_loadPC
              );

            addressM <= s_regAout(14 downto 0);
            pcout <= s_pcout(14 downto 0);
  outM <= s_ALUout;

end architecture;
