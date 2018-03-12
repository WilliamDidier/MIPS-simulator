.text
# Pour les tests ne pas utiliser le registre $1

lui $2, 0x0000
lui $3, 0x0011
lui $4, 0x0001

or $28, $2, $3
or $28, $3, $4

and $28, $2, $3
and $28, $3, $4

nor $28, $3, $4

addi $2, $0, 3
andi $28, $2, 1

# pout_start
# 00110000
# 00110000
# 00000000
# 00010000
# FFEEFFFF
# 00000001
# pout_end
