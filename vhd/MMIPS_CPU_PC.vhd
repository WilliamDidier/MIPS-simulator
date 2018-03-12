library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.MMIPS_pkg.all;

entity MMIPS_CPU_PC is
  Port (
    clk    : in  STD_LOGIC;
    rst    : in  STD_LOGIC;
    cmd    : out MMIPS_PO_cmd;
    status : in MMIPS_PO_status
    );
end MMIPS_CPU_PC;

architecture RTL of MMIPS_CPU_PC is
  type State_type is (S_Error,
                      S_Init,
                      S_Fetch_wait,
                      S_Fetch,
                      S_Decode,
		      S_LUI,
		      S_ORI,
		      S_ADD,
		      S_ADDI,
		      S_SLL,
		      S_AND,
		      S_ANDI,
		      S_NOR,
		      S_OR,
		      S_XOR,
		      S_XORI,
		      S_SUB,
		      S_SRL,
		      S_SRA,
		      S_J,
		      S_JR,
		      S_BEQ,
          	      S_BEQ2,
		      S_JAL,
         	      S_JALR,
		      S_JALR2,
		      S_BNE,
		      S_BLEZ,
		      S_BGEZ,
		      S_BLTZ,
		      S_BGTZ,
		      S_BLTZAL,
		      S_BLTZAL2,
		      S_BGEZAL,
		      S_BGEZAL2,
		      S_LW0,
		      S_LW1,
		      S_LW2,
		      S_LW3,
		      S_SW,
		      S_SW2,
		      S_SLT,
		      S_SLTU,
		      S_SLT2,
		      S_SLT3,
		      S_SLTI,
		      S_SLTIU,
		      S_SLTI2,
		      S_SLTI3
                      );

  signal state_d, state_q : State_type;
