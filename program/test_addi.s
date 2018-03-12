.text
# Pour les tests ne pas utiliser le registre $1
lui $2, 0x0001
addi $28, $2, 1
addi $28, $28, 1
addi $28, $2, 16


# pout_start
# 00010001
# 00010002
# 00010010
# pout_end