begin
  FSM_synchrone : process(clk)
  begin
    if clk'event and clk='1' then
      if rst='1' then
        state_q <= S_Init;
      else
        state_q <= state_d;
      end if;
    end if;
  end process FSM_synchrone;

  FSM_comb : process (state_q, status)
  begin
    state_d <= state_q;
    -- pré-affectation de commandes (cf MMIPS_pkg.vhd)
    cmd <= MMIPS_PO_cmd_zero;
    case state_q is
      when S_Error =>
        state_d <= S_Error;

      when S_Init =>
      -- PC <- 0 + 0
        cmd.ALU_X_sel <= UXS_cst_x00;
        cmd.ALU_Y_sel <= UYS_cst_x00;
        cmd.ALU_OP <= AO_plus;
        cmd.PC_we <= true;
        state_d <= S_Fetch_wait;

      when S_Fetch_wait =>
      -- mem[PC]
        cmd.mem_ce <= true;
        state_d <= S_Fetch;

      when S_Fetch =>
      -- IR <- mem_datain
        cmd.IR_we <= true;
        state_d <= S_Decode;

      when S_Decode =>
      -- PC <- PC + 4
        cmd.ALU_X_sel <= UXS_PC;
        cmd.ALU_Y_sel <= UYS_cst_x04;
        cmd.ALU_OP <= AO_plus;
        cmd.PC_we <= true;
        state_d <= S_Init;

        case status.IR(31 downto 29) is
	    when "100" =>
		case status.IR(28 downto 26) is
		    when "011" =>
			state_d <= S_LW0;
		    when others => null;
		end case;
	    when "101" =>
		case status.IR(28 downto 26) is
		    when "011" =>
			state_d <= S_SW;
		    when others => null;
		end case;
	    when "001" =>
		case status.IR(28 downto 26) is
		    when "111" =>
			state_d <= S_LUI;
		    when "101" =>
			state_d <= S_ORI;
		    when "001" =>
			state_d <= S_ADDI;
		    when "000" =>
			state_d <= S_ADDI;
		    when "100" =>
			state_d <= S_ANDI;
		    when "110" =>
			state_d <= S_XORI;
		    when "010" =>
			state_d <= S_SLTI;
		    when "011" =>
			state_d <= S_SLTIU;
		    when others => null;
		end case;
	    when "000" =>
		case status.IR(28 downto 26) is
		    when "010" =>
			state_d <= S_J;
		    when "100" =>
			state_d <= S_BEQ;
		    when "011" =>
			state_d <= S_JAL;
		    when "101" =>
			state_d <= S_BNE;
		    when "110" =>
			state_d <= S_BLEZ;
		    when "111" =>
			state_d <= S_BGTZ;
		    when "000" =>
			-- OPCODE SPECIAL
			case status.IR(5 downto 3) is
			    when "100" =>
				case status.IR(2 downto 0) is
				    when "000" =>
					state_d <= S_ADD;
				    when "001" =>
					state_d <= S_ADD;
				    when "100" =>
					state_d <= S_AND;
				    when "111" =>
					state_d <= S_NOR;
				    when "101" =>
					state_d <= S_OR;
				    when "110" =>
					state_d <= S_XOR;
				    when "010" =>
					state_d <= S_SUB;
				    when "011" =>
					state_d <= S_SUB;
				    when others => null;
				end case;
			    when "000" =>
				case status.IR(2 downto 0) is
				    when "000" =>
					state_d <= S_SLL;
				    when "100" =>
					state_d <= S_SLL;
				    when "010" =>
					state_d <= S_SRL;
				    when "110" =>
					state_d <= S_SRL;
				    when "011" =>
					state_d <= S_SRA;
				    when "111" =>
					state_d <= S_SRA;
				    when others => null;
				end case;
			    when"001" =>
				case status.IR(2 downto 0) is
				    when"000" =>
					state_d <= S_JR;
				    when "001" =>
			 	  state_d <= S_JALR;
				    when others => null;
				end case;
			    when "101" =>
				case status.IR(2 downto 0) is
				    when "010" =>
					state_d <= S_SLT;
				    when "011" =>
					state_d <= S_SLTU;
				    when others => null;
        end case;
			    when others => null;
			end case;
		    when "001" =>
			-- OPCODE REGIMM
			case status.IR(20) is
			    when '0' =>
				case status.IR(16) is
				    when '0' =>
					state_d <= S_BLTZ;
				    when others =>
					state_d <= S_BGEZ;
				end case;
			    when others =>
				case status.IR(16) is
				    when '0' =>
					state_d <= S_BLTZAL;
				    when others =>
					state_d <= S_BGEZAL;
				end case;
			end case;
		    when others => null;
		end case;
    	    when others => null;
        end case;

      when S_LUI =>
	-- RT <- IR(15:0) << 16
	cmd.ALU_X_sel <= UXS_cst_x10;
	cmd.ALU_Y_sel <= UYS_IR_imm16;
	cmd.ALU_OP <= AO_SLL;
	cmd.RF_Sel <= RFS_RT;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

     when S_ORI =>
	-- RT <- UYS_IR_imm16 OR RS
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_IR_imm16;
	cmd.ALU_OP <= AO_or;
	cmd.RF_Sel <= RFS_RT;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

     when S_ADD =>
	-- rd <- rs + rt
	case status.IR(0) is
	    when '0' =>
		cmd.ALU_extension_signe <= '0';
	    when others =>
		cmd.ALU_extension_signe <= '1';
	end case;
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_RF_RT;
	cmd.RF_Sel <= RFS_RD;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

    when S_ADDI =>
        -- rt <- (imm16(16-15)||imm16(15-0)) + rs
	case status.IR(26) is
	    when '0' =>
		cmd.ALU_extension_signe <= '0';
	    when others =>
		cmd.ALU_extension_signe <= '1';
	end case;
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_IR_imm16_ext;
	cmd.RF_Sel <= RFS_RT;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

    when S_SLL =>
	-- Décalage à gauche immédiat
	cmd.ALU_OP <= AO_SLL;
	case status.IR(2) is
	    when '0' =>
		cmd.ALU_X_sel <= UXS_IR_SH;
	    when others =>
		cmd.ALU_X_sel <= UXS_RF_RS;
	end case;
	cmd.ALU_Y_sel <= UYS_RF_RT;
	cmd.RF_sel <= RFS_RD;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

    when S_AND =>
	-- rd <- rs and rt
	cmd.ALU_OP <= AO_and;
	cmd.ALU_X_sel <= UXS_RF_RS;
	case status.IR(29) is
	    when '0' =>
		cmd.ALU_Y_sel <= UYS_RF_RT;
	    when others =>
		cmd.ALU_Y_sel <= UYS_IR_imm16_ext;
	end case;
	cmd.RF_sel <= RFS_RD;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

    when S_ANDI =>
	-- rt <- (0...0 || IMM16) and rs
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_IR_imm16;
	cmd.RF_sel <= RFS_RT;
	cmd.ALU_OP <= AO_and;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

    when S_NOR =>
	-- rd <- rs nor rt
	cmd.ALU_OP <= AO_nor ;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_RF_RT;
	cmd.RF_sel <= RFS_RD;
	cmd.RF_we <= true;
	-- mem[PC]14
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

    when S_OR =>
	-- rd <- rs or rt
	cmd.ALU_OP <= AO_or ;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_RF_RT;
	cmd.RF_sel <= RFS_RD;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

    when S_XOR =>
	-- rd <- rs xor rt
	cmd.ALU_OP <= AO_xor ;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_RF_RT;
	cmd.RF_sel <= RFS_RD;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

    when S_XORI =>
	-- rt <- (0...0 || IMM16) xor rs
	cmd.ALU_OP <= AO_xor;
	cmd.ALU_Y_sel <= UYS_IR_imm16;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.RF_sel <= RFS_RT;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

     when S_SUB =>
	-- rd <- rs - rt
	case status.IR(0) is
	    when '0' =>
		cmd.ALU_extension_signe <= '0';
	    when others =>
		cmd.ALU_extension_signe <= '1';
  end case;
	cmd.ALU_OP <= AO_moins;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_RF_RT;
	cmd.RF_Sel <= RFS_RD;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

    when S_SRL =>
	-- Décalage à droite logique
	cmd.ALU_OP <= AO_SRL;
	case status.IR(2) is
	    when '0' =>
		cmd.ALU_X_sel <= UXS_IR_SH;
	    when others =>
		cmd.ALU_X_sel <= UXS_RF_RS;
	end case;
	cmd.ALU_Y_sel <= UYS_RF_RT;
	cmd.RF_sel <= RFS_RD;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

    when S_SRA =>
	-- Décalage artihmétique à droite
	cmd.ALU_OP <= AO_SRA;
	case status.IR(2) is
	    when '0' =>
		cmd.ALU_X_sel <= UXS_IR_SH;
	    when others =>
		cmd.ALU_X_sel <= UXS_RF_RS;
	end case;
	cmd.ALU_Y_sel <= UYS_RF_RT;
	cmd.RF_sel <= RFS_RD;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

    when S_J =>
	-- pc <- (pc + 4)(31...28) || IMM26(25...0) || 00
	cmd.ALU_OP <= AO_or;
	cmd.ALU_X_sel <= UXS_PC_up;
	cmd.ALU_Y_sel <= UYS_IR_imm26;
	cmd.PC_we <= true;
	state_d <= S_Fetch_wait;

    when S_BEQ =>
	-- si (rs = rt), alors : beq2
	cmd.ALU_OP <= AO_moins;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_RF_RT;
	case status.z is
	    when true =>
		state_d <= S_BEQ2;
	    when others =>
		-- mem[PC]
		cmd.mem_ce <= true;
		state_d <= S_Fetch;
	end case;


    when S_BEQ2 =>
	-- pc <- pc + 4 + (IMM16(14-15) || IMM16(15...0) || 00)
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_PC;
	cmd.ALU_Y_sel <= UYS_IR_imm16_ext_up;
	cmd.PC_we <= true;
	cmd.ADDR_sel <= ADDR_from_PC;
	state_d <= S_Fetch_wait;

    when S_JAL =>
	-- $31 <- pc + 4
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_PC;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	cmd.RF_sel <= RFS_31;
	cmd.RF_we <= true;
	cmd.mem_ce <= true;
	state_d <= S_J;

    when S_JALR =>
	-- rd <- pc+4
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_PC;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	cmd.RF_sel <= RFS_RD;
	cmd.RF_we <= true;
	cmd.mem_ce <= true;
	state_d <= S_JALR2;

    when S_JALR2 =>
	--pc <- rs
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	cmd.PC_we <= true;
	state_d <= S_Fetch_wait;

    when S_JR =>
	-- pc <- rs
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	cmd.PC_we <= true;
	state_d <= S_Fetch_wait;

    when S_BNE =>
	-- si (rs =/= rt), alors : beq2
	cmd.ALU_OP <= AO_moins;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_RF_RT;
	case status.z is
	    when false =>
		state_d <= S_BEQ2;
	    when others =>
		-- mem[PC]
		cmd.mem_ce <= true;
		state_d <= S_Fetch;
    end case;

    when S_BLEZ =>
	-- si (rs <= 0), alors : beq2
	cmd.ALU_OP <= AO_moins;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	case status.s is
	    when true =>
		state_d <= S_BEQ2;
	    when others =>
		case status.z is
		    when true =>
			state_d <= S_BEQ2;
		    when others =>
			-- mem[PC]
			cmd.mem_ce <= true;
			state_d <= S_Fetch ;
		end case;
	    end case;

    when S_BLTZ =>
	-- si (rs < 0), alors : beq2
	cmd.ALU_OP <= AO_moins;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	case status.s is
	    when true =>
		state_d <= S_BEQ2;
	    when others =>
		-- mem[PC]
		cmd.mem_ce <= true;
		state_d <= S_Fetch ;
	    end case;

    when S_BGEZ =>
	-- si (rs >= 0), alors : beq2
	cmd.ALU_OP <= AO_moins;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	case status.s is
	    when false =>
		state_d <= S_BEQ2 ;
	    when others =>
		-- mem[PC]
		cmd.mem_ce <= true;
		state_d <= S_Fetch ;

	end case;

    when S_BGTZ =>
	-- si (rs > 0), alors : beq2
	cmd.ALU_OP <= AO_moins;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	case status.s is
	    when false =>
		case status.z is
		    when false =>
			state_d <= S_BEQ2 ;
		    when others =>
			-- mem[PC]
			cmd.mem_ce <= true;
			state_d <= S_Fetch ;
		end case;
	    when others =>
		-- mem[PC]
		cmd.mem_ce <= true;
		state_d <= S_Fetch ;
	end case;

    when S_BGEZAL =>
	-- $31 <- pc + 4
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_PC;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	cmd.RF_sel <= RFS_31;
	cmd.RF_we <= true;
	cmd.mem_ce <= true;
	state_d <= S_BGEZAL2;

    when S_BGEZAL2 =>
	-- si (rs >= 0), alors : branchement fonction
	cmd.ALU_OP <= AO_moins;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	case status.s is
	    when false =>
		state_d <= S_BEQ2 ;
	    when others =>
		-- mem[PC]
		cmd.mem_ce <= true;
		state_d <= S_Fetch ;
	end case;

    when S_BLTZAL =>
	-- $31 <- pc + 4
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_PC;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	cmd.RF_sel <= RFS_31;
	cmd.RF_we <= true;
	cmd.mem_ce <= true;
	state_d <= S_BLTZAL2;

    when S_BLTZAL2 => 
	-- si (rs < 0), alors : branchement fonction
	cmd.ALU_OP <= AO_moins;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	case status.s is
	    when true =>
		state_d <= S_BEQ2 ;
	    when others =>
		-- mem[PC]
		cmd.mem_ce <= true;
		state_d <= S_Fetch ;
	end case;

    when S_LW0 =>
	--rt <- mem[(IMM16 16-15 || IMM16 15-0) + rs]
	-- Première étape : calcul de l'adresse et envoi vers la mémoire
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_IR_imm16_ext;
	cmd.AD_we <= true;
	state_d <= S_LW1;

    when S_LW1 =>
	cmd.ADDR_sel <= ADDR_from_AD;
	cmd.mem_ce <= true;
	state_d <= S_LW2;

    when S_LW2 =>
	-- Deuxième étape : R2cupération de la valeur en mémoire dans DT
	cmd.DT_we <= true;
	state_d <= S_LW3;

    when S_LW3 =>
	--Troisième étape : Transférer de DT vers rt
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_DT;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	cmd.RF_sel <= RFS_RT;
	cmd.RF_we <= true;
	cmd.mem_ce <= true;
	state_d <= S_Fetch;

    when S_SW =>
	-- mem[(IMM16 16-15 || IMM16 15-0) + rs)] <- rt
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_IR_imm16_ext;
	cmd.AD_we <= true;
	state_d <= S_SW2;

    when S_SW2 =>
	cmd.ADDR_sel <= ADDR_from_AD;
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_cst_x00;
	cmd.ALU_Y_sel <= UYS_RF_RT;
	cmd.mem_we <= true;
	cmd.mem_ce <= true;
	state_d <= S_Fetch_wait;

    when S_SLT =>
	-- rs < rt => rd <- 0...0||1
	-- rs >= rt => rd <- 0...0
	cmd.ALU_extension_signe <= '1';
	cmd.ALU_OP <= AO_moins;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_RF_RT;
	case status.s is
	    when true =>
		state_d <= S_SLT3;
	    when others =>
		state_d <= S_SLT2;
	end case;

    when S_SLTU =>
	-- rs < rt => rd <- 0...0||1
	-- rs >= rt => rd <- 0...0
	cmd.ALU_extension_signe <= '0';
	cmd.ALU_OP <= AO_moins;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_RF_RT;
	case status.c is
	    when true =>
		state_d <= S_SLT3;
	    when others =>
		state_d <= S_SLT2;
	end case;

    when S_SLT2 =>
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_cst_x00;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	cmd.RF_sel <= RFS_RD;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch ;

    when S_SLT3 =>
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_cst_x01;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	cmd.RF_sel <= RFS_RD;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch ;

    when S_SLTI =>
	-- rs < (IMM16(16-15)||IMM16(15...0)) => rd <- 0...0||1
	-- rs >= (IMM16(16-15)||IMM16(15...0)) => rd <- 0...0
	cmd.ALU_extension_signe <= '1';
	cmd.ALU_OP <= AO_moins;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_IR_imm16_ext;
	case status.s is
	    when true =>
		state_d <= S_SLTI3;
	    when others =>
		state_d <= S_SLTI2;
	end case;

    when S_SLTIU =>
	-- rs < (IMM16(16-15)||IMM16(15...0)) => rd <- 0...0||1
	-- rs >= (IMM16(16-15)||IMM16(15...0)) => rd <- 0...0
	cmd.ALU_extension_signe <= '0';
	cmd.ALU_OP <= AO_moins;
	cmd.ALU_X_sel <= UXS_RF_RS;
	cmd.ALU_Y_sel <= UYS_IR_imm16_ext;
	case status.c is
	    when true =>
		state_d <= S_SLTI3;
	    when others =>
		state_d <= S_SLTI2;
	end case;

    when S_SLTI2 =>
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_cst_x00;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	cmd.RF_sel <= RFS_RT;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch ;

    when S_SLTI3 =>
	cmd.ALU_OP <= AO_plus;
	cmd.ALU_X_sel <= UXS_cst_x01;
	cmd.ALU_Y_sel <= UYS_cst_x00;
	cmd.RF_sel <= RFS_RT;
	cmd.RF_we <= true;
	-- mem[PC]
	cmd.mem_ce <= true;
	state_d <= S_Fetch ;

   when others => null;

    end case;
  end process FSM_comb;
end RTL;
